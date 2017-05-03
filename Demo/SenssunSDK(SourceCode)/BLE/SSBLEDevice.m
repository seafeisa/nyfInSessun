#import "SSBLEDevice.h"


@implementation SSBLEDevice

@synthesize deviceType = _deviceType;
@synthesize nameToServiceMap = _nameToServiceMap;
@synthesize ifBroadcast = _ifBroadcast;

- (id)initWithDeviceType:(SSBLEDeviceTypeEnum)deviceType nameToServiceMap:(NSDictionary *)nameToServiceMap ifBroadcast:(BOOL)ifBroadcast ifPrefixName:(BOOL)ifPrefixName {
    self = [super init];
    if (self) {
        _deviceType = deviceType;
        _nameToServiceMap = nameToServiceMap;
        _ifBroadcast = ifBroadcast;
        _ifPrefixName = ifPrefixName;
    }
    return self;
}

- (NSMutableDictionary *)shortServiceUUIDs {
    NSMutableDictionary *shortUUIDs = [NSMutableDictionary dictionary];
    for (NSDictionary *services in _nameToServiceMap.allValues) {
        if ([services count] > 0) {
            for (NSArray *array in services.allValues) {
                if (array.count > 0) {
                    NSString *shortUUID = (NSString *)[array objectAtIndex:0];
                    if (shortUUID && ![shortUUID isEqualToString:@""]) {
                        [shortUUIDs setObject:shortUUID forKey:[CBUUID UUIDWithString:shortUUID]];
                    }
                }
            }
        }
    }
    return shortUUIDs;
}

- (NSMutableDictionary *)serviceUUIDs {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSDictionary *services in _nameToServiceMap.allValues) {
        if ([services count] > 0) {
            for (NSString *value in services.allKeys) {
                [dictionary setObject:[services objectForKey:value] forKey:[CBUUID UUIDWithString:value]];
            }
        }
    }
    return dictionary;
}

