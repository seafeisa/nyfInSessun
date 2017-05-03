#import "SSBLEDeviceManager.h"
#import "SSBLEReadWriteManager.h"


const NSTimeInterval kTimeoutRefresh = 0.01f;
const NSTimeInterval kTimeoutReconnect = 4.0f;
const NSTimeInterval kTimeoutRewrite = 1.0f;
const NSTimeInterval kTimeoutRead = 2.0f;
const NSTimeInterval kTimeoutScan = 30.0f;
const NSTimeInterval kTimeOutReadRSSI = 1.0f;


const NSInteger kMaxAutoReconnectCount = 0;
const NSInteger kMaxManualReconnectCount = NSIntegerMax;


@interface SSBLEDeviceManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *_centralMgr;
    NSMutableArray *_targetDelegates;
    
    NSMutableDictionary *_typeToDeviceMap;
    NSMutableDictionary *_nameToConnectDeviceMap;
    NSMutableDictionary *_nameToBroadcastDeviceMap;
    
    NSInteger _rewriteCount;
    int _rssiMin;
    int _bleMode;
    NSMutableDictionary *_serialNOToDeviceIDMap;
    NSMutableDictionary *_deviceIDToNeedConnectAdvertiseNameMap;
    NSMutableDictionary *_serialNOToNeedConnectAdvertiseNameMap;
    NSMutableDictionary *_deviceIDToConnectingPeripheralMap;
    NSMutableDictionary *_deviceIDToPeripheralMap;
    NSInteger _maxConnectCount;
    
    NSInteger _scanDateTime;
    NSInteger _readRSSIDateTime;
    NSTimer *_timerRefresh;
    
    BOOL _ifOutputLog;
}
@end


@implementation SSBLEDeviceManager

@synthesize deviceIDToPeripheralMap = _deviceIDToPeripheralMap;

- (void)dealloc {
    _centralMgr.delegate = nil;
    [self disconnect];
}

- (id)initWithDeviceTypes:(NSArray *)deviceTypes rssiMin:(int)rssiMin {
    self = [super init];
    if (self) {
        self.ifTestPeripheral = NO;
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *identifier = (NSString *)[infoDictionary objectForKey:@"CFBundleIdentifier"];
        dispatch_queue_t centralQueue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_SERIAL);
        _centralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
        _targetDelegates = [NSMutableArray array];
        
        _nameToConnectDeviceMap = [NSMutableDictionary dictionary];
        _nameToBroadcastDeviceMap = [NSMutableDictionary dictionary];
        _typeToDeviceMap = [SSBLEDevice getDevicesNameMap:_nameToConnectDeviceMap :_nameToBroadcastDeviceMap :deviceTypes];
        
        _rewriteCount = NSIntegerMax;
        _rssiMin = rssiMin;
        _bleMode = SSBLEModeConnectManual;
        _serialNOToDeviceIDMap = [NSMutableDictionary dictionary];
        _deviceIDToNeedConnectAdvertiseNameMap = [NSMutableDictionary dictionary];
        _serialNOToNeedConnectAdvertiseNameMap = [NSMutableDictionary dictionary];
        _deviceIDToConnectingPeripheralMap = [NSMutableDictionary dictionary];
        _deviceIDToPeripheralMap = [NSMutableDictionary dictionary];
        _maxConnectCount = 2;
        
        _readRSSIDateTime = -1;
        _timerRefresh = nil;
        
        _ifOutputLog = NO;
#ifdef DEBUG
        _ifOutputLog = NO;
#endif
        
    }
    return self;
}

- (NSInteger)peripheralsCount {
    return _deviceIDToPeripheralMap.count;
}

- (void)setRewriteCount:(NSInteger)count {
    _rewriteCount = count;
}
- (void)setMaxConnectCount:(NSInteger)count {
    _maxConnectCount = count;
}
- (void)startTimer {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_timerRefresh invalidate];
        _timerRefresh = [NSTimer scheduledTimerWithTimeInterval:kTimeoutRefresh target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    });
}

- (void)stopTimer {
    [_timerRefresh invalidate];
    _timerRefresh = nil;
}

- (void)timerTick:(id)sender {
    NSDate *date = [NSDate date];
    NSInteger interval = [date timeIntervalSince1970];
    
    if (_scanDateTime != -1 && interval - _scanDateTime >= kTimeoutScan) {
        [self scanPeripherals];
    }
    
    if (_readRSSIDateTime == -1 || interval - _readRSSIDateTime >= kTimeOutReadRSSI) {
        _readRSSIDateTime = interval;
        [self readRSSI];
    }
    
    CBPeripheral *peripheral = nil;
    for (NSInteger i = _deviceIDToConnectingPeripheralMap.count - 1; i >= 0; i--) {
        peripheral = [_deviceIDToConnectingPeripheralMap.allValues objectAtIndex:i];
        if (!peripheral.connectDateTime) {
            continue;
        }
        if (interval - peripheral.connectDateTime.integerValue >= kTimeoutReconnect) {
            if (_bleMode == SSBLEModeConnectAuto && _maxConnectCount != -1 && [_deviceIDToPeripheralMap count] >= _maxConnectCount) {
                [_centralMgr cancelPeripheralConnection:peripheral];
                continue;
            }
            
            if (peripheral.maxReConnectCount.integerValue <= 0) {
                if ([_deviceIDToNeedConnectAdvertiseNameMap objectForKey:peripheral.deviceID]) {
                    [_deviceIDToNeedConnectAdvertiseNameMap removeObjectForKey:peripheral.deviceID];
                }
                [_centralMgr cancelPeripheralConnection:peripheral];
                if (_ifOutputLog) {
                    NSLog(@"connect time out %li:%li", (long)peripheral.connectDateTime, (long)interval);
                }
                continue;
            }
            
            if (_ifOutputLog) {
                NSLog(@"reconnect: %@", peripheral.deviceID);
            }
            peripheral.connectDateTime = @(interval);
            peripheral.maxReConnectCount = @(peripheral.maxReConnectCount.integerValue - 1);
        }
    }
    
    for (NSInteger i = _deviceIDToPeripheralMap.count - 1; i >= 0; i--) {
        peripheral = [_deviceIDToPeripheralMap.allValues objectAtIndex:i];
        if (peripheral.readWriteMgr && peripheral.readWriteMgr.readDateTime != -1 && interval - peripheral.readWriteMgr.readDateTime >= kTimeoutRead) {
            if (_ifOutputLog) {
                NSLog(@"read time out %li:%li", (long)peripheral.readWriteMgr.readDateTime, (long)interval);
            }
            if (peripheral.ifBroadcast && peripheral.ifBroadcast.boolValue) {
                peripheral.ifBroadcast = nil;
                [_deviceIDToPeripheralMap removeObjectForKey:peripheral.deviceID];
                id target = nil;
                for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
                    target = [_targetDelegates objectAtIndex:i];
                    if ([target respondsToSelector:@selector(peripheralDidDisconnect:)]) {
                        [target peripheralDidDisconnect:peripheral];
                    }
                }
                [self scanPeripherals:_bleMode];
            }
        }
        
        if (peripheral.readWriteMgr && peripheral.readWriteMgr.writeBuffer && peripheral.readWriteMgr.writeBuffer.count > 0) {
            NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
            SSBLEReadWriteData *writeData = [writeBuffer objectAtIndex:0];
            if (writeData.writeDateTime == -1) {
                writeData.writeDateTime = interval;
                [self writeData:writeData.data :peripheral];
                if (_ifOutputLog) {
                    NSLog(@"write data:%@ , %d", writeData.data, writeData.dataType);
                    NSLog(@"write Buffer count : %d", (int)peripheral.readWriteMgr.writeBuffer.count);
                }
            } else if (writeData.ifReply) {
                @synchronized(writeBuffer) {
                    [writeBuffer removeObjectAtIndex:0];
                }
                if (_ifOutputLog) {
                    NSLog(@"write Buffer count : %d", (int)peripheral.readWriteMgr.writeBuffer.count);
                }
            } else if (!writeData.ifReply && interval - writeData.writeDateTime >= kTimeoutRewrite) {
                if (writeData.maxRewriteCount <= 0) {
                    @synchronized(writeBuffer) {
                        [writeBuffer removeObjectAtIndex:0];
                    }
                    if (_ifOutputLog) {
                        NSLog(@"write Buffer count : %d", (int)peripheral.readWriteMgr.writeBuffer.count);
                    }
                    //writeData.dataType = -1;
                    writeData.data = nil;
                    id target = nil;
                    for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
                        target = [_targetDelegates objectAtIndex:i];
                        if ([target respondsToSelector:@selector(peripheralDidFailToWrite:data:)]) {
                            [target peripheralDidFailToWrite:peripheral data:writeData];
                        }
                    }
                } else {
                    writeData.writeDateTime = interval;
                    writeData.maxRewriteCount -= 1;
                    [self writeData:writeData.data :peripheral];
                    if (_ifOutputLog) {
                        NSLog(@"write data:%@ , %d", writeData.data, writeData.dataType);
                        NSLog(@"write Buffer count : %d", (int)peripheral.readWriteMgr.writeBuffer.count);
                    }
                }
            }
        }
    }
}

