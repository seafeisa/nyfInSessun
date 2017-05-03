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
        _ifOutputLog = NO;
#endif
    }
    return self;
}

- (void)addWriteData:(NSData *)data :(int)dataType :(NSInteger)maxRewriteCount {
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    NSInteger length = data.length;
    
    @synchronized(_writeBuffer) {
        for (SSBLEReadWriteData *readWriteData in _writeBuffer) {
            if (readWriteData.dataType == dataType && readWriteData.data.length == length) {
                const unsigned char *dataBuffer2 = (const unsigned char *)[readWriteData.data bytes];
                BOOL flag = NO;
                for (NSInteger i = 0; i < length; i++) {
                    if (dataBuffer[i] != dataBuffer2[i]) {
                        flag = YES;
                        break;
                    }
                }
                if (!flag) {
                    return;
                }
                return;
            }
        }
    }
    
    SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
    readWriteData.data = data;
    readWriteData.dataType = dataType;
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
    
    if (_measure && _measure.bodyMassKG >= 0 && _measure.bodyMassLB >= 0) {
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
    if (_measure && _measure.bodyMassKG >= 0 && _measure.bodyMassLB >= 0) {
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
    if (device.deviceType == SSBLESENSSUNFAT ||
        device.deviceType == SSBLESENSSUNHEART ||
        device.deviceType == SSBLESENSSUNSUPERFAT ||
        device.deviceType == SSBLESENSSUNBODY ||
        device.deviceType == SSBLESENSSUNBODYCLOCK ||
        device.deviceType == SSBLESENSSUNEQi99 ||
        device.deviceType == SSBLESENSSUNEQi912 ||
        device.deviceType == SSBLESENSSUNFATCLOCK ||
        device.deviceType == SSBLESENSSUNJOINTOWN ||
        device.deviceType == SSBLESENSSUNLETVB1) {

        if (!data || data.length < 8) {
            return;
        }
        
        NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType];
        if (!values || values.count == 0) {
            return;
        }
        
        NSString *heartRateString = [values objectForKey:@"heartRate"];
        int productCode = [[values objectForKey:@"productCode"] intValue];
        if (heartRateString) {
            int heartRate = [heartRateString intValue];
            int hco = [[values objectForKey:@"hco"] intValue];
            int hci = [[values objectForKey:@"hci"] intValue];
            int tpr = [[values objectForKey:@"tpr"] intValue];
            int hac = [[values objectForKey:@"hac"] intValue];
            
            BodyMeasure *measure = nil;
            if (productCode == 0x51) {
                measure = [[BodyMeasure alloc] init];
                measure.dataType = DataTypeHeartRate;
                measure.heartRate = heartRate;
                measure.hco = hco;
                measure.hci = hci;
                measure.tpr = tpr;
                measure.hac = hac;
                [self processReceivedValueDelegate:device peripheral:peripheral :measure :targetDelegates];
                return;
            }
            
            if (productCode == 0x53) {
                _measure.heartRate = heartRate;
                _measure.hco = hco;
                _measure.hci = hci;
                _measure.tpr = tpr;
                _measure.hac = hac;
                return;
            }
        }
        
        int dataType = [[values objectForKey:@"dataType"] intValue];
        if (dataType == 0xA0 || dataType == 0xAA ||
            dataType == 0x10 || dataType == 0x1A ||
            dataType == 0x20 || dataType == 0x2A ||
            dataType == 0x30 || dataType == 0x3A) {
            int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
            int bodyMassLB = [[values objectForKey:@"bodyMassLB"] intValue];
            NSString *unitID = [values objectForKey:@"unitID"];
            int number = [[values objectForKey:@"productCode"] intValue];
            
            if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
            } else {
                [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
            }
            
            _measure.bodyMassKG = bodyMassKG;
            _measure.bodyMassLB = bodyMassLB;
            _measure.ifStable = ((dataType == 0xAA || dataType == 0x1A || dataType == 0x2A || dataType == 0x3A) ? YES : NO);
            _measure.unitID = unitID;
            
            if (number <= 0x32) {
                _measure.dataType = DataTypeHistory;
                _measure.number = number;
            }
            
            if (_receiveDataType != DataTypeHistory &&
                _receiveDataType != DataTypeTestFat &&
                _measure.number > 0x32 &&
                !(_lastMeasure && _lastMeasure.dataType == DataTypeTestFat && _lastMeasure.bodyMassKG == bodyMassKG)) {
                _measure.dataType = DataTypeWeigh;
                [self processReceivedValueDelegate:device peripheral:peripheral :_measure :targetDelegates];
                _lastMeasure = _measure;
            }
            
        } else if (dataType == 0xB0) {
            int fat = [[values objectForKey:@"fat"] intValue];
            int hydro = [[values objectForKey:@"hydro"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            int number = -1;
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
                _measure.number = number2;
            }
            
            _measure.bodyFatPercentage = fat;
            _measure.hydro = hydro;
            
        } else if (dataType == 0xB1) {
            int visceralFat = [[values objectForKey:@"visceralFat"] intValue];
            int cellHydro = [[values objectForKey:@"cellHydro"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            int number = -1;
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
                _measure.number = number2;
            }
            
            _measure.visceralFat = visceralFat;
            _measure.cellHydro = cellHydro;
            
        } else if (dataType == 0xB2) {
            int leanBodyMass = [[values objectForKey:@"leanBodyMass"] intValue];
            int protein = [[values objectForKey:@"protein"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            int number = -1;
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
                _measure.number = number2;
            }
            
            _measure.leanBodyMass = leanBodyMass;
            _measure.protein = protein;
            
        } else if (dataType == 0xB3) {
            int bodyAge = [[values objectForKey:@"bodyAge"] intValue];
            int healthScore = [[values objectForKey:@"healthScore"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            int number = -1;
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
                _measure.number = number2;
            }
            
            _measure.bodyAge = bodyAge;
            _measure.healthScore = healthScore;
            
        } else if (dataType == 0xC0) {
            int muscle = [[values objectForKey:@"muscle"] intValue];
            int bone = [[values objectForKey:@"bone"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            int number = -1;
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
                _measure.number = number2;
            }
            
            _measure.muscle = muscle;
            _measure.bone = bone;
            
        } else if (dataType == 0xD0) {
            int kcal = [[values objectForKey:@"kcal"] intValue];
            int bmi = [[values objectForKey:@"bmi"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            int number = -1;
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
                _measure.number = number2;
            }
            
            _measure.kcal = kcal;
            _measure.bodyMassIndex = bmi;
            
        } else if (dataType == 0xE0) {
            int userID = [[values objectForKey:@"userID"] intValue];
            int number = [[values objectForKey:@"number"] intValue];
            int sex = [[values objectForKey:@"sex"] intValue];
            int age = [[values objectForKey:@"age"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
            }
            
            _measure.deviceUserID = userID;
            _measure.biologicalSexID = sex;
            _measure.age = age;
            _measure.number = number;
            
        } else if (dataType == 0xE1) {
            int heightCM = [[values objectForKey:@"heightCM"] intValue];
            int heightIN = [[values objectForKey:@"heightIN"] intValue];
            int number = [[values objectForKey:@"number"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
            }
            
            _measure.heightCM = heightCM;
            _measure.heightIN = heightIN;
            _measure.number = number;
            
        } else if (dataType == 0xE2) {
            int year = [[values objectForKey:@"year"] intValue];
            int day = [[values objectForKey:@"day"] intValue];
            int number = [[values objectForKey:@"number"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            NSString *startDateString = [NSString stringWithFormat:@"%d-01-01", (int)year];
            NSDateFormatter *fmater = [[NSDateFormatter alloc] init];
            fmater.dateFormat = @"yyyy-MM-dd";
            NSDate *startDate = [fmater dateFromString:startDateString];
            NSDate *date = [startDate dateByAddingTimeInterval:(day - 1) * 24 * 3600];
            
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
            }
            
            _measure.recordDate = [fmater stringFromDate:date];
            _measure.number = number;
            
        } else if (dataType == 0xE3) {
            int hour = [[values objectForKey:@"hour"] intValue];
            int minute = [[values objectForKey:@"minute"] intValue];
            int second = [[values objectForKey:@"second"] intValue];
            int number = [[values objectForKey:@"number"] intValue];
            int number2 = [[values objectForKey:@"productCode"] intValue];
            
            NSTimeInterval interval = hour * 3600 + minute * 60 + second;
            
            if (number2 <= 0x32) {
                if (number2 != _measure.number) {
                    if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                        [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
                    } else {
                        [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
                    }
                }
                number = number2;
                _measure.dataType = DataTypeHistory;
            }
            
            _measure.dayInterval = interval;
            _measure.number = number;
            
        } else if (dataType == 0xF0) {
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceivedAllHistoryData:)]) {
                    [target peripheralDidReceivedAllHistoryData:peripheral];
                }
            }
            if (_receiveDataType != DataTypeHistory) {
                return;
            }
            if (_receiveDataType == DataTypeHistory || _measure.dataType == DataTypeHistory) {
                [self processDidReceivedSearchHistoryDelegate:device peripheral:peripheral :targetDelegates];
            } else {
                [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
            }
            _measure = nil;
            _receiveDataType = DataTypeNone;
            
            int readCount = 0;
            int index = 0;
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
            
        } else if (dataType == 0xBE) {
            _measure.dataType = DataTypeTestFatError;
            [self processDidReceivedTestFatDelegate:device peripheral:peripheral :targetDelegates];
        /*
        } else if (dataType == 0xFF) {
            SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
            //readWriteData.data = data;
            readWriteData.readValues = values;
            
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:data:datas:)]) {
                    [target peripheralDidReceived:peripheral data:readWriteData datas:nil];
                }
            }
        */
        } else if (dataType == 0x00) {
            int reply = [[values objectForKey:@"reply"] intValue];
            if (_ifOutputLog) {
                NSLog(@"reply:%d", reply);
            }
            if (reply == SSBLESENSSUNFATWriteTestFat ||
                reply == SSBLESENSSUNSUPERFATWriteTestFat) {
                _receiveDataType = DataTypeTestFat;
                _measure = [[BodyMeasure alloc] init];
                
            } else if (reply == SSBLESENSSUNFATWriteSearchHistory ||
                       reply == SSBLESENSSUNFATWriteSearchHistory2) {
                _receiveDataType = DataTypeHistory;
                _measure = [[BodyMeasure alloc] init];
                _historyDictionary = [NSMutableDictionary dictionary];
                
            } else if (reply == SSBLESENSSUNFATWriteSyncDate) {
                if (!_ifSyncDate) {
                    _ifSyncDate = YES;
                }
                
            } else if (reply == SSBLESENSSUNFATWriteSyncTime) {
                if (!_ifSyncTime) {
                    _ifSyncTime = YES;
                    [self processDidAllowWrite:peripheral :targetDelegates];
                }
            }
            
            if (_writeBuffer.count > 0) {
                SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
                if (readWriteData.dataType == reply) {
                    readWriteData.ifReply = YES;
                    if (reply == SSBLESENSSUNBODYCLOCKWriteSetting) {
                        int value1 = [[values objectForKey:@"value1"] intValue];
                        readWriteData.readValues = @{@"number": @(value1)};
                    }
                    [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
                }
            }

        }

    } else if (device.deviceType == SSBLESENSSUNGROWTH) {
        [_readBuffer appendData:data];
        if (_readBuffer.length < 9) {
            return;
        }
        
        NSData *data = (NSData *)_readBuffer;
        _readBuffer = [NSMutableData data];
        NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType];
        if (!values || values.count == 0) {
            return;
        }
        
        int dataType = [[values objectForKey:@"dataType"] intValue];
        if (dataType == 0xA5) {
            _lastMeasure = _measure;
            
            _measure = [[BodyMeasure alloc] init];
            _measure.dataType = DataTypeWeigh;
            int overload = [[values objectForKey:@"overload"] intValue];
            if (overload == 1) {
                _measure.overLoad = YES;
            } else {
                _measure.overLoad = NO;
                
                int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
                int bodyMassLB = [[values objectForKey:@"bodyMassLB"] intValue];
                int ifStable = [[values objectForKey:@"ifStable"] intValue];
                NSString *unitID = [values objectForKey:@"unitID"];
                int sign = [[values objectForKey:@"sign"] intValue];
                int heightCM = [[values objectForKey:@"heightCM"] intValue];
                int userID = [[values objectForKey:@"userID"] intValue];
                
                _measure.bodyMassKG = (sign == 0 ? bodyMassKG : -bodyMassKG);
                _measure.bodyMassLB = (sign == 0 ? bodyMassLB : -bodyMassLB);
                _measure.ifStable = (ifStable == 0xAA ? YES : NO);
                _measure.unitID = unitID;
                _measure.heightCM = heightCM;
                _measure.deviceUserID = userID;
                [self processDidReceivedDelegate:device peripheral:peripheral :_measure :nil :targetDelegates];
                
            }
            
        } else if (dataType == 0x75) {
            int dataNO = [[values objectForKey:@"dataNO"] intValue];
            int dataCount = [[values objectForKey:@"dataCount"] intValue];
            if ([_historyDictionary objectForKey:@(dataNO)] && _historyDictionary.count == dataCount) {
                return;
            }
            
            int year = [[values objectForKey:@"year"] intValue];
            int day = [[values objectForKey:@"day"] intValue];
            int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
            int heightCM = [[values objectForKey:@"heightCM"] intValue];
            int userID = [[values objectForKey:@"userID"] intValue];
            
            NSString *startDateString = [NSString stringWithFormat:@"%d-01-01", (int)year];
            NSDateFormatter *fmater = [[NSDateFormatter alloc] init];
            fmater.dateFormat = @"yyyy-MM-dd";
            NSDate *startDate = [fmater dateFromString:startDateString];
            NSDate *date = [startDate dateByAddingTimeInterval:(day - 1) * 24 * 3600];
            if ([date compare:[NSDate date]] == NSOrderedDescending) {
                NSString *lastYearDateString = [NSString stringWithFormat:@"%d-01-01", (int)year - 1];
                NSDate *lastYearStartDate = [fmater dateFromString:lastYearDateString];
                date = [lastYearStartDate dateByAddingTimeInterval:(day - 1) * 24 * 3600];
            }
            
            _lastMeasure = nil;
            _measure = [[BodyMeasure alloc] init];
            _measure.dataType = DataTypeHistory;
            _measure.recordDate = [fmater stringFromDate:date];
            _measure.number = dataNO;
            _measure.deviceUserID = userID;
            _measure.bodyMassKG = bodyMassKG;
            _measure.heightCM = heightCM;
            
            if (!_historyDictionary) {
                _historyDictionary = [NSMutableDictionary dictionary];
            }
            [_historyDictionary setObject:_measure forKey:@(_measure.number)];
            [self processDidReceivedDelegate:device peripheral:peripheral :_measure :nil :targetDelegates];
            if (_historyDictionary.count == dataCount) {
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
            }
            
        } else if (dataType == SSBLESENSSUNGROWTHWriteUserAdd ||
                   dataType == SSBLESENSSUNGROWTHWriteUserDelete ||
                   dataType == SSBLESENSSUNGROWTHWriteUserSet ||
                   dataType == SSBLESENSSUNGROWTHWriteSyncDateTime ||
                   dataType == SSBLESENSSUNGROWTHWriteSyncDataShallow ||
                   dataType == SSBLESENSSUNGROWTHWriteSyncDataDeep) {
            if (_writeBuffer.count > 0) {
                SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
                if (readWriteData.dataType == dataType) {
                    const unsigned char *dataBuffer = (const unsigned char *)[readWriteData.data bytes];
                    int byte1Source = dataBuffer[1];
                    int byte2Source = dataBuffer[2];
                    int byte3Source = dataBuffer[3];
                    int byte4Source = dataBuffer[4];
                    int byte5Source = dataBuffer[5];
                    int byte6Source = dataBuffer[6];
                    int byte7Source = dataBuffer[7];
                    int byte8Source = dataBuffer[8];
                    
                    int byte2 = [[values objectForKey:@"byte2"] intValue];
                    int byte3 = [[values objectForKey:@"byte3"] intValue];
                    int byte4 = [[values objectForKey:@"byte4"] intValue];
                    int byte5 = [[values objectForKey:@"byte5"] intValue];
                    int byte6 = [[values objectForKey:@"byte6"] intValue];
                    int byte7 = [[values objectForKey:@"byte7"] intValue];
                    int byte8 = [[values objectForKey:@"byte8"] intValue];
                    
                    if (byte1Source == dataType &&
                        byte2Source == byte2 &&
                        byte3Source == byte3 &&
                        byte4Source == byte4 &&
                        byte5Source == byte5 &&
                        byte6Source == byte6 &&
                        byte7Source == byte7 &&
                        byte8Source == byte8) {
                        readWriteData.ifReply = YES;
                        readWriteData.data = nil;
                        readWriteData.readValues = nil;
                        [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
                        if (dataType == SSBLESENSSUNGROWTHWriteSyncDateTime) {
                            [self processDidAllowWrite:peripheral :targetDelegates];
                        }
                    }
                }
            }
            
        }
        
    } else if (device.deviceType == SSBLESENSSUNFOOD) {
        if (!data || data.length < 10) {
            return;
        }
        
        NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:SSBLESENSSUNFOOD];
        if (!values || values.count == 0) {
            return;
        }
        
        SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
        //readWriteData.data = data;
        readWriteData.readValues = values;
        
        id target = nil;
        for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
            target = [targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidReceived:data:datas:)]) {
                [target peripheralDidReceived:peripheral data:readWriteData datas:nil];
            }
        }
        
    } else if (device.deviceType == SSBLESENSSUNPAD) {
        if (!data || data.length < 16) {
            return;
        }
        
        NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType];
        if (!values || values.count == 0) {
            return;
        }

        int dataType = [[values objectForKey:@"dataType"] intValue];
        if (_writeBuffer.count > 0) {
            SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
            if (readWriteData.dataType == dataType) {
                if (readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode && readWriteData.replyCount < 3) {
                    readWriteData.replyCount += 1;
                } else {
                    readWriteData.ifReply = YES;
                    if (_ifOutputLog) {
                        NSLog(@"reply:%d", readWriteData.dataType);
                    }
                    [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
                }
            }
        }
        
        SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
        //readWriteData.data = data;
        readWriteData.readValues = values;
        
        if (dataType == SSBLESENSSUNPADReadSyncDateTimeReply) {
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidAllowWrite:)]) {
                    [target peripheralDidAllowWrite:peripheral];
                }
            }

        } else if (dataType == SSBLESENSSUNPADReadSyncWaterData) {
            int finish = [[values objectForKey:@"finish"] intValue];
            int count = -1;
            if (finish != 1) {
                NSNumber *number = [values objectForKey:@"number"];
                count = [[values objectForKey:@"count"] intValue];
                if (!_historyDictionary) {
                    _historyDictionary = [NSMutableDictionary dictionary];
                }
                if (![_historyDictionary objectForKey:number]) {
                    [_historyDictionary setObject:values forKey:number];
                }
            }
            
            NSMutableArray *waters = [NSMutableArray array];
            if (_historyDictionary.count == count || finish == 1) {
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
                NSString *lastYearStartDateString = [NSString stringWithFormat:@"%d-01-01 00:00:00", (int)components.year - 1];
                NSString *startDateString = [NSString stringWithFormat:@"%d-01-01 00:00:00", (int)components.year];
                
                NSDateFormatter *fmater = [[NSDateFormatter alloc] init];
                fmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSDate *lastYearStartDate = [fmater dateFromString:lastYearStartDateString];
                NSDate *startDate = [fmater dateFromString:startDateString];
                HistoryWater *waterData = nil;
                for (NSMutableDictionary *values in _historyDictionary.allValues) {
                    NSInteger day = [[values objectForKey:@"day"] integerValue];
                    NSInteger hour = [[values objectForKey:@"hour"] integerValue];
                    NSInteger minute = [[values objectForKey:@"minute"] integerValue];
                    NSInteger second = [[values objectForKey:@"second"] integerValue];
                    NSInteger water = [[values objectForKey:@"water"] integerValue];
                    
                    NSDate *recordDate = [startDate dateByAddingTimeInterval:(day - 1) * 24 * 3600 + hour * 3600 + minute * 60 + second];
                    if ([recordDate compare:[NSDate date]] == NSOrderedDescending) {
                        recordDate = [lastYearStartDate dateByAddingTimeInterval:(day - 1) * 24 * 3600 + hour * 3600 + minute * 60 + second];
                    }
                    waterData = [[HistoryWater alloc] init];
                    waterData.recordDate = [recordDate timeIntervalSince1970];
                    waterData.water = (double)water;
                    [waters addObject:waterData];
                }
            }
            
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:water:waters:)]) {
                    [target peripheralDidReceived:peripheral water:nil waters:waters];
                }
            }
            _historyDictionary = nil;

        } else if (dataType == SSBLESENSSUNPADReadSyncWaterData2) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
            NSString *lastYearStartDateString = [NSString stringWithFormat:@"%d-01-01 00:00:00", (int)components.year - 1];
            NSString *startDateString = [NSString stringWithFormat:@"%d-01-01 00:00:00", (int)components.year];
            
            NSDateFormatter *fmater = [[NSDateFormatter alloc] init];
            fmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDate *lastYearStartDate = [fmater dateFromString:lastYearStartDateString];
            NSDate *startDate = [fmater dateFromString:startDateString];
            HistoryWater *waterData = nil;
            NSInteger day = [[values objectForKey:@"day"] integerValue];
            NSInteger hour = [[values objectForKey:@"hour"] integerValue];
            NSInteger minute = [[values objectForKey:@"minute"] integerValue];
            NSInteger second = [[values objectForKey:@"second"] integerValue];
            NSInteger water = [[values objectForKey:@"water"] integerValue];
            
            NSDate *recordDate = [startDate dateByAddingTimeInterval:(day - 1) * 24 * 3600 + hour * 3600 + minute * 60 + second];
            if ([recordDate compare:[NSDate date]] == NSOrderedDescending) {
                recordDate = [lastYearStartDate dateByAddingTimeInterval:(day - 1) * 24 * 3600 + hour * 3600 + minute * 60 + second];
            }
            waterData = [[HistoryWater alloc] init];
            waterData.recordDate = [recordDate timeIntervalSince1970];
            waterData.water = (double)water;
            
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:water:waters:)]) {
                    [target peripheralDidReceived:peripheral water:waterData waters:nil];
                }
                if ([target respondsToSelector:@selector(peripheralDidReceived:data:datas:)]) {
                    [target peripheralDidReceived:peripheral data:readWriteData datas:nil];
                }
            }

        } else if (dataType == SSBLESENSSUNPADReadDeleteWaterDataReply ||
            dataType == SSBLESENSSUNPADReadWaterPlanReply ||
            dataType == SSBLESENSSUNPADReadSettingReply ||
            dataType == SSBLESENSSUNPADReadSyncWaterDataReply ||
            dataType == SSBLESENSSUNPADReadMassData ||
            dataType == SSBLESENSSUNPADReadWeighZeroReply ||
            dataType == SSBLESENSSUNPADReadStandbyModeReply ||
            dataType == SSBLESENSSUNPADReadBuildReply ||
            dataType == SSBLESENSSUNPADReadBuildData ||
            dataType == SSBLESENSSUNPADReadBatteryLevelReply) {
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:data:datas:)]) {
                    [target peripheralDidReceived:peripheral data:readWriteData datas:nil];
                }
            }
            
        }
        
    } else if (device.deviceType == SSBLESENSSUNTRACK) {
        if (!data || data.length < 5) {
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:wrongData:)]) {
                    [target peripheralDidReceived:peripheral wrongData:data];
                }
            }
            return;
        }
        
        NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType];
        if (!values || values.count == 0) {
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:wrongData:)]) {
                    [target peripheralDidReceived:peripheral wrongData:data];
                }
            }
            return;
        }
        
        if (_ifOutputLog) {
            NSLog(@"%@", values);
        }
        int reply = [[values objectForKey:@"reply"] intValue];
        if (_writeBuffer.count > 0) {
            SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
            if (readWriteData.dataType == reply) {
                readWriteData.ifReply = YES;
                readWriteData.readValues = values;
                [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
            }
        }
        
    } else if (device.deviceType == SSBLESENSSUN) {
        if (data.length == 8) {
            NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType];
            //int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
            
            SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
            readWriteData.data = data;
            readWriteData.readValues = values;
            
            int msgType = [[values objectForKey:@"msgType"] intValue];
            if (msgType == 0xA5) {
                msgType = 0x5A;
            }
            if (_ifOutputLog) {
                NSLog(@"received reply:%d", msgType);
            }
            if (_writeBuffer.count > 0) {
                SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
                if (readWriteData.dataType == msgType) {
                    readWriteData.ifReply = YES;
                    readWriteData.readValues = values;
                    [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
                }
            }
            
            //BodyMeasure *measure = [[BodyMeasure alloc] init];
            //measure.bodyMassKG = bodyMassKG;
            //measure.unitID = @"kg";
            //[self processReceivedValueDelegate:device peripheral:peripheral :readWriteData :nil :targetDelegates];
            return;
        }
        
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int byte0 = dataBuffer[0];
        int byte2 = dataBuffer[2];
        
        int temp0 = 0;
        int temp2 = 0;
        if (_readBuffer && _readBuffer.length > 0) {
            const unsigned char *dataBuffer2 = (const unsigned char *)[_readBuffer bytes];
            temp0 = dataBuffer2[0];
            temp2 = dataBuffer2[2];
        }
        
        if (byte0 != 0 && (_readBuffer.length == 0 || byte0 != temp0 + 1)) {
            id target = nil;
            if (_readBuffer && _readBuffer.length > 0) {
                for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                    target = [targetDelegates objectAtIndex:i];
                    if ([target respondsToSelector:@selector(peripheralDidReceived:wrongData:)]) {
                        [target peripheralDidReceived:peripheral wrongData:_readBuffer];
                    }
                }
            }
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:wrongData:)]) {
                    [target peripheralDidReceived:peripheral wrongData:data];
                }
            }
            _readBuffer = [NSMutableData data];
            return;
        }
        
        if (byte0 == 0) {
            temp2 = byte2;
            [_readBuffer appendData:data];
        } else {
            data = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
            Byte byte[1] = {byte0};
            [_readBuffer replaceBytesInRange:NSMakeRange(0, 1) withBytes:byte];
            [_readBuffer appendData:data];
        }
        
        if (temp2 <= _readBuffer.length - 3) {
            data = _readBuffer;
            _readBuffer = [NSMutableData data];
            NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType];
            if (!values || values.count == 0) {
                id target = nil;
                for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                    target = [targetDelegates objectAtIndex:i];
                    if ([target respondsToSelector:@selector(peripheralDidReceived:wrongData:)]) {
                        [target peripheralDidReceived:peripheral wrongData:data];
                    }
                }
                return;
            }
            
            SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
            readWriteData.data = data;
            readWriteData.readValues = values;
            
            int msgType = [[values objectForKey:@"msgType"] intValue];
            if (msgType == 0xA5) {
                msgType = 0x5A;
            }
            if (_ifOutputLog) {
                NSLog(@"received reply:%d", msgType);
            }
            if (_writeBuffer.count > 0) {
                SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
                if (readWriteData.dataType == msgType) {
                    readWriteData.ifReply = YES;
                    readWriteData.readValues = values;
                    [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
                }
            }
            
            if (msgType == 0x04) {
                int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
                int fat = [[values objectForKey:@"fat"] intValue];
                int hydro = [[values objectForKey:@"hydro"] intValue];
                int muscle = [[values objectForKey:@"muscle"] intValue];
                int bone = [[values objectForKey:@"bone"] intValue];
                int kcal = [[values objectForKey:@"kcal"] intValue];
                
                BodyMeasure *measure = [[BodyMeasure alloc] init];
                measure.dataType = DataTypeTestFat;
                measure.bodyMassKG = bodyMassKG;
                measure.ifStable = YES;
                measure.unitID = @"kg";
                measure.bodyFatPercentage = fat;
                measure.hydro = hydro;
                measure.muscle = muscle;
                measure.bone = bone;
                measure.kcal = kcal;
                [self processDidReceivedDelegate:device peripheral:peripheral :_measure :nil :targetDelegates];
            }
            
        }
        
    } else if (device.deviceType == SSBLESENSSUNMWS1) {
        if (!data) {
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:wrongData:)]) {
                    [target peripheralDidReceived:peripheral wrongData:data];
                }
            }
            return;
        }
        
        NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType];
        if (!values || values.count == 0) {
            id target = nil;
            for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
                target = [targetDelegates objectAtIndex:i];
                if ([target respondsToSelector:@selector(peripheralDidReceived:wrongData:)]) {
                    [target peripheralDidReceived:peripheral wrongData:data];
                }
            }
            return;
        }
        
        SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
        readWriteData.data = data;
        readWriteData.readValues = values;
        
        int dataType = [[values objectForKey:@"dataType"] intValue];
        if (_ifOutputLog) {
            NSLog(@"received reply:%d", dataType);
        }
        
        if (_writeBuffer.count > 0) {
            SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
            if (readWriteData.dataType == 0x0101 && dataType == 0x0100) {
                readWriteData.ifReply = YES;
                readWriteData.readValues = values;
                [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
                return;
            }
        }
        
        if (dataType == 0x01FE) {
            int bodyMass = [[values objectForKey:@"bodyMass"] intValue];
            NSString *unit = [values objectForKey:@"unit"];
            
            BodyMeasure *measure = [[BodyMeasure alloc] init];
            measure.dataType = DataTypeWeigh;
            measure.bodyMassKG = bodyMass;
            measure.ifStable = (dataType == 0xAA ? YES : NO);
            measure.unitID = unit;
            
            [self processDidReceivedDelegate:device peripheral:peripheral :measure :nil :targetDelegates];
            
        } else if (dataType == 0x01FD) {
            int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
            int fat = [[values objectForKey:@"fat"] intValue];
            int hydro = [[values objectForKey:@"hydro"] intValue];
            int muscle = [[values objectForKey:@"muscle"] intValue];
            int bone = [[values objectForKey:@"bone"] intValue];
            int kcal = [[values objectForKey:@"kcal"] intValue];
            
            BodyMeasure *measure = [[BodyMeasure alloc] init];
            measure.dataType = DataTypeTestFat;
            measure.bodyMassKG = bodyMassKG;
            measure.ifStable = YES;
            measure.unitID = @"kg";
            measure.bodyFatPercentage = fat;
            measure.hydro = hydro;
            measure.muscle = muscle;
            measure.bone = bone;
            measure.kcal = kcal;
            
            [self processDidReceivedDelegate:device peripheral:peripheral :measure :nil :targetDelegates];
            
        }
        
    } else if (device.deviceType == SSBLESENSSUNALI) {
        [_readBuffer appendData:data];
        
        if (_readBuffer.length > 0) {
            const unsigned char *dataBuffer = (const unsigned char *)[_readBuffer bytes];
            int byte0 = dataBuffer[0];
            int byte1 = dataBuffer[1];
            int byte2 = dataBuffer[2];
            
            int protocol = byte0;
            int length = byte1 * 256 + byte2;

            if (protocol == 0x01) {
                if (_readBuffer.length < length + 3) {
                    return;
                }
                
                data = _readBuffer;
                _readBuffer = [NSMutableData data];
                if (data.length > length + 3) {
                    NSData *newData = [_readBuffer subdataWithRange:NSMakeRange(length + 3, _readBuffer.length - length - 3)];
                    while (newData && newData.length > 0) {
                        dataBuffer = (const unsigned char *)[newData bytes];
                        int byte0 = dataBuffer[0];
                        if (byte0 != 0x01) {
                            if (newData.length > 1) {
                                newData = [newData subdataWithRange:NSMakeRange(1, newData.length - 1)];
                            } else {
                                newData = nil;
                            }
                        }
                    }
                    
                    if (newData && newData.length > 0) {
                        [_readBuffer appendData:newData];
                    }
                    
                }
                
                NSMutableDictionary *values = [SSBLEDevice parseData:data deviceType:device.deviceType];
                if (!values || values.count == 0) {
                    return;
                }
                
                int bodyMassKG = [[values objectForKey:@"bodyMassKG"] intValue];
                int hydro = [[values objectForKey:@"hydro"] intValue];
                int muscle = [[values objectForKey:@"muscle"] intValue];
                int bone = [[values objectForKey:@"bone"] intValue];
                int kcal = [[values objectForKey:@"kcal"] intValue];

                BodyMeasure *measure = [[BodyMeasure alloc] init];
                measure.dataType = DataTypeTestFat;
                measure.bodyMassKG = bodyMassKG;
                measure.hydro = hydro;
                measure.muscle = muscle;
                measure.bone = bone;
                measure.kcal = kcal;
                [self processDidReceivedDelegate:device peripheral:peripheral :measure :nil :targetDelegates];

                /*
                int dataType = [[values objectForKey:@"dataType"] intValue];
                if (_writeBuffer.count > 0) {
                    SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
                    if (readWriteData.dataType == dataType) {
                        if (readWriteData.dataType == SSBLESENSSUNPADWriteWeighMode && readWriteData.replyCount < 3) {
                            readWriteData.replyCount += 1;
                        } else {
                            readWriteData.ifReply = YES;
                            if (_ifOutputLog) {
                                NSLog(@"reply:%d", readWriteData.dataType);
                            }
                            [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
                        }
                    }
                }
                
                SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
                //readWriteData.data = data;
                readWriteData.readValues = values;
                */
                
            }
        }

    } else if (device.deviceType == SSBLESENSSUNFATPIN) {
        if (_readBuffer.length == 0 && data.length < 8) {
            return;
        }
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
        
        NSMutableDictionary *values = [SSBLEDevice parseData:_readBuffer deviceType:device.deviceType];
        _readBuffer = [NSMutableData data];
        
        SSBLEReadWriteData *readWriteData = [[SSBLEReadWriteData alloc] init];
        readWriteData.data = data;
        readWriteData.readValues = values;
        
        int productCode = [values[@"productCode"] intValue];
        int dataType = [values[@"dataType"] intValue];
        if (_writeBuffer.count > 0) {
            SSBLEReadWriteData *readWriteData = [_writeBuffer objectAtIndex:0];
            if (productCode == 0x03) {
                if ((readWriteData.dataType == 0x01 && dataType == 0x81) ||
                    (readWriteData.dataType == 0x02 && dataType == 0x82) ||
                    (readWriteData.dataType == 0x83 && dataType == 0x03) ||
                    (readWriteData.dataType == 0x04 && dataType == 0x84) ||
                    (readWriteData.dataType == 0x05 && dataType == 0x85) ||
                    (readWriteData.dataType == 0x06 && dataType == 0x86) ||
                    (readWriteData.dataType == 0x07 && dataType == 0x87)) {
                    readWriteData.ifReply = YES;
                    readWriteData.readValues = values;
                    [self processDidWriteDataDelegate:device peripheral:peripheral :readWriteData :targetDelegates];
                }
            }
        }

        id target = nil;
        for (NSInteger i = targetDelegates.count - 1; i >= 0; i--) {
            target = [targetDelegates objectAtIndex:i];
            if ([target respondsToSelector:@selector(peripheralDidReceived:data:datas:)]) {
                [target peripheralDidReceived:peripheral data:readWriteData datas:nil];
            }
        }
        
        if (productCode == 0x03 && dataType == 0x83) {
            [deviceMgr sendSENSSUNFATPINSyncDateTime:peripheral];
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
            measure.bodyMassLB = round(((bodyMassKG * 144475) >> 16) / 10.0f);
            measure.ifStable = YES;
            measure.unitID = unit;
            measure.dataType = DataTypeTestFat;
            
            measure.bodyFatPercentage = fat;
            measure.hydro = hydro;
            measure.muscle = muscle;
            measure.bone = bone;
            measure.kcal = kcal;
            
            NSDate *date = [[NSDate date] dateByAddingTimeInterval:interval];
            NSDateFormatter *fmater = [[NSDateFormatter alloc] init];
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
        
    }
}

@end