#pragma mark parse/construct data
+ (NSMutableDictionary *)parseData:(NSData *)data deviceType:(SSBLEDeviceTypeEnum)type {
    NSMutableDictionary *values = nil;
    /*
    if (type == SSBLESENSSUNSUPERFAT) {
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        
        NSMutableString *s = [[NSMutableString alloc] init];
        for (int i = 0; i < 20; i++) {
            NSString *temp = [NSString stringWithFormat:@"%02x", dataBuffer[i]];
            [s appendString:temp];
        }

        if ([s rangeOfString:@"bc8131"].length > 0) {
            const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
            
            NSMutableString *s = [[NSMutableString alloc] init];
            for (int i = 0; i < 20; i++) {
                NSString *temp = [NSString stringWithFormat:@"%02x", dataBuffer[i]];
                [s appendString:temp];
            }
            
            if ([s rangeOfString:@"bc8131"].length == 0) {
                return values;
            }
            
            values = [NSMutableDictionary dictionary];
            NSArray *array = [s componentsSeparatedByString:@"a5"];
            [values setValue:array[2] forKey:@"hz"];
            [values setValue:array[3] forKey:@"channel"];
            s = array[4];
            NSMutableString *ss = [[NSMutableString alloc] init];
            for (int i = 0; i < s.length / 2; i++) {
                NSString *temp = [s substringWithRange:NSMakeRange(i * 2 + 1, 1)];
                [ss appendString:temp];
            }
            NSString *value = ss;
            value = [value stringByReplacingOccurrencesOfString:@"e" withString:@"."];
            [values setValue:value forKey:@"value"];
            [values setObject:@(0xFF) forKey:@"guideCode"];
            [values setObject:@(0xA5) forKey:@"productCode"];
            [values setObject:@(0xFF) forKey:@"dataType"];
            return values;
        }
    }
    */
    
    ///*
    if (type == SSBLESENSSUNFAT ||
        type == SSBLESENSSUNHEART ||
        type == SSBLESENSSUNSUPERFAT ||
        type == SSBLESENSSUNBODY ||
        type == SSBLESENSSUNBODYCLOCK ||
        type == SSBLESENSSUNEQi99 ||
        type == SSBLESENSSUNEQi912 ||
        type == SSBLESENSSUNFATCLOCK ||
        type == SSBLESENSSUNJOINTOWN ||
        type == SSBLESENSSUNLETVB1) {
        
        if (data.length < 8) {
            return values;
        }
        
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int byte0 = dataBuffer[0];
        int byte5 = dataBuffer[5];
        
        if (type != SSBLESENSSUNJOINTOWN) {
            if (byte0 != 0xFF && byte5 == 0xFF) {
                data = [data subdataWithRange:NSMakeRange(5, 8)];
            }
        }
        
        dataBuffer = (const unsigned char *)[data bytes];
        int byte2 = dataBuffer[2];
        int byte3 = dataBuffer[3];
        int byte4 = dataBuffer[4];
        byte5 = dataBuffer[5];
        int dataType = dataBuffer[6];
        int byte7 = dataBuffer[7];
        
        int checkSum = (byte2 + byte3 + byte4 + byte5 + dataType) % 256;
        if (checkSum != byte7) {
            return values;
        }
        
        int guideCode = dataBuffer[0];
        int productCode = dataBuffer[1];
        if (type != SSBLESENSSUNJOINTOWN) {
            if (guideCode != 0xFF) {
                return values;
            }
        } else {
            if (guideCode != 0xFA || productCode != 0x55) {
                return values;
            }
        }
        
        if (type == SSBLESENSSUNHEART &&
            guideCode == 0xFF && (productCode == 0x53 || productCode == 0x51)) {
            values = [NSMutableDictionary dictionary];
            [values setObject:@(guideCode) forKey:@"guideCode"];
            [values setObject:@(productCode) forKey:@"productCode"];
            int heartRate = byte2;
            [values setObject:@(heartRate) forKey:@"heartRate"];
            int hco = byte3;
            [values setObject:@(hco) forKey:@"hco"];
            int hci = byte4;
            [values setObject:@(hci) forKey:@"hci"];
            int tpr = byte5;
            [values setObject:@(tpr) forKey:@"tpr"];
            int hac = dataType;
            [values setObject:@(hac) forKey:@"hac"];
            
            return values;
        }
        
        values = [NSMutableDictionary dictionary];
        [values setObject:@(guideCode) forKey:@"guideCode"];
        [values setObject:@(productCode) forKey:@"productCode"];
        [values setObject:@(dataType) forKey:@"dataType"];
        if (dataType == 0xA0 || dataType == 0xAA) {
            [values setObject:@"" forKey:@"unitID"];
            int bodyMassKG = byte2 * 256 + byte3;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
            int bodyMassLB = byte4 * 256 + byte5;
            [values setObject:@(bodyMassLB) forKey:@"bodyMassLB"];
            
        } else if (dataType == 0x10 || dataType == 0x1A) {
            [values setObject:@"kg" forKey:@"unitID"];
            int bodyMassKG = byte2 * 256 + byte3;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
            int bodyMassLB = byte4 * 256 + byte5;
            [values setObject:@(bodyMassLB) forKey:@"bodyMassLB"];
            
        } else if (dataType == 0x20 || dataType == 0x2A) {
            [values setObject:@"lb" forKey:@"unitID"];
            int bodyMassKG = byte2 * 256 + byte3;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
            int bodyMassLB = byte4 * 256 + byte5;
            [values setObject:@(bodyMassLB) forKey:@"bodyMassLB"];
            
        } else if (dataType == 0x30 || dataType == 0x3A) {
            [values setObject:@"st" forKey:@"unitID"];
            int bodyMassKG = byte2 * 256 + byte3;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
            int bodyMassLB = byte4 * 256 + byte5;
            [values setObject:@(bodyMassLB) forKey:@"bodyMassLB"];
            
        } else if (dataType == 0xB0) {
            if (type == SSBLESENSSUNSUPERFAT) {
                int fat = [[NSString stringWithFormat:@"%02X%02X", byte2, byte3] intValue];
                [values setObject:@(fat) forKey:@"fat"];
                int hydro = [[NSString stringWithFormat:@"%02X%02X", byte4, byte5] intValue];
                [values setObject:@(hydro) forKey:@"hydro"];
            } else {
                int fat = byte2 * 256 + byte3;
                [values setObject:@(fat) forKey:@"fat"];
                int hydro = byte4 * 256 + byte5;
                [values setObject:@(hydro) forKey:@"hydro"];
            }
            
        } else if (dataType == 0xB1) {
            if (type == SSBLESENSSUNSUPERFAT) {
                int visceralFat = [[NSString stringWithFormat:@"%02X%02X", byte2, byte3] intValue];
                [values setObject:@(visceralFat) forKey:@"visceralFat"];
                int cellHydro = [[NSString stringWithFormat:@"%02X%02X", byte4, byte5] intValue];
                [values setObject:@(cellHydro) forKey:@"cellHydro"];
            } else {
                int visceralFat = byte2 * 256 + byte3;
                [values setObject:@(visceralFat) forKey:@"visceralFat"];
                int cellHydro = byte4 * 256 + byte5;
                [values setObject:@(cellHydro) forKey:@"cellHydro"];
            }
            
        } else if (dataType == 0xB2) {
            if (type == SSBLESENSSUNSUPERFAT) {
                int leanBodyMass = [[NSString stringWithFormat:@"%02X%02X", byte2, byte3] intValue];
                [values setObject:@(leanBodyMass) forKey:@"leanBodyMass"];
                int protein = [[NSString stringWithFormat:@"%02X%02X", byte4, byte5] intValue];
                [values setObject:@(protein) forKey:@"protein"];
            } else {
                int leanBodyMass = byte2 * 256 + byte3;
                [values setObject:@(leanBodyMass) forKey:@"leanBodyMass"];
                int protein = byte4 * 256 + byte5;
                [values setObject:@(protein) forKey:@"protein"];
            }
            
        } else if (dataType == 0xB3) {
            if (type == SSBLESENSSUNSUPERFAT) {
                int bodyAge = [[NSString stringWithFormat:@"%02X%02X", byte2, byte3] intValue];
                [values setObject:@(bodyAge) forKey:@"bodyAge"];
                int healthScore = [[NSString stringWithFormat:@"%02X%02X", byte4, byte5] intValue];
                [values setObject:@(healthScore) forKey:@"healthScore"];
            } else {
                int bodyAge = byte3;
                [values setObject:@(bodyAge) forKey:@"bodyAge"];
                int healthScore = byte5;
                [values setObject:@(healthScore) forKey:@"healthScore"];
            }
            
        } else if (dataType == 0xC0) {
            if (type == SSBLESENSSUNSUPERFAT) {
                int muscle = [[NSString stringWithFormat:@"%02X%02X", byte2, byte3] intValue];
                [values setObject:@(muscle) forKey:@"muscle"];
                int bone = [[NSString stringWithFormat:@"%02X%02X", byte4, byte5] intValue];
                [values setObject:@(bone) forKey:@"bone"];
            } else {
                int muscle = byte2 * 256 + byte3;
                [values setObject:@(muscle) forKey:@"muscle"];
                int bone = byte5 * 256 + byte4;
                [values setObject:@(bone) forKey:@"bone"];
            }
            
        } else if (dataType == 0xD0) {
            if (type == SSBLESENSSUNSUPERFAT) {
                int kcal = [[NSString stringWithFormat:@"%02X%02X", byte2, byte3] intValue];
                [values setObject:@(kcal) forKey:@"kcal"];
                int bmi = [[NSString stringWithFormat:@"%02X%02X", byte4, byte5] intValue];
                [values setObject:@(bmi) forKey:@"bmi"];
            } else {
                int kcal = byte2 * 256 + byte3;
                [values setObject:@(kcal) forKey:@"kcal"];
                int bmi = byte4 * 256 + byte5;
                [values setObject:@(bmi) forKey:@"bmi"];
            }
            
        } else if (dataType == 0xE0) {
            int sex = byte2;
            [values setObject:@(sex) forKey:@"sex"];
            int userID = byte3;
            [values setObject:@(userID) forKey:@"userID"];
            int age = byte4;
            [values setObject:@(age) forKey:@"age"];
            int number = byte5;
            [values setObject:@(number) forKey:@"number"];
            
        } else if (dataType == 0xE1) {
            int heightCM = byte2 ;
            [values setObject:@(heightCM) forKey:@"heightCM"];
            int heightIN = byte3 * 256 + byte4;
            [values setObject:@(heightIN) forKey:@"heightIN"];
            int number = byte5;
            [values setObject:@(number) forKey:@"number"];
            
        } else if (dataType == 0xE2) {
            int year = byte2 + 2000;
            [values setObject:@(year) forKey:@"year"];
            int day = byte3 * 256 + byte4;
            [values setObject:@(day) forKey:@"day"];
            int number = byte5;
            [values setObject:@(number) forKey:@"number"];
            
        } else if (dataType == 0xE3) {
            int hour = byte2;
            [values setObject:@(hour) forKey:@"hour"];
            int minute = byte3;
            [values setObject:@(minute) forKey:@"minute"];
            int second = byte4;
            [values setObject:@(second) forKey:@"second"];
            int number = byte5;
            [values setObject:@(number) forKey:@"number"];
            
        } else if (dataType == 0xF0) {
            int number = byte2;
            [values setObject:@(number) forKey:@"number"];
            int count = byte3;
            [values setObject:@(count) forKey:@"count"];
            
        } else if (dataType == 0xBE) {
            int fatLowHigh = byte2 * 256 + byte3;
            [values setObject:@(fatLowHigh) forKey:@"fatLowHigh"];
            
        } else if (dataType == 0x00) {
            int reply = byte2;
            [values setObject:@(reply) forKey:@"reply"];
            int value1 = byte3;
            [values setObject:@(value1) forKey:@"value1"];
            int value2 = byte4;
            [values setObject:@(value2) forKey:@"value2"];
            int value3 = byte5;
            [values setObject:@(value3) forKey:@"value3"];
        }
        
    } else if (type == SSBLESENSSUNGROWTH) {
        if (data.length < 9) {
            return values;
        }
        
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int guideCode = dataBuffer[0];
        int dataType = dataBuffer[1];
        int byte2 = dataBuffer[2];
        int byte3 = dataBuffer[3];
        int byte4 = dataBuffer[4];
        int byte5 = dataBuffer[5];
        int byte6 = dataBuffer[6];
        int byte7 = dataBuffer[7];
        int byte8 = dataBuffer[8];
        int byte9 = dataBuffer[9];
        int byte10 = 0x00;
        int byte11 = 0x00;
        int byte12 = 0x00;
        if (data.length >= 13) {
            byte10 = dataBuffer[10];
            byte11 = dataBuffer[11];
            byte12 = dataBuffer[12];
            
            int checkSum = (byte2 + byte3 + byte4 + byte5 + byte6 + byte7 + byte8 + byte9 + byte10 + byte11) % 256;
            if (checkSum != byte12) {
                return values;
            }
            
            if (guideCode != 0xFF) {
                return values;
            }
            
        } else if (data.length >= 9) {
            int checkSum = (dataType + byte2 + byte3 + byte4 + byte5 + byte6 + byte7) % 256;
            if (checkSum != byte8) {
                return values;
            }
            
            if (guideCode != 0xA5) {
                return values;
            }
        }
        
        values = [NSMutableDictionary dictionary];
        [values setObject:@(guideCode) forKey:@"guideCode"];
        [values setObject:@(dataType) forKey:@"dataType"];
        
        if (dataType == 0xA5) {
            int bodyMassKG = byte2 * 256 + byte3;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
            int bodyMassLB = byte4 * 256 + byte5;
            [values setObject:@(bodyMassLB) forKey:@"bodyMassLB"];
            int heightCM = byte6 * 256 + byte7;
            [values setObject:@(heightCM) forKey:@"heightCM"];
            if (byte8 == 0x01 || byte8 == 0x03) {
                [values setObject:@"kg" forKey:@"unitID"];
                [values setObject:@(0) forKey:@"overload"];
                if (byte8 == 0x01) {
                    [values setObject:@(0) forKey:@"sign"];
                } else {
                    [values setObject:@(1) forKey:@"sign"];
                }
            } else if (byte8 == 0x02 || byte8 == 0x04) {
                [values setObject:@"lb" forKey:@"unitID"];
                [values setObject:@(0) forKey:@"overload"];
                if (byte8 == 0x02) {
                    [values setObject:@(0) forKey:@"sign"];
                } else {
                    [values setObject:@(1) forKey:@"sign"];
                }
            } else if (byte8 == 0x06 || byte8 == 0x08) {
                [values setObject:@"oz" forKey:@"unitID"];
                [values setObject:@(0) forKey:@"overload"];
                if (byte8 == 0x06) {
                    [values setObject:@(0) forKey:@"sign"];
                } else {
                    [values setObject:@(1) forKey:@"sign"];
                }
            } else if (byte8 == 0x07 || byte8 == 0x09) {
                [values setObject:@"lb:oz" forKey:@"unitID"];
                [values setObject:@(0) forKey:@"overload"];
                if (byte8 == 0x07) {
                    [values setObject:@(0) forKey:@"sign"];
                } else {
                    [values setObject:@(1) forKey:@"sign"];
                }
            } else if (byte8 == 0x05) {
                [values setObject:@(1) forKey:@"overload"];
            }
            int userID = byte9;
            [values setObject:@(userID) forKey:@"userID"];
            int ifStable = byte10;
            [values setObject:@(ifStable) forKey:@"ifStable"];
            
        } else if (dataType == 0x75) {
            int year = byte2 + 2000;
            [values setObject:@(year) forKey:@"year"];
            int day = byte3 * 256 + byte4;
            [values setObject:@(day) forKey:@"day"];
            int bodyMassKG = byte5 * 256 + byte6;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
            int heightCM = byte7 * 256 + byte8;
            [values setObject:@(heightCM) forKey:@"heightCM"];
            int userID = byte9;
            [values setObject:@(userID) forKey:@"userID"];
            int dataNO = byte10;
            [values setObject:@(dataNO) forKey:@"dataNO"];
            int dataCount = byte11;
            [values setObject:@(dataCount) forKey:@"dataCount"];
            
        } else if (dataType == 0x50 ||
                   dataType == 0x51 ||
                   dataType == 0x52 ||
                   dataType == 0x60 ||
                   dataType == 0x61 ||
                   dataType == 0x6A) {
            [values setObject:@(byte2) forKey:@"byte2"];
            [values setObject:@(byte3) forKey:@"byte3"];
            [values setObject:@(byte4) forKey:@"byte4"];
            [values setObject:@(byte5) forKey:@"byte5"];
            [values setObject:@(byte6) forKey:@"byte6"];
            [values setObject:@(byte7) forKey:@"byte7"];
            [values setObject:@(byte8) forKey:@"byte8"];
            
        }
        
    } else if (type == SSBLESENSSUNFOOD) {
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int guideCode = dataBuffer[0];
        int productCode = dataBuffer[1];
        if (guideCode != 0xFF || productCode != 0xA5) {
            return values;
        }
        
        int byte2 = dataBuffer[2];
        int byte3 = dataBuffer[3];
        int byte4 = dataBuffer[4];
        int byte5 = dataBuffer[5];
        int byte6 = dataBuffer[6];
        int byte7 = dataBuffer[7];
        int byte8 = dataBuffer[8];
        int byte9 = dataBuffer[9];
        
        int checkSum = (byte2 + byte3 + byte4 + byte5 + byte6 + byte7 + byte8) % 256;
        if (checkSum != byte9) {
            return values;
        }
        
        int foodMassG = byte2 * 256 + byte3;
        int foodMassByUnit = byte4 * 256 + byte5;
        int stable = (byte6 == 0xAA ? 1 : 0);
        int sign = byte7;
        int unit = byte8;
        
        values = [NSMutableDictionary dictionary];
        [values setObject:@(sign) forKey:@"sign"];
        [values setObject:@(foodMassG) forKey:@"foodMassG"];
        [values setObject:@(foodMassByUnit) forKey:@"foodMassByUnit"];
        [values setObject:@(unit) forKey:@"unit"];
        [values setObject:@(stable) forKey:@"stable"];
        
    } else if (type == SSBLESENSSUNPAD) {
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int byte0 = dataBuffer[0];
        int byte1 = dataBuffer[1];
        int byte2 = dataBuffer[2];
        int byte3 = dataBuffer[3];
        int byte4 = dataBuffer[4];
        int byte5 = dataBuffer[5];
        int byte6 = dataBuffer[6];
        int byte7 = dataBuffer[7];
        int byte8 = dataBuffer[8];
        int byte9 = dataBuffer[9];
        int byte10 = dataBuffer[10];
        int byte11 = dataBuffer[11];
        int byte12 = dataBuffer[12];
        int byte13 = dataBuffer[13];
        int byte14 = dataBuffer[14];
        int byte15 = dataBuffer[15];
        
        int guideCode = byte0;
        if (guideCode != 0xFF) {
            return values;
        }
        
        if (byte1 != 0x77) {
            int check = (byte1 + byte2 + byte3 + byte4 + byte5 + byte6 + byte7 + byte8 + byte9 + byte10 + byte11 + byte12 + byte13 + byte14) % 256;
            Byte checkByte = (Byte)0xFF & check;
            checkByte = ~checkByte;
            if (checkByte != byte15) {
                return values;
            }
        }
        
        int dataType = byte1;
        int voltage = byte14;
        
        values = [NSMutableDictionary dictionary];
        [values setObject:@(dataType) forKey:@"dataType"];
        [values setObject:@(voltage) forKey:@"voltage"];
        
        if (dataType == 0x70) {
            int ifStable = byte2;
            int sign = byte3;
            int weightKG = byte5 * 256 + byte4;
            int weightOZ = byte7 * 256 + byte6;
            int weightWithoutPeelKG = byte9 * 256 + byte8;
            int overload = byte13;
            
            [values setObject:@(ifStable) forKey:@"ifStable"];
            [values setObject:@(sign) forKey:@"sign"];
            [values setObject:@(weightKG) forKey:@"massKG"];
            [values setObject:@(weightOZ) forKey:@"massOZ"];
            [values setObject:@(weightWithoutPeelKG) forKey:@"massWithoutPeelKG"];
            [values setObject:@(overload) forKey:@"overload"];
            
        } else if (dataType == 0x73) {
            int ifStable = byte2;
            int sign = byte3;
            int build = byte5 * 256 + byte4;
            int buildStatus = byte6;
            int overload = byte13;
            
            [values setObject:@(ifStable) forKey:@"ifStable"];
            [values setObject:@(sign) forKey:@"sign"];
            [values setObject:@(build) forKey:@"build"];
            [values setObject:@(buildStatus) forKey:@"buildStatus"];
            [values setObject:@(overload) forKey:@"overload"];
            
        } else if (dataType == 0x75 ||
                   dataType == 0x77) {
            if (byte2 == 0x4F && byte3 == 0x4B) {
                [values setObject:@(1) forKey:@"finish"];
                return values;
            } else {
                [values setObject:@(0) forKey:@"finish"];
            }
            int day = byte3 * 256 + byte2;
            int hour = byte4;
            int minute = byte5;
            int second = byte6;
            int water = byte8 * 256 + byte7;
            int syncCount = byte9;
            int number = byte10;
            int dayOrder = byte11;
            int count = byte13;
            
            [values setObject:@(day) forKey:@"day"];
            [values setObject:@(hour) forKey:@"hour"];
            [values setObject:@(minute) forKey:@"minute"];
            [values setObject:@(second) forKey:@"second"];
            [values setObject:@(water) forKey:@"water"];
            [values setObject:@(syncCount) forKey:@"syncCount"];
            [values setObject:@(number) forKey:@"number"];
            [values setObject:@(dayOrder) forKey:@"dayOrder"];
            [values setObject:@(count) forKey:@"count"];
            
        } else if (dataType == 0x81) {
            int bindingStatus = byte2;
            
            [values setObject:@(bindingStatus) forKey:@"bindingStatus"];
            
        }
        
    } else if (type == SSBLESENSSUNTRACK) {
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        
        int byte0 = dataBuffer[0];
        int byte1 = dataBuffer[1];
        int byte2 = dataBuffer[2];
        int byte3 = dataBuffer[3];
        
        if (byte0 != 0xAA) {
            return values;
        }
        
        int checkSum = (byte1 + byte2) % 256;
        if (checkSum != byte3) {
            return nil;
        }
        
        int reply = byte1;
        int error = byte2;
        
        values = [NSMutableDictionary dictionary];
        [values setObject:@(reply) forKey:@"reply"];
        [values setObject:@(error) forKey:@"error"];
        
    } else if (type == SSBLESENSSUN) {
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int msgType = dataBuffer[1];
        
        values = [NSMutableDictionary dictionary];
        [values setObject:@(msgType) forKey:@"msgType"];
        if (data.length >= 20) {
            if (msgType == 0xF0) {
                int length = dataBuffer[2];
                NSMutableString *productUUID = [[NSMutableString alloc] init];
                for (int i = 0; i < length; i++) {
                    [productUUID appendFormat:@"%c", dataBuffer[i + 3]];
                }
                [values setObject:productUUID forKey:@"productUUID"];
                
            } else if (msgType == 0xF1) {
                int result = dataBuffer[3];
                [values setObject:@(result) forKey:@"result"];
                
            } else if (msgType == 0xF2) {
                int result = dataBuffer[3];
                [values setObject:@(result) forKey:@"result"];
                
            } else if (msgType == 0x04) {
                int byte3 = dataBuffer[3];
                int byte4 = dataBuffer[4];
                int byte5 = dataBuffer[5];
                int byte6 = dataBuffer[6];
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
                int byte28 = dataBuffer[28];
                int byte29 = dataBuffer[29];
                int byte30 = dataBuffer[30];
                int byte31 = dataBuffer[31];
                
                NSInteger sequenceID = byte3 * 255 * 255 * 255 * 255 * 255 + byte4 * 255 * 255 * 255 * 255 + byte5 * 255 * 255 * 255 + byte6 * 255 * 255 + byte7 * 255 + byte8;
                int bodyMassKG = byte9 * 256 + byte10;
                int bmi = byte11 * 256 + byte12;
                int fat = byte13 * 256 + byte14;
                int bcutaneousFat = byte15 * 256 + byte16;
                int visceralFat = byte17 * 256 + byte18;
                int muscle = byte19 * 256 + byte20;
                int kcal = byte21 * 256 + byte22;
                int bone = byte23 * 256 + byte24;
                int hydro = byte25 * 256 + byte26;
                int bodyAge = byte27 * 256 * byte28;
                int protein = byte29 * 256 * byte30;
                int userID = byte31;
                
                [values setObject:@(sequenceID) forKey:@"sequenceID"];
                [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
                [values setObject:@(bmi) forKey:@"bmi"];
                [values setObject:@(fat) forKey:@"fat"];
                [values setObject:@(bcutaneousFat) forKey:@"bcutaneousFat"];
                [values setObject:@(visceralFat) forKey:@"visceralFat"];
                [values setObject:@(muscle) forKey:@"muscle"];
                [values setObject:@(kcal) forKey:@"kcal"];
                [values setObject:@(bone) forKey:@"bone"];
                [values setObject:@(hydro) forKey:@"hydro"];
                [values setObject:@(bodyAge) forKey:@"bodyAge"];
                [values setObject:@(protein) forKey:@"protein"];
                [values setObject:@(userID) forKey:@"userID"];
                
            }
        } if (data.length == 8) {
            int byte2 = dataBuffer[2];
            int byte3 = dataBuffer[3];
            
            int bodyMassKG = byte2 * 256 + byte3;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
        }
        
    } else if (type == SSBLESENSSUNMWS1) {
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int byte0 = dataBuffer[0];
        int byte1 = dataBuffer[1];
        if (byte0 != 0xAA || byte1 != 0x55) {
            return values;
        }
        
        int byte2 = dataBuffer[2];
        if (byte2 > data.length) {
            return values;
        }
        
        int byte3 = dataBuffer[3];
        int byte4 = dataBuffer[4];
        int dataType = byte3 * 256 + byte4;
        values = [NSMutableDictionary dictionary];
        [values setObject:@(dataType) forKey:@"dataType"];
        
        if (byte3 == 0x01 && byte4 == 0xFE) {
            int byte5 = dataBuffer[5];
            int byte6 = dataBuffer[6];
            int byte7 = dataBuffer[7];
            int byte8 = dataBuffer[8];
            
            [values setObject:@(byte5) forKey:@"unitID"];
            if (byte5 == 0x00) {
                [values setObject:@"kg" forKey:@"unit"];
            } else if (byte5 == 0x01) {
                [values setObject:@"jin" forKey:@"unit"];
            } else if (byte5 == 0x02) {
                [values setObject:@"lb" forKey:@"unit"];
            }
            
            int bodyMass = byte6 * 256 + byte7;
            [values setObject:@(bodyMass) forKey:@"bodyMass"];
            int ifStable = byte8;
            [values setObject:@(ifStable) forKey:@"ifStable"];
            
        } else if (byte3 == 0x01 && byte4 == 0xFD) {
            int byte5 = dataBuffer[5];
            int byte6 = dataBuffer[6];
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
            
            int bodyMassKG = byte5 * 256 + byte6;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
            int fat = byte7 * 256 + byte8;
            [values setObject:@(fat) forKey:@"fat"];
            int hydro = byte9 * 256 + byte10;
            [values setObject:@(hydro) forKey:@"hydro"];
            int muscle = byte11 * 256 + byte12;
            [values setObject:@(muscle) forKey:@"muscle"];
            int bone = byte13 * 256 + byte14;
            [values setObject:@(bone) forKey:@"bone"];
            int kcal = byte15 * 256 + byte16;
            [values setObject:@(kcal) forKey:@"kcal"];
            
        } else if (byte3 == 0x01 && byte4 == 0x00) {
            int byte5 = dataBuffer[5];
            
            int reply = byte5;
            [values setObject:@(reply) forKey:@"reply"];
            
        }
    } else if (type == SSBLESENSSUNALI) {
        const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
        int byte0 = dataBuffer[0];
        int byte1 = dataBuffer[1];
        int byte2 = dataBuffer[2];
        //int byte3 = dataBuffer[3];
        //int byte4 = dataBuffer[4];
        //int byte5 = dataBuffer[5];
        int byte6 = dataBuffer[6];
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
        int byte17 = dataBuffer[17];

        int protocol = byte0;
        int length = byte1 * 256 + byte2;
        if (protocol == 0x01) {
            int checkSum = dataBuffer[data.length - 1];
            int check = 0;
            for (int i = 0; i < data.length - 1; i++) {
                check += dataBuffer[i];
            }
            check = (Byte)0xFF & check;
            if (checkSum != check) {
                return values;
            }
            
            values = [NSMutableDictionary dictionary];
            int bodyMassKG = byte6 * 256 + byte7;
            [values setObject:@(bodyMassKG) forKey:@"bodyMassKG"];
            int impedance = byte8 * 256 + byte9;
            [values setObject:@(impedance) forKey:@"impedance"];
            int hydro = byte10 * 256 + byte11;
            [values setObject:@(hydro) forKey:@"hydro"];
            int muscle = byte12 * 256 + byte13;
            [values setObject:@(muscle) forKey:@"muscle"];
            int bone = byte14 * 256 + byte15;
            [values setObject:@(bone) forKey:@"bone"];
            int kcal = byte16 * 256 + byte17;
            [values setObject:@(kcal) forKey:@"kcal"];
            
            if (length == 0x25) {
                
            } else if (length == 0x39) {
                
            }
            
        }
        
    }
    //*/
    
    return values;
}

+ (NSMutableDictionary *)getDevicesNameMap:(NSMutableDictionary *)nameToConnectDeviceMap :(NSMutableDictionary *)nameToBroadcastDeviceMap :(NSArray *)deviceTypes {
    NSMutableDictionary *deviceTypeMap = [NSMutableDictionary dictionary];
    for (id key in deviceTypes) {
        [deviceTypeMap setObject:@"" forKey:key];
    }
    
    NSMutableDictionary *typeToDeviceMap = [NSMutableDictionary dictionary];
    SSBLEDeviceTypeEnum deviceType = -1;
    SSBLEDevice *device = nil;
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNBODY)]) {
        deviceType = SSBLESENSSUNBODY;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN BODY": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                              @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]},
                                                           @"IFit Scale": @{}}
                                             ifBroadcast:YES
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToBroadcastDeviceMap setObject:device forKey:name];
            NSMutableDictionary *serviceMap = [device.nameToServiceMap objectForKey:name];
            if (serviceMap.count > 0) {
                [nameToConnectDeviceMap setObject:device forKey:name];
            }
        }
    }
    
    ///*
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNFAT)]) {
        deviceType = SSBLESENSSUNFAT;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"BLE to UART_2": @{@"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]},
                                                           @"SENSSUN FAT": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                             @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]},
                                                           @"iFit Scale": @{@"49535343-FE7D-4AE5-8FA9-9FAFD205E455": @[@"", @"49535343-1E4D-4BD9-BA61-23C647249616", @"49535343-8841-43F4-A8D4-ECBE34729BB3"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }
    //*/
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNSUPERFAT)]) {
        deviceType = SSBLESENSSUNSUPERFAT;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN FAT PRO": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                                 @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }

    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNFATCLOCK)]) {
        deviceType = SSBLESENSSUNFATCLOCK;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN FAT_A": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                               @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            NSMutableDictionary *serviceMap = [device.nameToServiceMap objectForKey:name];
            if (serviceMap.count > 0) {
                [nameToConnectDeviceMap setObject:device forKey:name];
            }
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNGROWTH)]) {
        deviceType = SSBLESENSSUNGROWTH;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN Growth": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                                @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            NSMutableDictionary *serviceMap = [device.nameToServiceMap objectForKey:name];
            if (serviceMap.count > 0) {
                [nameToConnectDeviceMap setObject:device forKey:name];
            }
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNHEART)]) {
        deviceType = SSBLESENSSUNHEART;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN Heart": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                               @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }

    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNBODYCLOCK)]) {
        deviceType = SSBLESENSSUNBODYCLOCK;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN BODY_A": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                                @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            NSMutableDictionary *serviceMap = [device.nameToServiceMap objectForKey:name];
            if (serviceMap.count > 0) {
                [nameToConnectDeviceMap setObject:device forKey:name];
            }
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNEQi99)]) {
        deviceType = SSBLESENSSUNEQi99;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"EQi-99": @{}}
                                             ifBroadcast:YES
                                            ifPrefixName:YES];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToBroadcastDeviceMap setObject:device forKey:name];
            NSMutableDictionary *serviceMap = [device.nameToServiceMap objectForKey:name];
            if (serviceMap.count > 0) {
                [nameToConnectDeviceMap setObject:device forKey:name];
            }
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNEQi912)]) {
        deviceType = SSBLESENSSUNEQi912;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"EQi-912": @{@"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNFOOD)]) {
        deviceType = SSBLESENSSUNFOOD;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN FOOD": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                              @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNPAD)]) {
        deviceType = SSBLESENSSUNPAD;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN Pad": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"],
                                                                             @"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNTRACK)]) {
        deviceType = SSBLESENSSUNTRACK;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"iL7501B": @{@"FFF0": @[@"FFF0", @"FFF1", @"FFF1"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }

    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNALI)]) {
        deviceType = SSBLESENSSUNALI;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN FAT": @{@"FEB3": @[@"FEB3", @"FED6", @"FED5"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }

    if ([deviceTypeMap objectForKey:@(SSBLESENSSUN)]) {
        deviceType = SSBLESENSSUN;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN": @{@"D618D000-6000-1000-8000-000000000000": @[@"D618", @"D618D002-6000-1000-8000-000000000000", @"D618D001-6000-1000-8000-000000000000"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }

    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNMWS1)]) {
        deviceType = SSBLESENSSUNMWS1;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"MW-S1": @{@"FFB0": @[@"FFB0", @"FFB2", @"FFB2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNJOINTOWN)]) {
        deviceType = SSBLESENSSUNJOINTOWN;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"JOINTOWN": @{@"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }
    
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNLETVB1)]) {
        deviceType = SSBLESENSSUNLETVB1;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"LETV-B1": @{@"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }

    /*
    if ([deviceTypeMap objectForKey:@(SSBLESENSSUNFATPIN)]) {
        deviceType = SSBLESENSSUNFATPIN;
        device = [[SSBLEDevice alloc] initWithDeviceType:deviceType
                                        nameToServiceMap:@{@"SENSSUN FAT": @{@"FFF0": @[@"FFF0", @"FFF1", @"FFF2"]}}
                                             ifBroadcast:NO
                                            ifPrefixName:NO];
        [typeToDeviceMap setObject:device forKey:@(deviceType)];
        for (NSString *name in device.nameToServiceMap.allKeys) {
            [nameToConnectDeviceMap setObject:device forKey:name];
        }
    }
    */
    
    return typeToDeviceMap;
}

@end