#pragma mark add/remove delegate
- (void)addDelegate:(id)delegate {
    if (!delegate) {
        return;
    }
    
    NSUInteger hash = [delegate hash];
    BOOL flag = NO;
    id target = nil;
    for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
        target = [_targetDelegates objectAtIndex:i];
        if ([target hash] == hash) {
            flag = YES;
            break;
        }
    }
    
    if (!flag) {
        [_targetDelegates addObject:delegate];
    }
}

- (void)removeDelegate:(id)delegate {
    if (!delegate) {
        [_targetDelegates removeAllObjects];
    } else {
        [_targetDelegates removeObject:delegate];
    }
}

#pragma mark connect/disconnect BLE
- (void)stopScan {
    _scanDateTime = -1;
    [_centralMgr stopScan];
    if (_ifOutputLog) {
        NSLog(@"stop scan");
    }
}

- (void)reset {
    [_serialNOToDeviceIDMap removeAllObjects];
    [_deviceIDToNeedConnectAdvertiseNameMap removeAllObjects];
    [_serialNOToNeedConnectAdvertiseNameMap removeAllObjects];
    [_deviceIDToConnectingPeripheralMap removeAllObjects];
    [_deviceIDToPeripheralMap removeAllObjects];
}

- (void)scanPeripherals {
    if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    [self stopScan];
    NSMutableDictionary *serviceIDs = [NSMutableDictionary dictionary];
    for (SSBLEDevice *device in _typeToDeviceMap.allValues) {
        [serviceIDs addEntriesFromDictionary:device.shortServiceUUIDs];
    }
    [_centralMgr scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    _scanDateTime = [[NSDate date] timeIntervalSince1970];
    [self startTimer];
    if (_ifOutputLog) {
        NSLog(@"scan");
    }
}

- (void)scanPeripherals:(int)bleMode {
    _bleMode = bleMode;
    if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    [self stopScan];
    
    if (_bleMode == SSBLEModeConnectAuto &&
        _maxConnectCount != -1 &&
        [_deviceIDToPeripheralMap count] >= _maxConnectCount) {
        return;
    }
    NSMutableDictionary *serviceIDs = [NSMutableDictionary dictionary];
    for (SSBLEDevice *device in _typeToDeviceMap.allValues) {
        [serviceIDs addEntriesFromDictionary:device.shortServiceUUIDs];
    }
    [_centralMgr scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    _scanDateTime = [[NSDate date] timeIntervalSince1970];
    [self startTimer];
    if (_ifOutputLog) {
        NSLog(@"scan");
    }
}

- (void)connect:(NSDictionary *)deviceIDToAdvertiseNameMap {
    _bleMode = SSBLEModeConnectManual;
    [_deviceIDToNeedConnectAdvertiseNameMap addEntriesFromDictionary:deviceIDToAdvertiseNameMap];
    
    if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    [self scanPeripherals:_bleMode];
}

- (void)disconnect:(NSString *)deviceID {
    if ([_deviceIDToNeedConnectAdvertiseNameMap objectForKey:deviceID]) {
        [_deviceIDToNeedConnectAdvertiseNameMap removeObjectForKey:deviceID];
    }
    
    CBPeripheral *peripheral = [_deviceIDToConnectingPeripheralMap objectForKey:deviceID];
    if (peripheral) {
        [_serialNOToNeedConnectAdvertiseNameMap removeObjectForKey:peripheral.serialNO];
        [_deviceIDToConnectingPeripheralMap removeObjectForKey:peripheral.deviceID];
        [_centralMgr cancelPeripheralConnection:peripheral];
        return;
    }
    
    peripheral = [_deviceIDToPeripheralMap objectForKey:deviceID];
    if (peripheral) {
        [_serialNOToNeedConnectAdvertiseNameMap removeObjectForKey:peripheral.serialNO];
        peripheral.ifExpectDisconnect = @(YES);
        [self cancelConnectPeripheral:peripheral];
        return;
    }
}

- (void)connectWithSerialNO:(NSDictionary *)serialNOToAdvertiseNameMap {
    _bleMode = SSBLEModeConnectManual;
    for (NSString *key in serialNOToAdvertiseNameMap) {
        id value = serialNOToAdvertiseNameMap[key];
        [_serialNOToNeedConnectAdvertiseNameMap setObject:value forKey:[key uppercaseString]];
    }
    //[_serialNOToNeedConnectAdvertiseNameMap addEntriesFromDictionary:serialNOToAdvertiseNameMap];
    
    if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    [self scanPeripherals:_bleMode];
}

- (void)disconnectWithSerialNO:(NSString *)serialNO {
    serialNO = [serialNO uppercaseString];
    if ([_serialNOToNeedConnectAdvertiseNameMap objectForKey:serialNO]) {
        [_serialNOToNeedConnectAdvertiseNameMap removeObjectForKey:serialNO];
        NSString *deviceID = [_serialNOToDeviceIDMap objectForKey:serialNO];
        if (deviceID) {
            [_deviceIDToNeedConnectAdvertiseNameMap removeObjectForKey:deviceID];
        }
    }
    
    CBPeripheral *peripheral = nil;
    for (NSInteger i = _deviceIDToConnectingPeripheralMap.count - 1; i >= 0; i--) {
        peripheral = [_deviceIDToConnectingPeripheralMap.allValues objectAtIndex:i];
        if (peripheral.serialNO && [peripheral.serialNO isEqualToString:serialNO]) {
            [_deviceIDToNeedConnectAdvertiseNameMap removeObjectForKey:peripheral.deviceID];
            [_deviceIDToConnectingPeripheralMap removeObjectForKey:peripheral.deviceID];
            [_centralMgr cancelPeripheralConnection:peripheral];
            return;
        }
    }
    
    for (NSInteger i = _deviceIDToPeripheralMap.count - 1; i >= 0; i--) {
        peripheral = [_deviceIDToPeripheralMap.allValues objectAtIndex:i];
        if (peripheral.serialNO && [peripheral.serialNO isEqualToString:serialNO]) {
            [_deviceIDToNeedConnectAdvertiseNameMap removeObjectForKey:peripheral.deviceID];
            peripheral.ifExpectDisconnect = @(YES);
            [self cancelConnectPeripheral:peripheral];
            return;
        }
    }
}

- (void)connect {
    _bleMode = SSBLEModeConnectAuto;
    
    if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if ( _maxConnectCount != -1 && [_deviceIDToPeripheralMap count] >= _maxConnectCount) {
        return;
    }
    
    [self scanPeripherals:_bleMode];
}

- (void)disconnect {
    [self stopTimer];
    [self stopScan];

    NSInteger count = _deviceIDToConnectingPeripheralMap.allValues.count;
    CBPeripheral *peripheral = nil;
    for (NSInteger i = count - 1; i >= 0; i--) {
        peripheral = [_deviceIDToConnectingPeripheralMap.allValues objectAtIndex:i];
        [_deviceIDToConnectingPeripheralMap removeObjectForKey:peripheral.deviceID];
        [_centralMgr cancelPeripheralConnection:peripheral];
    }
    
    count = _deviceIDToPeripheralMap.allValues.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        peripheral = [_deviceIDToPeripheralMap.allValues objectAtIndex:i];
        peripheral.ifExpectDisconnect = @(YES);
        [self cancelConnectPeripheral:peripheral];
    }
    
    [self reset];
}

- (SSBLEDevice *)getDeviceWithName:(NSString *)advertiseName {
    SSBLEDevice *device = [_nameToConnectDeviceMap objectForKey:advertiseName];
    if (device) {
        return device;
    }
    
    device = [_nameToBroadcastDeviceMap objectForKey:advertiseName];
    if (device) {
        return device;
    }
    
    for (NSInteger i = _typeToDeviceMap.allValues.count - 1; i >= 0; i--) {
        SSBLEDevice *temp = [_typeToDeviceMap.allValues objectAtIndex:i];
        if (temp.ifPrefixName) {
            if ([self getDeviceName:temp :advertiseName]) {
                device = temp;
            }
        }
    }
    
    return device;
}

- (NSString *)getDeviceName:(SSBLEDevice *)device :(NSString *)advertiseName {
    NSString *deviceName = nil;
    
    NSArray *names = device.nameToServiceMap.allKeys;
    for (NSInteger i = names.count - 1; i >= 0; i--) {
        NSString *name = [names objectAtIndex:i];
        if ([advertiseName hasPrefix:name]) {
            deviceName = name;
            break;
        }
    }
    
    return deviceName;
}

- (void)resetPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = nil;
    peripheral.connectDateTime = nil;
    peripheral.ifBroadcast = nil;
    peripheral.ifExpectDisconnect = nil;
    peripheral.readWriteMgr = nil;
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {
    NSDate *date = [NSDate date];
    NSInteger interval = [date timeIntervalSince1970];
    
    NSInteger maxReconnectCount = -1;
    if (_bleMode == SSBLEModeConnectManual) {
        maxReconnectCount = kMaxManualReconnectCount;
    } else if (_bleMode == SSBLEModeConnectAuto) {
        maxReconnectCount = kMaxAutoReconnectCount;
    }
    
    [self stopTimer];
    [_deviceIDToConnectingPeripheralMap setObject:peripheral forKey:peripheral.deviceID];
    SSBLEDevice *device = [_nameToConnectDeviceMap objectForKey:peripheral.advertiseName];
    [self resetPeripheral:peripheral];
    peripheral.deviceType = @(device.deviceType);
    if (device.ifPrefixName && [self getDeviceName:device :peripheral.advertiseName]) {
        peripheral.serialNO = peripheral.advertiseName;
    } else if (!peripheral.serialNO) {
        peripheral.serialNO = peripheral.deviceID;
    }
    peripheral.maxReConnectCount = @(maxReconnectCount);
    peripheral.connectDateTime = @(interval);
    [_centralMgr connectPeripheral:peripheral options:nil];
    [self startTimer];
    if (_ifOutputLog) {
        NSLog(@"connect: %@\r\nserial NO:%@\r\ndevice Type:%d", peripheral.deviceID, peripheral.serialNO, peripheral.deviceType.intValue);
    }
    
    id target = nil;
    for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
        target = [_targetDelegates objectAtIndex:i];
        if ([target respondsToSelector:@selector(peripheralDidConnecting:)]) {
            [target peripheralDidConnecting:peripheral];
        }
    }
}

