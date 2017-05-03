#import "SSBLEReadWriteManager.h"


@interface SSBLEReadWriteManager () {
    NSMutableData *_readBuffer;
    NSMutableArray *_writeBuffer;
    
    BOOL _ifSyncDate;
    BOOL _ifSyncTime;
    DataTypeEnum _receiveDataType;
    BodyMeasure *_lastMeasure;
    BodyMeasure *_measure;
    NSMutableDictionary *_historyDictionary;
    
    BOOL _ifOutputLog;
}
@end


@implementation SSBLEReadWriteManager

@synthesize notifyCharacteristic = _notifyCharacteristic;
@synthesize writeCharacteristic = _writeCharacteristic;
@synthesize readBuffer = _readBuffer;
@synthesize writeBuffer = _writeBuffer;
@synthesize readDateTime = _readDateTime;

- (id)init {
    self = [super init];
    if (self) {
        _notifyCharacteristic = nil;
        _writeCharacteristic = nil;
        _readBuffer = [NSMutableData data];
        _writeBuffer = [NSMutableArray array];
        _readDateTime = -1;
        
        _ifSyncDate = NO;
        _ifSyncTime = NO;
        _receiveDataType = DataTypeNone;
        _lastMeasure = nil;
        _measure = nil;
        _historyDictionary = nil;
        
        _ifOutputLog = NO;
#ifdef DEBUG
        _ifOutputLog = YES;
#endif
    }
    return self;
}

- (void)addWriteData:(NSData *)data :(int)dataType :(int)seq :(NSInteger)maxRewriteCount {
    SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
    readWriteData.data = data;
    readWriteData.dataType = dataType;
    readWriteData.seq = seq;
    readWriteData.maxRewriteCount = maxRewriteCount;
    readWriteData.writeDateTime = -1;
    readWriteData.ifReply = NO;
    @synchronized(_writeBuffer) {
        [_writeBuffer addObject:readWriteData];
    }
}

- (void)processDidReceivedDelegate:(SSBLEDevice *)device peripheral:(CBPeripheral *)peripheral :(BodyMeasure *)value :(NSMutableArray *)values :(NSMutableArray *)delegates {
    id target = nil;
    for (NSInteger i = delegates.count - 1; i >= 0; i--) {
        target = [delegates objectAtIndex:i];
        if ([target respondsToSelector:@selector(peripheralDidReceived:value:values:)]) {
            [target peripheralDidReceived:peripheral value:value values:values];
        }
    }
}

- (void)processReceivedValueDelegate:(SSBLEDevice *)device peripheral:(CBPeripheral *)peripheral :(BodyMeasure *)value :(NSMutableArray *)delegates {
    [self processDidReceivedDelegate:device peripheral:peripheral :value :nil :delegates];
}

- (BOOL)processDidReceivedTestFatDelegate:(SSBLEDevice *)device peripheral:(CBPeripheral *)peripheral :(NSMutableArray *)delegates {
    BOOL flag = NO;
    
    if (_measure.bodyMassKG >= 0 && _measure.bodyMassLB >= 0) {
        if (_measure.bodyFatPercentage >= 0 ||
            _measure.visceralFat >= 0 ||
            _measure.protein >= 0 ||
            _measure.bodyAge >= 0 ||
            _measure.muscle >= 0 ||
            _measure.kcal >= 0 ||
            _measure.biologicalSexID >= 0 ||
            _measure.heightCM >= 0 ||
            ![_measure.recordDate isEqualToString:@""] ||
            _measure.dayInterval >= 0 ||
            _measure.dataType == DataTypeTestFatError) {
            if (_measure.dataType != DataTypeTestFatError) {
                _measure.dataType = DataTypeTestFat;
            }
            [self processDidReceivedDelegate:device peripheral:peripheral :_measure :nil :delegates];
            _lastMeasure = _measure;
            _receiveDataType = DataTypeNone;
            flag = YES;
            
        } else {
            _measure.dataType = DataTypeWeigh;
            [self processDidReceivedDelegate:device peripheral:peripheral :_measure :nil :delegates];
            _lastMeasure = _measure;
        }
    }
    
    _measure = [[BodyMeasure alloc] init];
    
    return flag;
}

