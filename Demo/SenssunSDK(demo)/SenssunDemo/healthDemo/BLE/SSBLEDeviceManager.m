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
    NSDictionary *_typeToDeviceMap;
    
    NSInteger _rewriteCount;
    NSInteger _maxConnectCount;
    int _rssiMin;
    int _bleMode;
    NSMutableDictionary *_serialNOToNeedConnectMap;
    NSMutableDictionary *_serialNOToConnectingPeripheralMap;
    NSMutableDictionary *_serialNOToPeripheralMap;
    
    NSInteger _scanDateTime;
    NSInteger _readRSSIDateTime;
    NSTimer *_timerRefresh;
    
    BOOL _ifOutputLog;
}
@end


@implementation SSBLEDeviceManager

@synthesize serialNOToPeripheralMap = _serialNOToPeripheralMap;

- (void)dealloc {
    _centralMgr.delegate = nil;
    [self disconnect];
}

- (id)initWithDeviceTypes:(NSArray *)deviceTypes rssiMin:(int)rssiMin {
    self = [super init];
    if (self) {
        self.ifTestPeripheral = NO;
        
        _centralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _targetDelegates = [NSMutableArray array];
        _typeToDeviceMap = [SSBLEDevice getDevicesMap:deviceTypes];
        
        _rewriteCount = NSIntegerMax;
        _maxConnectCount = 2;
        _rssiMin = rssiMin;
        _bleMode = SSBLEModeConnectManual;
        _serialNOToNeedConnectMap = [NSMutableDictionary dictionary];
        _serialNOToConnectingPeripheralMap = [NSMutableDictionary dictionary];
        _serialNOToPeripheralMap = [NSMutableDictionary dictionary];
        
        _readRSSIDateTime = -1;
        _timerRefresh = nil;
        
        _ifOutputLog = NO;
#ifdef DEBUG
        _ifOutputLog = YES;
#endif
        
    }
    return self;
}