- (void)cancelConnectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral.ifBroadcast && peripheral.ifBroadcast.boolValue) {
        if ([_deviceIDToPeripheralMap objectForKey:peripheral.deviceID]) {
            if (_timerRefresh && _timerRefresh.isValid) {
                [self stopTimer];
                [_deviceIDToPeripheralMap removeObjectForKey:peripheral.deviceID];
                [self startTimer];
            } else {
                [_deviceIDToPeripheralMap removeObjectForKey:peripheral.deviceID];
            }
            id target = nil;
            for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
                target = [_targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidDisconnect:)]) {
                    [target peripheralDidDisconnect:peripheral];
                }
            }
        }
    } else {
        peripheral.delegate = nil;
        [_centralMgr cancelPeripheralConnection:peripheral];
    }
}

#pragma mark CBCentralManager Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [_timerRefresh invalidate];
    
    if (_centralMgr.state == CBCentralManagerStateUnsupported) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSLog(@"Sorry, BLE is not supported for this device!");
        });
        return;
    } else if (_centralMgr.state == CBCentralManagerStatePoweredOff) {
        for (CBPeripheral *peripheral in _deviceIDToPeripheralMap.allValues) {
            id target = nil;
            for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
                target = [_targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidDisconnect:)]) {
                    [target peripheralDidDisconnect:peripheral];
                }
            }
        }
        [_deviceIDToConnectingPeripheralMap removeAllObjects];
        [_deviceIDToPeripheralMap removeAllObjects];
        return;
    } else if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (_centralMgr.state == CBCentralManagerStatePoweredOn) {
        if (_bleMode == SSBLEModeConnectManual) {
            if (_deviceIDToNeedConnectAdvertiseNameMap.count > 0) {
                [self connect:_deviceIDToNeedConnectAdvertiseNameMap];
            }
            if (_serialNOToNeedConnectAdvertiseNameMap.count > 0) {
                [self connectWithSerialNO:_serialNOToNeedConnectAdvertiseNameMap];
            }
            if (_deviceIDToNeedConnectAdvertiseNameMap.count == 0 && _serialNOToNeedConnectAdvertiseNameMap.count == 0) {
                [self scanPeripherals];
            }
        } else if (_bleMode == SSBLEModeConnectAuto) {
            [self connect];
        }
    }
}