- (BOOL)processDidReceivedSearchHistoryDelegate:(SSBLEDevice *)device peripheral:(CBPeripheral *)peripheral :(NSMutableArray *)delegates {
    BOOL flag = NO;
    if (_measure.bodyMassKG >= 0 && _measure.bodyMassLB >= 0) {
        if (_measure.number != -1) {
            _measure.dataType = DataTypeHistory;
            if (_historyDictionary) {
                [_historyDictionary setObject:_measure forKey:@(_measure.number)];
            }
            [self processDidReceivedDelegate:device peripheral:peripheral :_measure :nil :delegates];
            _lastMeasure = _measure;
            flag = YES;
        }
    }
    
    _measure = [[BodyMeasure alloc] init];
    
    return flag;
}

- (void)processDidWriteDataDelegate:(SSBLEDevice *)device peripheral:(CBPeripheral *)peripheral :(SSBLEReadWriteData *)data :(NSMutableArray *)delegates {
    data.data = nil;
    id target = nil;
    for (NSInteger i = delegates.count - 1; i >= 0; i--) {
        target = [delegates objectAtIndex:i];
        if ([target respondsToSelector:@selector(peripheralDidWrite:data:)]) {
            [target peripheralDidWrite:peripheral data:data];
        }
    }
}

- (void)processDidAllowWrite:(CBPeripheral *)peripheral :(NSMutableArray *)delegates {
    id target = nil;
    for (NSInteger i = delegates.count - 1; i >= 0; i--) {
        target = [delegates objectAtIndex:i];
        if ([target respondsToSelector:@selector(peripheralDidAllowWrite:)]) {
            [target peripheralDidAllowWrite:peripheral];
        }
    }
}

