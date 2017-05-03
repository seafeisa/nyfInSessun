#import "SSBLEDevice.h"


@implementation SSBLEDevice

@synthesize deviceType = _deviceType;
@synthesize serviceMap = _serviceMap;
@synthesize maxConnectCount = _maxConnectCount;
@synthesize serialNOToPeripheralMap = _serialNOToPeripheralMap;

- (id)initWithDeviceType:(SSBLEDeviceTypeEnum)deviceType serviceMap:(NSDictionary *)serviceMap maxConnectCount:(int)maxConnectCount {
    self = [super init];
    if (self) {
        _deviceType = deviceType;
        _serviceMap = serviceMap;
        _maxConnectCount = maxConnectCount;
        _serialNOToPeripheralMap = [NSMutableDictionary dictionaryWithCapacity:maxConnectCount];
    }
    return self;
}

- (NSDictionary *)shortServiceUUIDs {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    for (NSArray *services in _serviceMap.allValues) {
        if ([services count] > 0) {
            NSString *shortUUID = services[0];
            if ([shortUUID isEqualToString:@""]) {
                continue;
            }
            [values setObject:services forKey:[CBUUID UUIDWithString:shortUUID]];
        }
    }
    return values;
}

- (NSDictionary *)serviceUUIDs {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    for (NSString *serviceUUID in _serviceMap.allKeys) {
        [values setObject:_serviceMap[serviceUUID] forKey:[CBUUID UUIDWithString:serviceUUID]];
    }
    return values;
}