- (NSString *)dataToHexString:(NSData *)data {
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer) {
        return [NSString string];
    }
    
    NSUInteger dataLength = [data length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%02lX", (unsigned long)dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (RSSI.intValue < _rssiMin || RSSI.intValue == 127) {
        return;
    }
    
    if (peripheral.state != CBPeripheralStateDisconnected) {
        return;
    }
    
    NSString *advertiseName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (!advertiseName) {
        advertiseName = peripheral.name;
    }
    
    SSBLEDevice *device = [self getDeviceWithName:advertiseName];
    if (!device) {
        return;
    }
    
    NSData *data = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (data && data.length < 8 && device.ifBroadcast) {
        return;
    }
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    int byte0 = 0;
    int byte5 = 0;
    if (data && data.length >= 8 && device.ifBroadcast) {
        byte0 = dataBuffer[0];
        if (data.length >= 13) {
            byte5 = dataBuffer[5];
        }
    }

    peripheral.deviceType = @(device.deviceType);
    peripheral.advertiseName = advertiseName;
    if (RSSI.intValue != 127) {
        peripheral.newRSSI = RSSI;
    }
    if (device.ifPrefixName && [self getDeviceName:device :peripheral.advertiseName]) {
        NSString *prefix = [NSString stringWithFormat:@"%@ ", [device.nameToServiceMap.allKeys lastObject]];
        peripheral.serialNO = [advertiseName substringFromIndex:prefix.length];
    } else {
        if ((device.ifBroadcast && (byte0 != 0xFF && byte5 != 0xFF) && data) || (!device.ifBroadcast && data)) {
            peripheral.serialNO = [self dataToHexString:data];
        } else {
            peripheral.serialNO = peripheral.deviceID;
        }
    }
    [_serialNOToDeviceIDMap setObject:peripheral.deviceID forKey:peripheral.serialNO];
    
    if (_bleMode == SSBLEModeConnectManual) {
        if (RSSI.intValue != 127) {
            id target = nil;
            for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
                target = [_targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidDiscover:)]) {
                    [target peripheralDidDiscover:peripheral];
                }
            }
        }
    }
    
    if (device.deviceType == SSBLESENSSUNPAD) {
        NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:SSBLESENSSUNPAD];
        [values setObject:peripheral.deviceID forKey:@"deviceID"];
        if (_ifOutputLog) {
            NSLog(@"broadcast value : %@", values);
        }
        
        SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
        //readWriteData.data = data;
        readWriteData.readValues = values;
        
        id target = nil;
        for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
            target = [_targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidReceived:data:datas:)]) {
                [target peripheralDidReceived:peripheral data:readWriteData datas:nil];
            }
        }
        
    } else if (data && data.length > 0 && device.ifBroadcast && (byte0 == 0xFF || byte5 == 0xFF)) {
        if (_bleMode == SSBLEModeConnectAuto ||
            (_bleMode == SSBLEModeConnectManual && ([_deviceIDToNeedConnectAdvertiseNameMap objectForKey:peripheral.deviceID] ||
                                                    (peripheral.serialNO && [_serialNOToNeedConnectAdvertiseNameMap objectForKey:peripheral.serialNO])))) {
            NSDate *date = [NSDate date];
            NSInteger interval = [date timeIntervalSince1970];
            
            if (!peripheral.ifBroadcast || ![peripheral.ifBroadcast boolValue]) {
                if (_bleMode == SSBLEModeConnectAuto &&
                    _maxConnectCount != -1 &&
                    [_deviceIDToPeripheralMap count] >= _maxConnectCount) {
                    return;
                }
                
                if ([_deviceIDToConnectingPeripheralMap objectForKey:peripheral.deviceID] ||
                    [_deviceIDToPeripheralMap objectForKey:peripheral.deviceID]) {
                    return;
                }
                
                [self stopTimer];
                [self resetPeripheral:peripheral];
                peripheral.ifBroadcast = @(YES);
                SSBLEReadWriteManager *readWriteMgr = [[SSBLEReadWriteManager alloc] init];
                peripheral.readWriteMgr = readWriteMgr;
                peripheral.readWriteMgr.readDateTime = interval;
                [_deviceIDToPeripheralMap setObject:peripheral forKey:peripheral.deviceID];
                id target = nil;
                for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
                    target = [_targetDelegates objectAtIndex:i];
                    if ([target respondsToSelector:@selector(peripheralDidConnect:)]) {
                        [target peripheralDidConnect:peripheral];
                    }
                }
                [self startTimer];
                return;
                
            } else if (peripheral.ifBroadcast && peripheral.ifBroadcast.boolValue == YES) {
                peripheral.readWriteMgr.readDateTime = interval;
                SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
                if (_ifOutputLog) {
                    NSLog(@"broadcast value : %@", data);
                }
                [peripheral.readWriteMgr readData:data :device :peripheral :_targetDelegates :self];
                return;
                
            }
            
        }
    }
    
    if (_maxConnectCount != -1 &&
        [_deviceIDToPeripheralMap count] >= _maxConnectCount) {
        return;
    }
    
    if ([_deviceIDToConnectingPeripheralMap objectForKey:peripheral.deviceID] ||
        [_deviceIDToPeripheralMap objectForKey:peripheral.deviceID]) {
        return;
    }
    
    if (_bleMode == SSBLEModeConnectAuto ||
        (_bleMode == SSBLEModeConnectManual && ([_deviceIDToNeedConnectAdvertiseNameMap objectForKey:peripheral.deviceID] ||
                                                [_serialNOToNeedConnectAdvertiseNameMap objectForKey:peripheral.serialNO]))) {
        [self connectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    if (_bleMode == SSBLEModeConnectAuto && _maxConnectCount != -1 && [_deviceIDToPeripheralMap count] >= _maxConnectCount) {
        [_centralMgr cancelPeripheralConnection:peripheral];
        return;
    }
    
    [self stopTimer];
    SSBLEReadWriteManager *readWriteMgr = [[SSBLEReadWriteManager alloc] init];
    peripheral.readWriteMgr = readWriteMgr;
    /*
    peripheral.connectDateTime = nil;
    [_deviceIDToConnectingPeripheralMap removeObjectForKey:peripheral.deviceID];
    [_deviceIDToPeripheralMap setObject:peripheral forKey:peripheral.deviceID];
    [self startTimer];
    id target = nil;
    for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
        target = [_targetDelegates objectAtIndex:i];
        if ([target respondsToSelector:@selector(peripheralDidConnect:)]) {
            [target peripheralDidConnect:peripheral];
        }
    }
    */
    
    peripheral.delegate = self;
    SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
    [peripheral discoverServices:device.serviceUUIDs.allKeys];
    
    /*
    if (_maxConnectCount != -1 && [_deviceIDToPeripheralMap count] >= _maxConnectCount) {
        [self stopScan];
    }
    */
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error && _ifOutputLog) {
        NSLog(@"disconnect error : %@", error);
    }
    
    [self reconnect:peripheral :error];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error && _ifOutputLog) {
        NSLog(@"fail to connnect error : %@", error);
    }
    
    [self reconnect:peripheral :error];
}

- (void)reconnect:(CBPeripheral *)peripheral :(NSError *)error {
    if ([_deviceIDToConnectingPeripheralMap objectForKey:peripheral.deviceID]) {
        if (_timerRefresh && _timerRefresh.isValid) {
            [self stopTimer];
            [_deviceIDToConnectingPeripheralMap removeObjectForKey:peripheral.deviceID];
            [self startTimer];
        } else {
            [_deviceIDToConnectingPeripheralMap removeObjectForKey:peripheral.deviceID];
        }
        id target = nil;
        for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
            target = [_targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidFailToConnect:)]) {
                [target peripheralDidFailToConnect:peripheral];
            }
        }
        
        if (_bleMode == SSBLEModeConnectAuto) {
            [self scanPeripherals:_bleMode];
        }
    }
    
    if ([_deviceIDToPeripheralMap objectForKey:peripheral.deviceID]) {
        if (_timerRefresh && _timerRefresh.isValid) {
            [self stopTimer];
            [_deviceIDToPeripheralMap removeObjectForKey:peripheral.deviceID];
            [self startTimer];
        } else {
            [_deviceIDToPeripheralMap removeObjectForKey:peripheral.deviceID];
        }
        id target = nil;
        for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
            target = [_targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidDisconnect:)]) {
                [target peripheralDidDisconnect:peripheral];
            }
        }
        
        if (error && !peripheral.ifExpectDisconnect) {
            if (_bleMode == SSBLEModeConnectManual) {
                [self connect:@{peripheral.deviceID: peripheral.advertiseName}];
            } else if (_bleMode == SSBLEModeConnectAuto) {
                [self connect];
            }
        }
    }
}

