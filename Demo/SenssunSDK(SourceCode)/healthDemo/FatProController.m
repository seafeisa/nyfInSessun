#import "FatProController.h"
#import "SSBLEDeviceManager.h"
#import "AppDelegate.h"
#import "Unit.h"


@interface FatProController () <SSBLEDeviceDelegate> {
    BOOL _isConnected;
    BOOL _isAllowWrite;
    BodyMeasure *_lastBodyMeasure;
}
@end


@implementation FatProController

- (void)dealloc {
}

- (id)init {
    self = [super init];
    if (self) {
        _isConnected = NO;
        _isAllowWrite = YES;
    }
    return self;
}

- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.bleMgr connectWithSerialNO:@{self.serialNO: self.advertiseName}];
    [delegate.bleMgr addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.bleMgr disconnectWithSerialNO:self.serialNO];
    [delegate.bleMgr removeDelegate:self];
}

- (void)peripheralDidConnect:(CBPeripheral *)peripheral {
    _isConnected = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
    });
}

- (void)peripheralDidDisconnect:(CBPeripheral *)peripheral {
    _isConnected = NO;
    _isAllowWrite = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
    });
}

- (void)peripheralDidAllowWrite:(CBPeripheral *)peripheral {
    _isAllowWrite = YES;
}

- (void)peripheralDidReceived:(CBPeripheral *)peripheral value:(BodyMeasure *)value values:(NSMutableArray *)values {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (value && value.dataType == DataTypeWeigh) {
            if (!value.ifStable || value.ifStable != _lastBodyMeasure.ifStable || value.bodyMassKG != _lastBodyMeasure.bodyMassKG) {
                self.lblWeightKg.text = [NSString stringWithFormat:@"体重：%.1fkg", value.bodyMassKG / 10.0f];
                self.lblWeightlb.text = [NSString stringWithFormat:@"体重：%.1flb", value.bodyMassLB / 10.0f];
                self.lblStable.text = [NSString stringWithFormat:@"数据：%@", (value.ifStable ? @"稳定" : @"不稳定")];
            }
            
        } else if (value && value.dataType == DataTypeTestFat) {
            if (value.bodyMassKG != _lastBodyMeasure.bodyMassKG || value.bodyFatPercentage != _lastBodyMeasure.bodyFatPercentage) {
                self.lblTestFat.text = [NSString stringWithFormat:@"%@\r\n脂肪率:%.1f%%, 水分:%.1fkg, 肌肉:%.1fkg, \r\n骨骼%.1fkg, 卡路里:%dkcal, 蛋白质:%.1fkg,\r\n内脏脂肪指数:%.1f, 身体年龄:%d, 健康得分:%d", self.lblTestFat.text, value.bodyFatPercentage/10.0f, value.cellHydro/10.0f, value.muscle/10.0f, value.bone/1000.0f, value.kcal, value.protein/10.0f, value.visceralFat / 10.0f, value.bodyAge, value.healthScore];
            }
            
        }
        
        if (value) {
            _lastBodyMeasure = value;
        }
    });
}

- (IBAction)testFat:(id)sender {
    if (!_isAllowWrite) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"not allow send" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //Unit *unit = [[Unit getHeightUnitDictionary] objectForKey:@"in"];
    int heightCM = 178;
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    CBPeripheral *peripheral = delegate.bleMgr.deviceIDToPeripheralMap.allValues.lastObject;
    [delegate.bleMgr sendSENSSUNSUPERFATTestFatWithSex:1 userID:1 age:30 heightCM:heightCM heightInch:0 peripheral:peripheral];
    
    //self.lblTestFat.text = @"";
}

- (IBAction)testFat2:(id)sender {
    if (!_isAllowWrite) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"not allow send" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //Unit *unit = [[Unit getHeightUnitDictionary] objectForKey:@"in"];
    int heightCM = 178;
    //int heightInch = heightCM * unit.ExchangeRate;
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    CBPeripheral *peripheral = delegate.bleMgr.deviceIDToPeripheralMap.allValues.lastObject;
    [delegate.bleMgr sendSENSSUNSUPERFATTestFat2WithSex:1 userID:1 age:30 heightCM:heightCM heightInch:0 peripheral:peripheral];
    
    //self.lblTestFat.text = @"";
}

- (void)peripheralDidReceived:(CBPeripheral *)peripheral data:(SSBLEReadWriteData *)data datas:(NSArray *)datas {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSDictionary *values = data.readValues;
        NSString *hz = [values objectForKey:@"hz"];
        NSString *c = [values objectForKey:@"channel"];
        NSString *value = [values objectForKey:@"value"];
        
        int freq = ([hz isEqualToString:@"30"] ? 50 : 250);
        int channel = [[c substringFromIndex:1] intValue];
        self.lblTestFat.text = [NSString stringWithFormat:@"%@\r\n频率:%d, 通道:%d, 阻抗:%@", self.lblTestFat.text, freq, channel, value];
        
        if (freq == 250 && channel == 5) {
            self.lblTestFat.text = [NSString stringWithFormat:@"%@\r\n", self.lblTestFat.text];
        }
        
        
        
        CGSize size = [self.lblTestFat.text sizeWithFont:self.lblTestFat.font constrainedToSize:CGSizeMake(self.lblTestFat.frame.size.width, INT32_MAX)];
        self.lblTestFat.frame = CGRectMake(0.0f, 0.0f, self.lblTestFat.frame.size.width, size.height);
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, size.height);
    });
}

@end