#pragma mark parse/construct data
+ (NSString *)dataToHexString:(NSData *)data {
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

+ (NSMutableDictionary *)parseData:(NSData *)data deviceType:(SSBLEDeviceTypeEnum)type model:(NSString *)model protocol:(int)protocol {
    NSMutableDictionary *values = nil;
    
    if (type == SSBLESENSSUNSCALEBODY) {
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int byte4 = dataBuffer[4];
        int byte5 = dataBuffer[5];
        int byte6 = dataBuffer[6];
        
        int length = byte4;
        int checkSum = dataBuffer[length - 1];
        int check = 0;
        for (int i = 4; i < length - 1; i++) {
            check += dataBuffer[i];
        }
        check &= 0xFF;
        if (check != checkSum) {
            return values;
        }
        
        int productCode = byte5;
        int dataType = byte6;
        values = [NSMutableDictionary dictionary];
        [values setObject:@(productCode) forKey:@"productCode"];
        if (productCode == 0x02) {
            [values setObject:@(dataType) forKey:@"dataType"];
            if (dataType == 0x80) {
                int byte7 = dataBuffer[7];
                int byte8 = dataBuffer[8];
                int byte9 = dataBuffer[9];
                int byte10 = dataBuffer[10];
                int byte11 = dataBuffer[11];
                
                int bodyMassKG = byte7 * 256 + byte8;
                int bodyMassLB = byte9 * 256 + byte10;
                
                [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
                [values setObject:@(bodyMassLB) forKey:@"bodyMassLB"];
                if (byte11 == 0x01) {
                    [values setObject:@"kg" forKey:@"unit"];
                } else if (byte11 == 0x02) {
                    [values setObject:@"lb" forKey:@"unit"];
                } else if (byte11 == 0x03) {
                    [values setObject:@"st" forKey:@"unit"];
                }
                
            } else if (dataType == 0x81) {
                int byte7 = dataBuffer[7];
                
                int status = byte7;
                [values setObject:@(status) forKey:@"status"];
                
            } else if (dataType == 0x82) {
                int byte7 = dataBuffer[7];
                int byte8 = dataBuffer[8];
                int byte9 = dataBuffer[9];
                int byte10 = dataBuffer[10];
                int byte11 = dataBuffer[11];
                int byte12 = dataBuffer[12];
                int byte13 = dataBuffer[13];
                int byte14 = dataBuffer[14];
                
                int number = byte7;
                int bodyMassKG = byte8 * 256 + byte9;
                int year = 2000 + byte10;
                int month = byte11;
                int day = byte12;
                int hour = byte13;
                int minute = byte14;
                
                [values setObject:@(number) forKey:@"number"];
                [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
                [values setObject:@(year) forKey:@"year"];
                [values setObject:@(month) forKey:@"month"];
                [values setObject:@(day) forKey:@"day"];
                [values setObject:@(hour) forKey:@"hour"];
                [values setObject:@(minute) forKey:@"minute"];
                
            } else if (dataType == 0x83) {
                int byte7 = dataBuffer[7];
                
                int status = byte7;
                [values setObject:@(status) forKey:@"status"];
                
            } else if (dataType == 0x84) {
                int byte7 = dataBuffer[7];
                int byte8 = dataBuffer[8];
                int byte9 = dataBuffer[9];
                int byte10 = dataBuffer[10];
                int byte11 = dataBuffer[11];
                int byte12 = dataBuffer[12];
                
                NSString *serialNO = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X", byte7, byte8, byte9, byte10, byte11, byte12];
                [values setObject:serialNO forKey:@"serialNO"];
                
            } else if (dataType == 0x85) {
                int byte7 = dataBuffer[7];
                
                int battery = byte7;
                [values setObject:@(battery) forKey:@"battery"];
                
            }
            
        } else if (productCode == 0x03) {
            [values setObject:@(dataType) forKey:@"dataType"];
            if (dataType == 0x80) {
                int byte7 = dataBuffer[7];
                int byte8 = dataBuffer[8];
                int byte9 = dataBuffer[9];
                int byte10 = dataBuffer[10];
                int byte11 = dataBuffer[11];
                int byte12 = dataBuffer[12];
                
                int bodyMassKG = byte7 * 256 + byte8;
                int bodyMassLB = byte9 * 256 + byte10;
                int ifStable = byte12;
                
                [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
                [values setObject:@(bodyMassLB) forKey:@"bodyMassLB"];
                if (byte11 == 0x01) {
                    [values setObject:@"kg" forKey:@"unit"];
                } else if (byte11 == 0x02) {
                    [values setObject:@"lb" forKey:@"unit"];
                } else if (byte11 == 0x03) {
                    [values setObject:@"st" forKey:@"unit"];
                }
                [values setObject:@(ifStable) forKey:@"ifStable"];
                
            } else if (dataType == 0x81) {
                int byte7 = dataBuffer[7];
                
                int status = byte7;
                [values setObject:@(status) forKey:@"status"];
                
            } else if (dataType == 0x82) {
                int byte7 = dataBuffer[7];
                
                int status = byte7;
                if (status == 0xFF) {
                    [values setObject:@(1) forKey:@"finish"];
                    return values;
                }
                
                int byte8 = dataBuffer[8];
                int byte9 = dataBuffer[9];
                int byte10 = dataBuffer[10];
                int byte11 = dataBuffer[11];
                int byte12 = dataBuffer[12];
                int byte13 = dataBuffer[13];
                int byte14 = dataBuffer[14];
                int byte15 = dataBuffer[15];
                int byte16 = dataBuffer[16];
                int byte17 = dataBuffer[17];
                int byte18 = dataBuffer[18];
                int byte19 = dataBuffer[19];
                int byte20 = dataBuffer[20];
                int byte21 = dataBuffer[21];
                int byte22 = dataBuffer[22];
                int byte23 = dataBuffer[23];
                int byte24 = dataBuffer[24];
                int byte25 = dataBuffer[25];
                int byte26 = dataBuffer[26];
                int byte27 = dataBuffer[27];
                
                int number = byte7;
                int pin = [[NSString stringWithFormat:@"%02X%02X", byte8, byte9] intValue];
                int bodyMassKG = byte10 * 256 + byte11;
                int fat = byte12 * 256 + byte13;
                int impedance = byte14 * 256 + byte15;
                int hydro = byte16 * 256 + byte17;
                int muscle = byte18 * 256 + byte19;
                int bone = byte20 * 256 + byte21;
                int kcal = byte22 * 256 + byte23;
                int interval = byte24 * 256 * 256 * 256 + byte25 * 256 * 256 + byte26 * 256 + byte27;
                
                [values setObject:@(0) forKey:@"finish"];
                [values setObject:@(number) forKey:@"number"];
                [values setObject:@(pin) forKey:@"pin"];
                [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
                [values setObject:@(fat) forKey:@"fat"];
                [values setObject:@(impedance) forKey:@"impedance"];
                [values setObject:@(hydro) forKey:@"hydro"];
                [values setObject:@(muscle) forKey:@"muscle"];
                [values setObject:@(bone) forKey:@"bone"];
                [values setObject:@(kcal) forKey:@"kcal"];
                [values setObject:@(interval) forKey:@"interval"];
                
            } else if (dataType == 0x83) {
                int byte7 = dataBuffer[7];
                
                int status = byte7;
                [values setObject:@(status) forKey:@"status"];
                
            } else if (dataType == 0x84) {
                int byte7 = dataBuffer[7];
                int byte8 = dataBuffer[8];
                int byte9 = dataBuffer[9];
                int byte10 = dataBuffer[10];
                int byte11 = dataBuffer[11];
                int byte12 = dataBuffer[12];
                
                NSString *serialNO = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X", byte7, byte8, byte9, byte10, byte11, byte12];
                [values setObject:serialNO forKey:@"serialNO"];
                
            } else if (dataType == 0x85) {
                int byte7 = dataBuffer[7];
                
                int battery = byte7;
                [values setObject:@(battery) forKey:@"battery"];
                
            } else if (dataType == 0x87) {
                int byte7 = dataBuffer[7];
                int byte8 = dataBuffer[8];
                int byte9 = dataBuffer[9];
                int byte10 = dataBuffer[10];
                int byte11 = dataBuffer[11];
                int byte12 = dataBuffer[12];
                int byte13 = dataBuffer[13];
                int byte14 = dataBuffer[14];
                int byte15 = dataBuffer[15];
                int byte16 = dataBuffer[16];
                
                int count = byte7;
                int number = byte8;
                int pin = [[NSString stringWithFormat:@"%02X%02X", byte9, byte10] intValue];
                int sex = byte11;
                int heightCM = byte12;
                int age = byte13;
                int sportMode = byte14;
                int bodyMassKG = byte15 * 256 * byte16;
                
                [values setObject:@(count) forKey:@"count"];
                [values setObject:@(number) forKey:@"number"];
                [values setObject:@(pin) forKey:@"pin"];
                [values setObject:@(sex) forKey:@"sex"];
                [values setObject:@(heightCM) forKey:@"heightCM"];
                [values setObject:@(age) forKey:@"age"];
                [values setObject:@(sportMode) forKey:@"sportMode"];
                [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
                
            }
            
        }
        
    } else if (type == SSBLESENSSUNWRISTSTRAP) {
        
    }
    
    return values;
}

+ (NSDictionary *)getDevicesMap:(NSArray *)deviceTypes {
    NSMutableDictionary *deviceTypeMap = [NSMutableDictionary dictionary];
    for (id key in deviceTypes) {
        [deviceTypeMap setObject:@"" forKey:key];
    }
    
    NSMutableDictionary *typeToDeviceMap = [NSMutableDictionary dictionary];
    SSBLEDeviceTypeEnum deviceType = -1;
    SSBLEDevice *device = nil;
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNSCALEBODY)]) {
        deviceType = SSBLESENSSUNSCALEBODY;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                              serviceMap:@{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                           @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}
                                             maxConnectCount:1];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNWRISTSTRAP)]) {
        deviceType = SSBLESENSSUNWRISTSTRAP;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                              serviceMap:@{@"96BCFE20-A200-1000-8000-C2396B930012": @[@"", @"96BCFE22-A200-1000-8000-C2396B930012", @"96BCFE21-A200-1000-8000-C2396B930012"],
                                                           @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E": @[@"", @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E", @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"],
                                                           @"0AFO": @[@"", @"0AF7", @"0AF6"]}
                                         maxConnectCount:1];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
    }

    return typeToDeviceMap;
}