#pragma mark peripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        if (_ifOutputLog) {
            NSLog(@"discover services error : %@", error);
        }
        [self reconnect:peripheral :error];
        return;
    }
    
    SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
    for (CBService *service in peripheral.services) {
        NSArray *array = [device.serviceUUIDs objectForKey:service.UUID];
        NSMutableArray *idArray = [NSMutableArray array];
        if (array) {
            NSMutableDictionary *ids = [NSMutableDictionary dictionary];
            for (int i = 1; i < array.count; i++) {
                NSString *idString = [array objectAtIndex:i];
                if (![ids objectForKey:idString]) {
                    [ids setObject:idString forKey:idString];
                    [idArray addObject:[CBUUID UUIDWithString:idString]];
                }
            }
            [peripheral discoverCharacteristics:idArray forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        if (_ifOutputLog) {
            NSLog(@"discover characteristics error : %@", error);
        }
        [self reconnect:peripheral :error];
        return;
    }
    
    SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
    NSArray *array = [device.serviceUUIDs objectForKey:service.UUID];
    NSString *notifyID = [array objectAtIndex:1];
    NSString *writeID = [array objectAtIndex:2];
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:notifyID]] &&
            ((characteristic.properties & CBCharacteristicPropertyNotify) || (characteristic.properties & CBCharacteristicPropertyIndicate))) {
            peripheral.readWriteMgr.notifyCharacteristic = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:writeID]] &&
            ((characteristic.properties & CBCharacteristicPropertyWrite) || (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse))) {
            peripheral.readWriteMgr.writeCharacteristic = characteristic;
        }
    }
    
    if (!peripheral.readWriteMgr.notifyCharacteristic || !peripheral.readWriteMgr.writeCharacteristic) {
        return;
    }

    [self stopTimer];
    peripheral.connectDateTime = nil;
    [_deviceIDToConnectingPeripheralMap removeObjectForKey:peripheral.deviceID];
    [_deviceIDToPeripheralMap setObject:peripheral forKey:peripheral.deviceID];
    [self startTimer];
    id target = nil;
    for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
        target = [_targetDelegates objectAtIndex:i];
        if ([target respondsToSelector:@selector(peripheralDidConnect:)]) {
            [target peripheralDidConnect:peripheral];
        }
    }
    if (_maxConnectCount != -1 && [_deviceIDToPeripheralMap count] >= _maxConnectCount) {
        [self stopScan];
    }
    
    if (self.ifTestPeripheral) {
        id target = nil;
        for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
            target = [_targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidAllowWrite:)]) {
                [target peripheralDidAllowWrite:peripheral];
            }
        }
        return;
    }
    
    int deviceType = peripheral.deviceType.intValue;
    if (deviceType == SSBLESENSSUNFAT ||
        deviceType == SSBLESENSSUNHEART ||
        deviceType == SSBLESENSSUNBODYCLOCK ||
        deviceType == SSBLESENSSUNEQi912 ||
        deviceType == SSBLESENSSUNFATCLOCK ||
        deviceType == SSBLESENSSUNJOINTOWN ||
        deviceType == SSBLESENSSUNLETVB1) {
        [self sendSENSSUNFATSyncDate:peripheral];
        [self sendSENSSUNFATSyncTime:peripheral];
        
    } else if (deviceType == SSBLESENSSUNGROWTH) {
        [self sendSENSSUNGROWTHSyncDateTime:peripheral];
        
    } else if (deviceType == SSBLESENSSUNPAD) {
        [self sendSENSSUNPADSyncDateTime:peripheral];
        
    } else {
        id target = nil;
        for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
            target = [_targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidAllowWrite:)]) {
                [target peripheralDidAllowWrite:peripheral];
            }
        }
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error && _ifOutputLog) {
        NSLog(@"set characteristic error : %@", error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (_ifOutputLog) {
        NSLog(@"notify value : %@", characteristic.value);
    }
    
    if (error) {
        if (_ifOutputLog) {
            NSLog(@"notify error : %@", error);
        }
        return;
    }
    
    if (!characteristic.value || characteristic.value.length == 0) {
        return;
    }
    
    SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
    [peripheral.readWriteMgr readData:characteristic.value :device :peripheral :_targetDelegates :self];
}

#pragma mark write data
- (void)writeData:(NSData *)data :(CBPeripheral *)peripheral {
    if (!peripheral || !data) {
        return;
    }
    
    if (peripheral.state == CBPeripheralStateConnected && peripheral.readWriteMgr.writeCharacteristic) {
        if (peripheral.readWriteMgr.writeCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            [peripheral writeValue:data forCharacteristic:peripheral.readWriteMgr.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
        } else {
            [peripheral writeValue:data forCharacteristic:peripheral.readWriteMgr.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error && _ifOutputLog) {
        NSLog(@"write value error : %@", error);
    }
}

#pragma mark read RSSI
- (void)readRSSI {
    for (NSInteger i = _deviceIDToPeripheralMap.count - 1; i >= 0; i--) {
        CBPeripheral *peripheral = [_deviceIDToPeripheralMap.allValues objectAtIndex:i];
        if (!peripheral.ifBroadcast || !peripheral.ifBroadcast.boolValue) {
            if (peripheral.state == CBPeripheralStateConnected) {
                [peripheral readRSSI];
            }
        }
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    peripheral.newRSSI = peripheral.RSSI;
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    peripheral.newRSSI = RSSI;
}

#pragma mark write data to SENSSUNFAT
- (void)sendSENSSUNFATSyncDate:(CBPeripheral *)peripheral {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:date];
    int year = [components year] % 100;
    int order = (int)[calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:date];
    int orderHigh = floor(order / 256);
    int orderLow = (int)order % 256;
    int weekday = (int)[components weekday] - 1;
    
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteSyncDate :year :orderHigh :orderLow :weekday :0x00 :peripheral :_rewriteCount];
}

- (void)sendSENSSUNFATSyncTime:(CBPeripheral *)peripheral {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    int hour = (int)[components hour];
    int minute = (int)[components minute];
    int second = (int)[components second];
    
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteSyncTime :hour :minute :second :0x00 :0x00 :peripheral :_rewriteCount];
}

- (void)sendSENSSUNFATTestFatWithSex:(int)sex userID:(int)userID age:(int)age heightCM:(int)heightCM heightInch:(int)heightInch peripheral:(CBPeripheral *)peripheral {
    int byte3 = userID;
    //clear bit 8 to 0
    byte3 = byte3 & 0x7F;
    //set bit 8 to 0|1
    if (sex % 2 == 0) {
        byte3 = byte3 | (0 << 7);//byte3 & 0x7F;
    } else {
        byte3 = byte3 | (1 << 7);//byte3 | 0x80;
    }
    int heightInchHigh = floor(heightInch / 256);
    int heightInchLow = heightInch % 256;
    
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteTestFat :byte3 :age :heightCM :heightInchHigh :heightInchLow :peripheral :_rewriteCount];
}

- (void)sendSENSSUNFATSearchHistoryWithUserID:(int)userID peripheral:(CBPeripheral *)peripheral {
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteSearchHistory :userID :0x00 :0x00 :0x00 :0x00 :peripheral :_rewriteCount];
}

- (void)sendSENSSUNFATClearData:(CBPeripheral *)peripheral {
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteClearData :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :_rewriteCount];
}

- (void)sendSENSSUNFATCloseScale:(CBPeripheral *)peripheral {
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteCloseScale :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :_rewriteCount];
}

- (void)sendSENSSUNFATResetScale:(CBPeripheral *)peripheral {
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteResetScale :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :_rewriteCount];
}

- (void)sendSENSSUNFATData:(int)dataType :(int)byte3 :(int)byte4 :(int)byte5 :(int)byte6 :(int)byte7 :(CBPeripheral *)peripheral :(NSInteger)maxRewriteCount {
    if (!peripheral) {
        return;
    }
    
    int checkSum = (dataType + byte3 + byte4 + byte5 + byte6 + byte7) % 256;
    NSData *data = nil;
    if ([peripheral.deviceType intValue] == SSBLESENSSUNJOINTOWN) {
        Byte byte[8] = {0x55, dataType, byte3, byte4, byte5, byte6, byte7, checkSum};
        data = [NSData dataWithBytes:byte length:8];
    } else {
        Byte byte[8] = {0xA5, dataType, byte3, byte4, byte5, byte6, byte7, checkSum};
        data = [NSData dataWithBytes:byte length:8];
    }
    
    [peripheral.readWriteMgr addWriteData:data :dataType :maxRewriteCount];
}

#pragma mark write data to SENSSUNFATHEART
- (void)sendSENSSUNHEARTTestHeartRate:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.deviceType.intValue == SSBLESENSSUNHEART) {
        [self sendSENSSUNFATData:SSBLESENSSUNFATWriteTestHeartRate :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :_rewriteCount];
    }
}

- (void)sendSENSSUNHEARTExitTestHeartRate:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.deviceType.intValue == SSBLESENSSUNHEART) {
        [self sendSENSSUNFATData:SSBLESENSSUNFATWriteExitTestHeartRate :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :_rewriteCount];
    }
}