- (void)readData:(NSData *)data :(SSBLEDevice *)device :(CBPeripheral *)peripheral :(NSMutableArray *)targetDelegates :(SSBLEDeviceManager *)deviceMgr {
    if (device.deviceType == SSBLESENSSUNSCALEBODY) {
        [_readBuffer appendData:data];
        
        const unsigned char *dataBuffer = (const unsigned char *)[_readBuffer bytes];
        int byte0 = dataBuffer[0];
        int byte1 = dataBuffer[1];
        int byte2 = dataBuffer[2];
        int byte3 = dataBuffer[3];
        int byte4 = dataBuffer[4];
        
        NSString *guideCode = [NSString stringWithFormat:@"%02X%02X%02X%02X", byte0, byte1, byte2, byte3];
        if (![guideCode isEqualToString:@"100000C5"]) {
            _readBuffer = [NSMutableData data];
            return;
        }
        
        int length = byte4;
        if (length > _readBuffer.length) {
            return;
        }
        
        NSMutableDictionary *values = [SSBLEDevice parseData:_readBuffer deviceType:device.deviceType model:peripheral.model protocol:(int)strtoull([peripheral.protocol UTF8String], 0, 16)];
        _readBuffer = [NSMutableData data];
        
        SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
        readWriteData.data = data;
        readWriteData.readValues = values;
        
        id target = nil;
        for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
            target = [targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidReceived:data:datas:)]) {
                [target peripheralDidReceived:peripheral data:readWriteData datas:nil];
            }
        }
        
        int productCode = [values[@"productCode"] intValue];
        int dataType = [values[@"dataType"] intValue];
        
        if (_writeBuffer.count > 0) {
            SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
            if ((readWriteData.dataType == 0x01 && dataType == 0x81) ||
                (readWriteData.dataType == 0x02 && dataType == 0x82) ||
                (readWriteData.dataType == 0x03 && dataType == 0x83) ||
                (readWriteData.dataType == 0x06 && dataType == 0x86) ||
                (readWriteData.dataType == 0x07 && dataType == 0x87)) {
                readWriteData.ifReply = YES;
                if (_ifOutputLog) {
                    NSLog(@"reply:%d", readWriteData.dataType);
                }
                [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
            }
        }
        
        if (productCode == 0x03 && dataType == 0x80) {
            int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
            int bodyMassLB = [[values objectForKey:@"bodyMassLB"] intValue];
            NSString *unit = [values objectForKey:@"unit"];
            int ifStable = [[values objectForKey:@"ifStable"] intValue];
            
            BodyMeasure *measure = [[BodyMeasure alloc] init];
            measure.bodyMassKG = bodyMassKG;
            measure.bodyMassLB = bodyMassLB;
            measure.ifStable = ((ifStable == 0xAA) ? YES : NO);
            measure.unitID = unit;
            measure.dataType = DataTypeWeigh;
            [self processDidReceivedDelegate:device peripheral:peripheral :measure :nil :targetDelegates];
            
        } else if (productCode == 0x03 && dataType == 0x82) {
            int finish = [[values objectForKey:@"finish"] intValue];
            if (finish == 1) {
                int readCount = 0;
                int index = 1;
                NSMutableArray *values = [NSMutableArray array];
                while (readCount < _historyDictionary.count) {
                    BodyMeasure *temp = nil;
                    while (!temp) {
                        temp = [_historyDictionary objectForKey:@(index)];
                        index += 1;
                    }
                    [values addObject:temp];
                    readCount += 1;
                }
                [self processDidReceivedDelegate:device peripheral:peripheral :nil :values :targetDelegates];
                _historyDictionary = nil;
                return;
            }
            
            int number = [[values objectForKey:@"number"] intValue];
            int pin = [[values objectForKey:@"pin"] intValue];
            int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
            NSString *unit = [values objectForKey:@"unit"];
            int fat = [[values objectForKey:@"fat"] intValue];
            int hydro = [[values objectForKey:@"hydro"] intValue];
            int muscle = [[values objectForKey:@"muscle"] intValue];
            int bone = [[values objectForKey:@"bone"] intValue];
            int kcal = [[values objectForKey:@"kcal"] intValue];
            int interval = [[values objectForKey:@"interval"] intValue];
            
            BodyMeasure *measure = [[BodyMeasure alloc] init];
            measure.number = number;
            measure.deviceUserID = pin;
            measure.bodyMassKG = bodyMassKG;
            //measure.bodyMassLB = bodyMassLB;
            measure.ifStable = YES;
            measure.unitID = unit;
            if (number == 0) {
                measure.dataType = DataTypeTestFat;
            } else {
                measure.dataType = DataTypeHistory;
            }
            
            measure.bodyFatPercentage = fat;
            measure.hydro = hydro;
            measure.muscle = muscle;
            measure.bone = bone;
            measure.kcal = kcal;
            
            NSDate *date = [[NSDate date] dateByAddingTimeInterval:interval];
            NSDateFormatter *fmater = [[NSDateFormatter alloc] init];
            fmater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            fmater.timeZone = [NSTimeZone localTimeZone];
            fmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            measure.recordDate = [fmater stringFromDate:date];
            
            [self processDidReceivedDelegate:device peripheral:peripheral :measure :nil :targetDelegates];
            if (number == 0) {
                return;
            }
            if (!_historyDictionary) {
                _historyDictionary = [NSMutableDictionary dictionary];
            }
            [_historyDictionary setObject:measure forKey:@(number)];
            
        }
        
    } else if (device.deviceType == SSBLESENSSUNSCALEKITCHEN) {
        if (!data || data.length < 10) {
            return;
        }
        
        NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType model:peripheral.model protocol:(int)strtoull([peripheral.protocol UTF8String], 0, 16)];
        if (!values || values.count == 0) {
            return;
        }
        
        SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
        readWriteData.data = data;
        readWriteData.readValues = values;
        
        id target = nil;
        for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
            target = [targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidReceived:data:datas:)]) {
                [target peripheralDidReceived:peripheral data:readWriteData datas:nil];
            }
        }
        
    }
}

@end