+ (NSDictionary *)getAcceptableManufacturerIDs {
    return @{@"0001" : @"0001",
             @"0002" : @"0002",
             @"4717" : @"4717"};
}

+ (NSDictionary *)parseSerialNO:(NSString *)serialNO {
    if (serialNO.length < 22) {
        return nil;
    }
    
    NSString *manufacturerID = [serialNO substringWithRange:NSMakeRange(0, 4)];
    if (![SSBLEDevice getAcceptableManufacturerIDs][manufacturerID]) {
        return nil;
    }
    
    NSString *protocol = [serialNO substringWithRange:NSMakeRange(4, 2)];
    NSString *model = [serialNO substringWithRange:NSMakeRange(6, 4)];
    
    return @{@"manufacturerID" : manufacturerID,
             @"protocol" : protocol,
             @"model" : model};
}

+ (NSDictionary *)modelToDeviceTypeMap {
    return @{@"0115" : @(SSBLESENSSUNSCALEBODY),
             @"1001" : @(SSBLESENSSUNWRISTSTRAP),
             @"0117" : @(SSBLESENSSUNWRISTSTRAP)};
}

+ (int)getDeviceTypeByModel:(NSString *)model {
    NSDictionary *modelToDeviceTypeMap = [SSBLEDevice modelToDeviceTypeMap];
    
    return [modelToDeviceTypeMap[model] intValue];
}

@end