#pragma mark write data to SSBLESENSSUNBODYCLOCK
- (void)sendSENSSUNBODYCLOCKSetting:(CBPeripheral *)peripheral :(int)repeatSun :(int)repeatMon :(int)repeatTue :(int)repeatWed :(int)repeatThu :(int)repeatFri :(int)repeatSat :(int)hour :(int)minute :(int)tone :(int)index {
    int byte2 = hour;
    int byte3 = minute;
    int byte4 = tone;
    int byte5 = 0x00;
    //set bit 0 to 0|1
    if (repeatSun == 0) {
        byte5 = byte5 | (0 << 0);
    } else {
        byte5 = byte5 | (1 << 0);
    }
    //set bit 1 to 0|1
    if (repeatMon == 0) {
        byte5 = byte5 | (0 << 1);
    } else {
        byte5 = byte5 | (1 << 1);
    }
    //set bit 2 to 0|1
    if (repeatTue == 0) {
        byte5 = byte5 | (0 << 2);
    } else {
        byte5 = byte5 | (1 << 2);
    }
    //set bit 3 to 0|1
    if (repeatWed == 0) {
        byte5 = byte5 | (0 << 3);
    } else {
        byte5 = byte5 | (1 << 3);
    }
    //set bit 4 to 0|1
    if (repeatThu == 0) {
        byte5 = byte5 | (0 << 4);
    } else {
        byte5 = byte5 | (1 << 4);
    }
    //set bit 5 to 0|1
    if (repeatFri == 0) {
        byte5 = byte5 | (0 << 5);
    } else {
        byte5 = byte5 | (1 << 5);
    }
    //set bit 6 to 0|1
    if (repeatSat == 0) {
        byte5 = byte5 | (0 << 6);
    } else {
        byte5 = byte5 | (1 << 6);
    }
    int byte6 = index;
    [self sendSENSSUNFATData:SSBLESENSSUNBODYCLOCKWriteSetting :byte2 :byte3 :byte4 :byte5 :byte6 :peripheral :_rewriteCount];
}

#pragma mark write data to SENSSUNSUPERFAT
- (void)sendSENSSUNSUPERFATTestFatWithSex:(int)sex userID:(int)userID age:(int)age heightCM:(int)heightCM heightInch:(int)heightInch peripheral:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.deviceType.intValue == SSBLESENSSUNSUPERFAT) {
        int byte3 = userID;
        //clear bit 8 to 0
        byte3 = byte3 & 0x7F;
        //set bit 8 to 0|1
        if (sex % 2 == 0) {
            byte3 = byte3 | (0 << 7);//byte3 & 0x7F;
        } else {
            byte3 = byte3 | (1 << 7);//byte3 | 0x80;
        }
        int heightInchHigh = floor(heightInch / 256);
        int heightInchLow = heightInch % 256;
        
        [self sendSENSSUNSUPERFATData:SSBLESENSSUNSUPERFATWriteTestFat :byte3 :age :heightCM :heightInchHigh :heightInchLow :peripheral];
    }
}

- (void)sendSENSSUNSUPERFATTestFat2WithSex:(int)sex userID:(int)userID age:(int)age heightCM:(int)heightCM heightInch:(int)heightInch peripheral:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.deviceType.intValue == SSBLESENSSUNSUPERFAT) {
        int byte3 = userID;
        //clear bit 8 to 0
        byte3 = byte3 & 0x7F;
        //set bit 8 to 0|1
        if (sex % 2 == 0) {
            byte3 = byte3 | (0 << 7);//byte3 & 0x7F;
        } else {
            byte3 = byte3 | (1 << 7);//byte3 | 0x80;
        }
        int heightInchHigh = floor(heightInch / 256);
        int heightInchLow = heightInch % 256;
        
        [self sendSENSSUNSUPERFATData:SSBLESENSSUNSUPERFATWriteTestFat2 :byte3 :age :heightCM :heightInchHigh :heightInchLow :peripheral];
    }
}

- (void)sendSENSSUNSUPERFATData:(int)dataType :(int)byte3 :(int)byte4 :(int)byte5 :(int)byte6 :(int)byte7 :(CBPeripheral *)peripheral {
    if (!peripheral) {
        return;
    }
    
    int checkSum = (dataType + byte3 + byte4 + byte5 + byte6 + byte7) % 256;
    Byte byte[12] = {0xBC, dataType, byte3, byte4, byte5, byte6, byte7, checkSum, 0xD4, 0xC6, 0xC8, 0xD4};
    NSData *data = [NSData dataWithBytes:byte length:12];
    
    [peripheral.readWriteMgr addWriteData:data :dataType :_rewriteCount];
}

#pragma mark write data to SENSSUNGROWTH
- (void)sendSENSSUNGROWTHUserAdd:(int)userNO :(CBPeripheral *)peripheral {
    [self sendSENSSUNGROWTHData:SSBLESENSSUNGROWTHWriteUserAdd :userNO :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :2];
}

- (void)sendSENSSUNGROWTHUserDelete:(int)userNO :(CBPeripheral *)peripheral {
    [self sendSENSSUNGROWTHData:SSBLESENSSUNGROWTHWriteUserDelete :userNO :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :2];
}

- (void)sendSENSSUNGROWTHUserSet:(int)userNO :(CBPeripheral *)peripheral {
    [self sendSENSSUNGROWTHData:SSBLESENSSUNGROWTHWriteUserSet :userNO :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :2];
}

- (void)sendSENSSUNGROWTHSyncDateTime:(CBPeripheral *)peripheral {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    int year = [components year] % 100;
    int order = (int)[calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:date];
    int orderHigh = floor(order / 256);
    int orderLow = (int)order % 256;
    int hour = (int)[components hour];
    int minute = (int)[components minute];
    int second = (int)[components second];
    
    [self sendSENSSUNGROWTHData:SSBLESENSSUNGROWTHWriteSyncDateTime :year :orderHigh :orderLow :hour :minute :second :peripheral :_rewriteCount];
}

- (void)sendSENSSUNGROWTHSyncDataShallow:(int)userNO :(CBPeripheral *)peripheral {
    [self sendSENSSUNGROWTHData:SSBLESENSSUNGROWTHWriteSyncDataShallow :userNO :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :2];
}

- (void)sendSENSSUNGROWTHSyncDataDeep:(int)userNO :(CBPeripheral *)peripheral {
    [self sendSENSSUNGROWTHData:SSBLESENSSUNGROWTHWriteSyncDataDeep :userNO :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :2];
}

- (void)sendSENSSUNGROWTHData:(int)dataType :(int)byte2 :(int)byte3 :(int)byte4 :(int)byte5 :(int)byte6 :(int)byte7 :(CBPeripheral *)peripheral :(NSInteger)maxRewriteCount {
    if (!peripheral) {
        return;
    }
    
    int checkSum = (dataType + byte2 + byte3 + byte4 + byte5 + byte6 + byte7) % 256;
    Byte byte[9] = {0xA5, dataType, byte2, byte3, byte4, byte5, byte6, byte7, checkSum};
    NSData *data = [NSData dataWithBytes:byte length:9];
    
    [peripheral.readWriteMgr addWriteData:data :dataType :maxRewriteCount];
}

#pragma mark write data to SENSSUNFATCLOCK
- (void)sendSENSSUNFATCLOCKSearchHistory:(CBPeripheral *)peripheral {
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteSearchHistory2 :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral :_rewriteCount];
}

- (void)sendSENSSUNFATCLOCKSearchHistoryDeep:(CBPeripheral *)peripheral {
    [self sendSENSSUNFATData:SSBLESENSSUNFATWriteSearchHistory2 :0x32 :0x00 :0x00 :0x00 :0x00 :peripheral :_rewriteCount];
}