- (NSInteger)peripheralsCount {
    return _serialNOToPeripheralMap.count;
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
    for (NSInteger i = _serialNOToConnectingPeripheralMap.count - 1; i >= 0; i--) {
        peripheral = [_serialNOToConnectingPeripheralMap.allValues objectAtIndex:i];
        if (!peripheral.connectDateTime) {
            continue;
        }
        if (interval - peripheral.connectDateTime.integerValue >= kTimeoutReconnect) {
            if (![self ifConnectable:peripheral.deviceType]) {
                [_centralMgr cancelPeripheralConnection:peripheral];
                continue;
            }
            
            if (peripheral.maxReConnectCount.integerValue <= 0) {
                if ([_serialNOToNeedConnectMap objectForKey:peripheral.serialNO]) {
                    [_serialNOToNeedConnectMap removeObjectForKey:peripheral.serialNO];
                }
                [_centralMgr cancelPeripheralConnection:peripheral];
                if (_ifOutputLog) {
                    NSLog(@"connect time out %li:%li", (long)peripheral.connectDateTime, (long)interval);
                }
                continue;
            }
            
            if (_ifOutputLog) {
                NSLog(@"reconnect: %@", peripheral.serialNO);
            }
            peripheral.connectDateTime = @(interval);
            peripheral.maxReConnectCount = @(peripheral.maxReConnectCount.integerValue - 1);
        }
    }
    
    for (NSInteger i = _serialNOToPeripheralMap.count - 1; i >= 0; i--) {
        peripheral = [_serialNOToPeripheralMap.allValues objectAtIndex:i];
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
- (BOOL)ifConnectable:(NSNumber *)deviceType {
    BOOL connectable = NO;
    if (_maxConnectCount != -1 && [_serialNOToPeripheralMap count] >= _maxConnectCount) {
        return connectable;
    }
    
    if (deviceType) {
        SSBLEDevice *device = [_typeToDeviceMap objectForKey:deviceType];
        if (device.maxConnectCount != -1 && [device.serialNOToPeripheralMap count] >= device.maxConnectCount) {
            return connectable;
        }
        connectable = YES;

    } else {
        for (SSBLEDevice *device in _typeToDeviceMap.allValues) {
            if (device.maxConnectCount == -1 || [device.serialNOToPeripheralMap count] < device.maxConnectCount) {
                connectable = YES;
                break;
            }
        }
    }
    
    return connectable;
}

- (void)stopScan {
    _scanDateTime = -1;
    [_centralMgr stopScan];
    if (_ifOutputLog) {
        NSLog(@"stop scan");
    }
}

- (void)reset {
    [_serialNOToNeedConnectMap removeAllObjects];
    [_serialNOToConnectingPeripheralMap removeAllObjects];
    [_serialNOToPeripheralMap removeAllObjects];
    for (SSBLEDevice *device in _typeToDeviceMap.allValues) {
        [device.serialNOToPeripheralMap removeAllObjects];
    }
}

- (void)scanPeripherals {
    [self scanPeripherals:SSBLEModeNone];
}

- (void)scanPeripherals:(int)bleMode {
    if (bleMode != SSBLEModeNone) {
        _bleMode = bleMode;
        if (![self ifConnectable:nil]) {
            return;
        }
    }
    if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    [self stopScan];
    NSMutableDictionary *serviceIDs = [NSMutableDictionary dictionary];
    for (SSBLEDevice *device in _typeToDeviceMap.allValues) {
        [serviceIDs addEntriesFromDictionary:device.shortServiceUUIDs];
    }
    [_centralMgr scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
    _scanDateTime = [[NSDate date] timeIntervalSince1970];
    [self startTimer];
    if (_ifOutputLog) {
        NSLog(@"scan");
    }
}

- (void)connectWithSerialNOs:(NSArray *)serialNOs {
    _bleMode = SSBLEModeConnectManual;
    for (NSString *serialNO in serialNOs) {
        [_serialNOToNeedConnectMap setObject:serialNO forKey:serialNO];
    }
    
    if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    [self scanPeripherals:_bleMode];
}

- (void)disconnectWithSerialNOs:(NSArray *)serialNOs {
    for (NSString *serialNO in serialNOs) {
        if ([_serialNOToNeedConnectMap objectForKey:serialNO]) {
            [_serialNOToNeedConnectMap removeObjectForKey:serialNO];
        }
        
        CBPeripheral *peripheral = nil;
        for (NSInteger i = _serialNOToConnectingPeripheralMap.count - 1; i >= 0; i--) {
            peripheral = [_serialNOToConnectingPeripheralMap.allValues objectAtIndex:i];
            if (peripheral.serialNO && [peripheral.serialNO isEqualToString:serialNO]) {
                [_serialNOToConnectingPeripheralMap removeObjectForKey:peripheral.serialNO];
                [_centralMgr cancelPeripheralConnection:peripheral];
                return;
            }
        }
        
        for (NSInteger i = _serialNOToPeripheralMap.count - 1; i >= 0; i--) {
            peripheral = [_serialNOToPeripheralMap.allValues objectAtIndex:i];
            if (peripheral.serialNO && [peripheral.serialNO isEqualToString:serialNO]) {
                peripheral.ifExpectDisconnect = @(YES);
                [self cancelConnectPeripheral:peripheral];
                return;
            }
        }
    }
}

- (void)connect {
    _bleMode = SSBLEModeConnectAuto;
    if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (![self ifConnectable:nil]) {
        return;
    }
    
    [self scanPeripherals:_bleMode];
}

- (void)disconnect {
    [self stopTimer];
    
    NSInteger count = _serialNOToConnectingPeripheralMap.allValues.count;
    CBPeripheral *peripheral = nil;
    for (NSInteger i = count - 1; i >= 0; i--) {
        peripheral = [_serialNOToConnectingPeripheralMap.allValues objectAtIndex:i];
        [_serialNOToConnectingPeripheralMap removeObjectForKey:peripheral.serialNO];
        [_centralMgr cancelPeripheralConnection:peripheral];
    }
    
    count = _serialNOToPeripheralMap.allValues.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        peripheral = [_serialNOToPeripheralMap.allValues objectAtIndex:i];
        peripheral.ifExpectDisconnect = @(YES);
        [self cancelConnectPeripheral:peripheral];
    }
    
    [self reset];
}

- (void)resetPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = nil;
    peripheral.connectDateTime = nil;
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
    [_serialNOToConnectingPeripheralMap setObject:peripheral forKey:peripheral.serialNO];
    [self resetPeripheral:peripheral];
    peripheral.seq = @(-1);
    peripheral.maxReConnectCount = @(maxReconnectCount);
    peripheral.connectDateTime = @(interval);
    [_centralMgr connectPeripheral:peripheral options:nil];
    [self startTimer];
    if (_ifOutputLog) {
        NSLog(@"connect: %@\r\nserial NO:%@\r\ndevice Type:%d", peripheral.deviceID, peripheral.serialNO, peripheral.deviceType.intValue);
    }
}

- (void)cancelConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = nil;
    [_centralMgr cancelPeripheralConnection:peripheral];
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
        for (CBPeripheral *peripheral in _serialNOToPeripheralMap.allValues) {
            id target = nil;
            for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
                target = [_targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidDisconnect:)]) {
                    [target peripheralDidDisconnect:peripheral];
                }
            }
        }
        [_serialNOToConnectingPeripheralMap removeAllObjects];
        [_serialNOToPeripheralMap removeAllObjects];
        for (SSBLEDevice *device in _typeToDeviceMap.allValues) {
            [device.serialNOToPeripheralMap removeAllObjects];
        }
        return;
    } else if (_centralMgr.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (_centralMgr.state == CBCentralManagerStatePoweredOn) {
        [self scanPeripherals:_bleMode];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (RSSI.intValue < _rssiMin || RSSI.intValue == 127) {
        return;
    }
    
    if (peripheral.state != CBPeripheralStateDisconnected) {
        return;
    }
    
    NSData *data = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if ([peripheral.name isEqualToString:@"ID107 HR"]) {
        NSString *serialNO = [SSBLEDevice dataToHexString:data];
        if ([serialNO isEqualToString:@"11000100EA1E158A92ABF6"] ||
            [serialNO isEqualToString:@"11000200EA1E158A92ABF7"]) {
            Byte byte[11] = {0x47, 0x17, 0x01, 0x01, 0x17, 0xAA, 0x00, 0x00, 0x00, 0x00, 0x00};
            data = [NSData dataWithBytes:byte length:11];
        }
    }
    if (!data || data.length < 11) {
        return;
    }
    NSString *serialNO = [SSBLEDevice dataToHexString:data];
    NSDictionary *values = [SSBLEDevice parseSerialNO:serialNO];
    if (!values) {
        return;
    }
    
    NSString *manufacturerID = values[@"manufacturerID"];
    NSString *protocol = values[@"protocol"];
    NSString *model = values[@"model"];
    int deviceType = [SSBLEDevice getDeviceTypeByModel:model];
    
    if (RSSI.intValue != 127) {
        peripheral.newRSSI = RSSI;
    }
    peripheral.serialNO = serialNO;
    peripheral.manufacturerID = manufacturerID;
    peripheral.protocol = protocol;
    peripheral.model = model;
    peripheral.deviceType = @(deviceType);
    
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
    
    if (![self ifConnectable:peripheral.deviceType]) {
        return;
    }
    
    if ([_serialNOToConnectingPeripheralMap objectForKey:peripheral.serialNO] ||
        [_serialNOToPeripheralMap objectForKey:peripheral.serialNO]) {
        return;
    }
    
    if (_bleMode == SSBLEModeConnectAuto ||
        (_bleMode == SSBLEModeConnectManual && [_serialNOToNeedConnectMap objectForKey:peripheral.serialNO])) {
        [self connectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    if (![self ifConnectable:peripheral.deviceType]) {
        [_centralMgr cancelPeripheralConnection:peripheral];
        return;
    }
    
    [self stopTimer];
    SSBLEReadWriteManager *readWriteMgr = [[SSBLEReadWriteManager alloc] init];
    peripheral.readWriteMgr = readWriteMgr;
    peripheral.connectDateTime = nil;
    [_serialNOToConnectingPeripheralMap removeObjectForKey:peripheral.serialNO];
    [_serialNOToPeripheralMap setObject:peripheral forKey:peripheral.serialNO];
    SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
    [device.serialNOToPeripheralMap setObject:peripheral forKey:peripheral.serialNO];
    [self startTimer];
    id target = nil;
    for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
        target = [_targetDelegates objectAtIndex:i];
        if ([target respondsToSelector:@selector(peripheralDidConnect:)]) {
            [target peripheralDidConnect:peripheral];
        }
    }
    
    peripheral.delegate = self;
    [peripheral discoverServices:device.serviceUUIDs.allKeys];
    
    if (![self ifConnectable:nil]) {
        [self stopScan];
    }
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
    if ([_serialNOToConnectingPeripheralMap objectForKey:peripheral.serialNO]) {
        if (_timerRefresh && _timerRefresh.isValid) {
            [self stopTimer];
            [_serialNOToConnectingPeripheralMap removeObjectForKey:peripheral.serialNO];
            [self startTimer];
        } else {
            [_serialNOToConnectingPeripheralMap removeObjectForKey:peripheral.serialNO];
        }
        id target = nil;
        for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
            target = [_targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidFailToConnect:)]) {
                [target peripheralDidFailToConnect:peripheral];
            }
        }
        
        [self scanPeripherals:_bleMode];
    }
    
    if ([_serialNOToPeripheralMap objectForKey:peripheral.serialNO]) {
        if (_timerRefresh && _timerRefresh.isValid) {
            [self stopTimer];
            [_serialNOToPeripheralMap removeObjectForKey:peripheral.serialNO];
            SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
            [device.serialNOToPeripheralMap removeObjectForKey:peripheral.serialNO];
            [self startTimer];
        } else {
            [_serialNOToPeripheralMap removeObjectForKey:peripheral.serialNO];
            SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
            [device.serialNOToPeripheralMap removeObjectForKey:peripheral.serialNO];
        }
        id target = nil;
        for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
            target = [_targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidDisconnect:)]) {
                [target peripheralDidDisconnect:peripheral];
            }
        }
        
        if (error && !peripheral.ifExpectDisconnect) {
            [self scanPeripherals:_bleMode];
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
    
    if (!peripheral.readWriteMgr.writeCharacteristic) {
        return;
    }
    
    id target = nil;
    for (NSInteger i = _targetDelegates.count - 1; i >= 0; i--) {
        target = [_targetDelegates objectAtIndex:i];
        if ([target respondsToSelector:@selector(peripheralDidAllowWrite:)]) {
            [target peripheralDidAllowWrite:peripheral];
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
    
    SSBLEDevice *device = [_typeToDeviceMap objectForKey:peripheral.deviceType];
    [peripheral.readWriteMgr readData:characteristic.value :device :peripheral :_targetDelegates :self];
}

#pragma mark write data
- (void)writeData:(NSData *)data :(CBPeripheral *)peripheral {
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
    for (NSInteger i = _serialNOToPeripheralMap.count - 1; i >= 0; i--) {
        CBPeripheral *peripheral = [_serialNOToPeripheralMap.allValues objectAtIndex:i];
        if (peripheral.state == CBPeripheralStateConnected) {
            [peripheral readRSSI];
        }
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    peripheral.newRSSI = peripheral.RSSI;
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    peripheral.newRSSI = RSSI;
}

#pragma mark write data to SENSSUNSCALEBODY
- (void)sendSENSSUNSCALEBODYStopMeasureData:(CBPeripheral *)peripheral {
    int dataType = 0x00;
    
    const int length = 3;
    Byte byte[length] = {0x03, dataType, 0x0A};
    
    [self sendSENSSUNSCALEBODYData:peripheral :dataType :[NSData dataWithBytes:byte length:length]];
}

- (void)sendSENSSUNSCALEBODYSyncUserData:(CBPeripheral *)peripheral :(int)operation :(int)number :(int)pin :(int)sex :(int)heightCM :(int)age :(int)sportMode :(NSString *)unitID :(int)bodyMassKG {
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
    
    [self sendSENSSUNSCALEBODYData:peripheral :dataType :[NSData dataWithBytes:byte length:length]];
}

- (void)sendSENSSUNSCALEBODYSyncHistoryData:(CBPeripheral *)peripheral :(int)pin {
    int dataType = 0x02;
    
    pin = round(pin / 1000 * pow(16, 3) + pin % 1000 / 100 * pow(16, 2) + pin % 1000 % 100 / 10 * 16 + pin % 100 % 100 % 10);
    
    const int length = 5;
    Byte byte[length] = {0x03, dataType, pin / 256, pin % 256, 0x00};
    
    [self sendSENSSUNSCALEBODYData:peripheral :dataType :[NSData dataWithBytes:byte length:length]];
}

- (void)sendSENSSUNSCALEBODYSyncDateTime:(CBPeripheral *)peripheral {
    int dataType = 0x03;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    const int length = 8;
    Byte byte[length] = {0x03, dataType, [cmps year] - 2000, [cmps month], [cmps day], [cmps hour], [cmps minute], [cmps second]};
    
    [self sendSENSSUNSCALEBODYData:peripheral :dataType :[NSData dataWithBytes:byte length:length]];
}

- (void)sendSENSSUNSCALEBODYGetSerialNO:(CBPeripheral *)peripheral {
    int dataType = 0x04;
    
    const int length = 3;
    Byte byte[length] = {0x03, dataType, 0x00};
    
    [self sendSENSSUNSCALEBODYData:peripheral :dataType :[NSData dataWithBytes:byte length:length]];
}

- (void)sendSENSSUNSCALEBODYGetBattery:(CBPeripheral *)peripheral {
    int dataType = 0x05;
    
    const int length = 3;
    Byte byte[length] = {0x03, dataType, 0x00};
    
    [self sendSENSSUNSCALEBODYData:peripheral :dataType :[NSData dataWithBytes:byte length:length]];
}

- (void)sendSENSSUNSCALEBODYResetScale:(CBPeripheral *)peripheral {
    int dataType = 0x06;
    
    const int length = 2;
    Byte byte[length] = {0x03, dataType};
    
    [self sendSENSSUNSCALEBODYData:peripheral :dataType :[NSData dataWithBytes:byte length:length]];
}

- (void)sendSENSSUNSCALEBODYGetUserData:(CBPeripheral *)peripheral {
    int dataType = 0x07;
    
    const int length = 2;
    Byte byte[length] = {0x03, dataType};
    
    [self sendSENSSUNSCALEBODYData:peripheral :dataType :[NSData dataWithBytes:byte length:length]];
}

- (void)sendSENSSUNSCALEBODYData:(CBPeripheral *)peripheral :(int)dataType :(NSData *)data {
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
    
    peripheral.seq = @(peripheral.seq.intValue + 1);
    [peripheral.readWriteMgr addWriteData:writeData :dataType :peripheral.seq.intValue :_rewriteCount];
}

@end