#pragma mark write data to SENSSUNPAD
- (void)sendSENSSUNPADBuildWithGram:(int)gram :(CBPeripheral *)peripheral {
    int point = -1;
    int gramHigh = -1;
    int gramLow = -1;
    if (gram == 5000) {
        gram = 5020;
        gramHigh = floor(gram / 256);
        gramLow = (int)gram % 256;
        point = 3;
    } else if (gram == 3000) {
        gram = 3020;
        gramHigh = floor(gram / 256);
        gramLow = (int)gram % 256;
        point = 2;
    } else if (gram == 2000) {
        gram = 2020;
        gramHigh = floor(gram / 256);
        gramLow = (int)gram % 256;
        point = 1;
    } else if (gram == 1000) {
        gram = 1020;
        gramHigh = floor(gram / 256);
        gramLow = (int)gram % 256;
        point = 0;
    }
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteBuild :gramLow :gramHigh :point :0x00 :0x00 :peripheral];
}

- (void)sendSENSSUNPADBatteryLevel:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 0; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteBatteryLevel :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral];
}

- (void)sendSENSSUNPADWaterPlan:(float)water :(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 1; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteWaterPlan ||
                readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    int waterHigh = floor(water / 256);
    int waterLow = (int)water % 256;
    
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteWaterPlan :waterLow :waterHigh :0x00 :0x00 :0x00 :peripheral];
}

- (void)sendSENSSUNPADSyncDateTime:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 0; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteSyncDateTime ||
                readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    int weekday = (int)([components weekday] - 1) * 0x10;
    int order = (int)[calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:date];
    int orderHigh = floor(order / 256) + weekday;
    int orderLow = (int)order % 256;
    
    int hour = (int)[components hour];
    int minute = (int)[components minute];
    int second = (int)[components second];
    
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteSyncDateTime :orderLow :orderHigh :hour :minute :second :peripheral];
}

- (void)sendSENSSUNPADSyncWaterData:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 0; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteSyncWaterData ||
                readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteSyncWaterData :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral];
}

- (void)sendSENSSUNPADDeleteWaterData:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 0; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteDeleteWaterData ||
                readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteDeleteWaterData :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral];
}

- (void)sendSENSSUNPADWeighMode:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 0; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteStandbyMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteWeighMode :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral];
}

- (void)sendSENSSUNPADWeighZero:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 0; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteStandbyMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteWeighZero :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral];
}

- (void)sendSENSSUNPADStandbyMode:(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 0; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteStandbyMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    [self sendSENSSUNPADData:SSBLESENSSUNPADWriteStandbyMode :0x00 :0x00 :0x00 :0x00 :0x00 :peripheral];
}

- (void)sendSENSSUNPADData:(int)dataType :(int)byte2 :(int)byte3 :(int)byte4 :(int)byte5 :(int)byte6 :(CBPeripheral *)peripheral {
    if (!peripheral) {
        return;
    }
    
    int check = (dataType + byte2 + byte3 + byte4 + byte5 + byte6) % 256;
    Byte checkByte = (Byte)0xff & check;
    checkByte = ~checkByte;
    Byte byte[8] = {0xA5, dataType, byte2, byte3, byte4, byte5, byte6, checkByte};
    NSData *data = [NSData dataWithBytes:byte length:8];
    
    [peripheral.readWriteMgr addWriteData:data :dataType :_rewriteCount];
}

- (void)sendSENSSUNPADSetting:(int)startSun :(int)endSun :(int)startMon :(int)endMon :(int)startTue :(int)endTue :(int)startWed :(int)endWed :(int)startThu :(int)endThu :(int)startFri :(int)endFri :(int)startSat :(int)endSat :(CBPeripheral *)peripheral {
    if (peripheral && peripheral.readWriteMgr.writeBuffer.count > 0) {
        NSMutableArray *writeBuffer = peripheral.readWriteMgr.writeBuffer;
        int count = (int)writeBuffer.count;
        for (int i = count - 1; i >= 1; i--) {
            SSBLEReadWriteData *readWriteData = [writeBuffer objectAtIndex:i];
            if (readWriteData.dataType == SSBLESENSSUNPADWriteSetting ||
                readWriteData.dataType == SSBLESENSSUNPADWriteBatteryLevel ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode ||
                readWriteData.dataType == SSBLESENSSUNPADWriteWeighZero) {
                [writeBuffer removeObjectAtIndex:i];
            }
        }
    }
    
    int dataType = SSBLESENSSUNPADWriteSetting;
    Byte byte[16] = {0xA5, dataType, startSun, endSun, startMon, endMon, startTue, endTue, startWed, endWed, startThu, endThu, startFri, endFri, startSat, endSat};
    NSData *data = [NSData dataWithBytes:byte length:16];
    
    [peripheral.readWriteMgr addWriteData:data :dataType :_rewriteCount];
}

#pragma mark write data to SENSSUNTRACK
- (void)sendSENSSUNTRACKTest:(CBPeripheral *)peripheral {
    int dataType = SSBLESENSSUNTRACKWriteTest;
    int checkSum = (dataType + 0x00 + 0x00 + 0x00 + 0x00 + 0x00 + 0x00 + 0x00 + 0x00) % 256;
    Byte byte[11] = {0xAA, dataType, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, checkSum};
    NSData *data = [NSData dataWithBytes:byte length:11];
    
    [peripheral.readWriteMgr addWriteData:data :dataType :_rewriteCount];
}

#pragma mark write data to SENSSUNALI
- (void)sendSENSSUNALITestFatWithSex:(int)sex userID:(int)userID age:(int)age heightCM:(int)heightCM heightInch:(int)heightInch peripheral:(CBPeripheral *)peripheral {
    int byte3 = userID;
    //clear bit 8 to 0
    byte3 = byte3 & 0x7F;
    //set bit 8 to 0|1
    if (sex % 2 == 0) {
        byte3 = byte3 | (0 << 7);//byte3 & 0x7F;
    } else {
        byte3 = byte3 | (1 << 7);//byte3 | 0x80;
    }
    int heightInchHigh = floor(heightInch / 256);
    int heightInchLow = heightInch % 256;
    
    [self sendSENSSUNALIData:SSBLESENSSUNFATWriteTestFat :byte3 :age :heightCM :heightInchHigh :heightInchLow :peripheral :_rewriteCount];
}

- (void)sendSENSSUNALIData:(int)dataType :(int)byte3 :(int)byte4 :(int)byte5 :(int)byte6 :(int)byte7 :(CBPeripheral *)peripheral :(NSInteger)maxRewriteCount {
    int checkSum = (dataType + byte3 + byte4 + byte5 + byte6 + byte7) % 256;
    Byte byte[11] = {0x02, 0x00, 0x08, 0xA5, dataType, byte3, byte4, byte5, byte6, byte7, checkSum};
    NSData *data = [NSData dataWithBytes:byte length:11];
    
    [peripheral.readWriteMgr addWriteData:data :dataType :maxRewriteCount];
}

#pragma mark write data to SENSSUN
- (void)sendSENSSUNGetProductUUID:(CBPeripheral *)peripheral {
    Byte byte[20] = {0x00, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    NSData *data = [NSData dataWithBytes:byte length:20];
    
    [peripheral.readWriteMgr addWriteData:data :SSBLESENSSUNWriteGetProductUUID :_rewriteCount];
}

- (void)sendSENSSUNSyncUserData:(CBPeripheral *)peripheral :(int)number :(int)sex :(int)age :(int)height {
    int heightHigh = height / 256;
    int heightLow = height % 256;
    Byte byte[20] = {0x00, 0xF1, 0x05, number, sex, age, heightHigh, heightLow, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    NSData *data = [NSData dataWithBytes:byte length:20];
    
    [peripheral.readWriteMgr addWriteData:data :SSBLESENSSUNWriteSyncUserData :_rewriteCount];
}

- (void)sendSENSSUNSyncDateTime:(CBPeripheral *)peripheral {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    Byte byte[20] = {0x00, 0xF2, 0x06, [cmps year], [cmps month], [cmps day], [cmps hour], [cmps minute], [cmps second], 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    NSData *data = [NSData dataWithBytes:byte length:20];
    
    [peripheral.readWriteMgr addWriteData:data :SSBLESENSSUNWriteSyncDateTime :_rewriteCount];
}

- (void)sendSENSSUNResetScale:(CBPeripheral *)peripheral {
    Byte byte[20] = {0xA5, 0x5A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    NSData *data = [NSData dataWithBytes:byte length:20];
    
    [peripheral.readWriteMgr addWriteData:data :SSBLESENSSUNWriteResetScale :_rewriteCount];
}

#pragma mark write data to SENSSUNMWS1
- (void)sendSENSSUNMWS1TestFatWithSex:(int)sex :(int)age :(int)height :(CBPeripheral *)peripheral {
    int dataType = 0x0101;
    Byte byte[8] = {0xAA, 0x55, 0x0A, dataType / 256, dataType % 256, height, age, sex};
    int crc16 = [self CRC16:byte :8];
    Byte byte2[11] = {byte[0], byte[1], byte[2], byte[3], byte[4], byte[5], byte[6], byte[7], crc16 / 256, crc16 % 256};
    NSData *data = [NSData dataWithBytes:byte2 length:11];
    
    [peripheral.readWriteMgr addWriteData:data :dataType :_rewriteCount];
}

- (void)sendSENSSUNMWS1Disconnect:(CBPeripheral *)peripheral {
    int dataType = 0x0102;
    Byte byte[5] = {0xAA, 0x55, 0x07, dataType / 256, dataType % 256};
    int crc16 = [self CRC16:byte :5];
    Byte byte2[7] = {byte[0], byte[1], byte[2], byte[3], byte[4], crc16 / 256, crc16 % 256};
    NSData *data = [NSData dataWithBytes:byte2 length:7];
    
    [peripheral.readWriteMgr addWriteData:data :dataType :_rewriteCount];
}

- (int)CRC16:(unsigned char *)buff :(int)length {
    int message;
    unsigned char temp;
    
    message = 0;
    message = ((message^(*buff)) << 8) ^ (*(buff + 1));
    for (int j = 2; j < length; j++) {
        temp = *(buff + j);
        for (int i = 8; i > 0; i--) {
            if ((message & 0x8000) == 0x8000) {
                if ((temp & 0x80) == 0x80) {
                    message = (((message << 1) | 0x01) ^ 0x1021);
                } else {
                    message = ((message << 1) ^ 0x1021);
                }
            } else {
                if ((temp & 0x80) == 0x80) {
                    message = ((message << 1) | 0x01);
                } else {
                    message = (message << 1);
                }
            }
            temp = temp << 1;
        }
    }
    
    return message;
}

#pragma mark write data to SENSSUNFATPIN
- (void)sendSENSSUNBODYPINSyncUserData:(CBPeripheral *)peripheral :(int)operation :(int)number :(int)pin :(int)sex :(int)heightCM :(int)age :(int)sportMode :(NSString *)unitID :(int)bodyMassKG {
    int dataType = 0x01;
    
    pin = round(pin / 1000 * pow(16, 3) + pin % 1000 / 100 * pow(16, 2) + pin % 1000 % 100 / 10 * 16 + pin % 100 % 100 % 10);
    
    int unit = 0;
    if ([unitID isEqualToString:@"kg"]) {
        unit = 0x00;
    } else if ([unitID isEqualToString:@"lb"]) {
        unit = 0x01;
    } else if ([unitID isEqualToString:@"st"]) {
        unit = 0x02;
    }
    
    const int length = 13;
    Byte byte[length] = {0x02, dataType, operation, number, pin / 256, pin % 256, sex, heightCM, age, sportMode, unit, bodyMassKG / 256, bodyMassKG % 256};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNBODYPINSyncHistoryData:(CBPeripheral *)peripheral {
    int dataType = 0x02;
    
    const int length = 4;
    Byte byte[length] = {0x02, dataType, 0x00, 0x0A};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNBODYPINSyncDateTime:(CBPeripheral *)peripheral {
    int dataType = 0x03;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    const int length = 8;
    Byte byte[length] = {0x02, dataType, [cmps year] - 2000, [cmps month], [cmps day], [cmps hour], [cmps minute], [cmps second]};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNBODYPINGetSerialNO:(CBPeripheral *)peripheral {
    int dataType = 0x04;
    
    const int length = 3;
    Byte byte[length] = {0x02, dataType, 0x00};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNBODYPINGetBattery:(CBPeripheral *)peripheral {
    int dataType = 0x05;
    
    const int length = 3;
    Byte byte[length] = {0x02, dataType, 0x00};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNFATPINStopMeasureData:(CBPeripheral *)peripheral {
    int dataType = 0x00;
    
    const int length = 3;
    Byte byte[length] = {0x03, dataType, 0x0A};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNFATPINSyncUserData:(CBPeripheral *)peripheral :(int)operation :(int)number :(int)pin :(int)sex :(int)heightCM :(int)age :(int)sportMode :(NSString *)unitID :(int)bodyMassKG {
    int dataType = 0x01;
    
    pin = round(pin / 1000 * pow(16, 3) + pin % 1000 / 100 * pow(16, 2) + pin % 1000 % 100 / 10 * 16 + pin % 100 % 100 % 10);
    
    int unit = 0;
    if ([unitID isEqualToString:@"kg"]) {
        unit = 0x00;
    } else if ([unitID isEqualToString:@"lb"]) {
        unit = 0x01;
    } else if ([unitID isEqualToString:@"st"]) {
        unit = 0x02;
    }
    
    const int length = 13;
    Byte byte[length] = {0x03, dataType, operation, number, pin / 256, pin % 256, sex, heightCM, age, sportMode, unit, bodyMassKG / 256, bodyMassKG % 256};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNFATPINSyncHistoryData:(CBPeripheral *)peripheral :(int)pin {
    int dataType = 0x02;
    
    pin = round(pin / 1000 * pow(16, 3) + pin % 1000 / 100 * pow(16, 2) + pin % 1000 % 100 / 10 * 16 + pin % 100 % 100 % 10);
    
    const int length = 5;
    Byte byte[length] = {0x03, dataType, pin / 256, pin % 256, 0xAA};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNFATPINSyncDateTime:(CBPeripheral *)peripheral {
    int dataType = 0x03;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    const int length = 8;
    Byte byte[length] = {0x03, dataType, [cmps year] - 2000, [cmps month], [cmps day], [cmps hour], [cmps minute], [cmps second]};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNFATPINGetSerialNO:(CBPeripheral *)peripheral {
    int dataType = 0x04;
    
    const int length = 3;
    Byte byte[length] = {0x03, dataType, 0x00};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :0];
}

- (void)sendSENSSUNFATPINGetBattery:(CBPeripheral *)peripheral {
    int dataType = 0x05;
    
    const int length = 3;
    Byte byte[length] = {0x03, dataType, 0x00};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNFATPINResetScale:(CBPeripheral *)peripheral {
    int dataType = 0x06;
    
    const int length = 2;
    Byte byte[length] = {0x03, dataType};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNFATPINGetUserData:(CBPeripheral *)peripheral {
    int dataType = 0x07;
    
    const int length = 2;
    Byte byte[length] = {0x03, dataType};
    
    [self sendSENSSUNFATPINData:peripheral :dataType :[NSData dataWithBytes:byte length:length] :_rewriteCount];
}

- (void)sendSENSSUNFATPINData:(CBPeripheral *)peripheral :(int)dataType :(NSData *)data :(NSInteger)maxRewriteCount {
    NSMutableData *writeData = [NSMutableData data];
    Byte byte[5] = {0x10, 0x00, 0x00, 0xC5, data.length + 6};
    [writeData appendBytes:byte length:5];
    
    [writeData appendData:data];
    
    const unsigned char *dataBuffer = (const unsigned char *)[writeData bytes];
    int checkSum = 0;
    for (int i = 4; i < writeData.length; i++) {
        checkSum += dataBuffer[i];
    }
    checkSum &= 0xFF;
    
    Byte byte2[1] = {checkSum};
    [writeData appendBytes:byte2 length:1];
    
    [peripheral.readWriteMgr addWriteData:writeData :dataType :maxRewriteCount];
}

@end
