#import "MassFatController.h"
#import "SSBLEDeviceManager.h"
#import "AppDelegate.h"
#import "Unit.h"


@interface MassFatController () <SSBLEDeviceDelegate> {
    BOOL _isConnected;
    BOOL _isAllowWrite;
    BodyMeasure *_lastBodyMeasure;
}
@end


@implementation MassFatController

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
            self.lblWeightKg.text = [NSString stringWithFormat:@"体重：%.1fkg", value.bodyMassKG / 10.0f];
            self.lblWeightlb.text = [NSString stringWithFormat:@"体重：%.1flb", value.bodyMassLB / 10.0f];
            self.lblStable.text = [NSString stringWithFormat:@"数据：%@", (value.ifStable ? @"稳定" : @"不稳定")];
            self.lblTestFat.text = [NSString stringWithFormat:@"脂肪率:%.1f%%, 水分:%.1f%%, 肌肉:%.1f%%, \r\n骨骼：%.1f%%, 卡路里：%dkcal, 蛋白质:%.1f%%,\r\n内脏脂肪:%.1f%%, 身体年龄:%d, 健康得分:%d, 皮下脂肪:%.1f%%, 活动代谢:%dkcal", value.bodyFatPercentage/10.0f, value.hydro/10.0f, value.muscle/10.0f, value.bone/10.0f, value.kcal, value.protein/10.0f, value.visceralFat/10.0f, value.bodyAge, value.healthScore, value.bcutaneousFat/10.0f, [BodyMeasure getAMR:value.kcal :DeviceSportMode2 :DeviceGenderMale]];
            
        } else if (value && value.dataType == DataTypeTestFatError) {
            self.lblTestFat.text = [NSString stringWithFormat:@"测试脂肪失败"];
            
        } else if (value && value.dataType == DataTypeHistory) {
            BodyMeasure *temp = value;
            if (value.dayInterval > 0) {
                NSDateFormatter *fmater = [[NSDateFormatter alloc] init];
                fmater.dateFormat = @"yyyy-MM-dd";
                NSDate *startDate = [fmater dateFromString:value.recordDate];
                NSDate *date = [startDate dateByAddingTimeInterval:value.dayInterval];
                fmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSString *newDate = [fmater stringFromDate:date];
                
                self.lblHistory.text = [NSString stringWithFormat:@"用户序号：%d, \r\n历史数据序号：%d, \r\n历史记录日期：%@, \r\n体重：%.1f kg, \r\n体重：%.1f lb, \r\n脂肪率：%.1f %%, \r\n水分值：%.1f %%, \r\n肌肉值：%.1f %%, \r\n骨骼值：%.1f %%, \r\n卡路里：%d kcal, \r\n蛋白质:%.1f%%, \r\n内脏脂肪:%.1f%%, \r\n身体年龄:%d, \r\n健康得分:%d, \r\n皮下脂肪:%.1f%%, \r\n活动代谢:%dkcal\r\n\r\n%@", temp.deviceUserID, temp.number, newDate, temp.bodyMassKG/10.f, temp.bodyMassLB/10.f, temp.bodyFatPercentage/10.f, temp.hydro/10.f, temp.muscle/10.f, temp.bone/10.f, temp.kcal, temp.protein/10.0f, temp.visceralFat/10.0f, temp.bodyAge, temp.healthScore, temp.bcutaneousFat/10.0f, [BodyMeasure getAMR:temp.kcal :DeviceSportMode2 :DeviceGenderMale], self.lblHistory.text];
            } else {
                self.lblHistory.text = [NSString stringWithFormat:@"用户序号：%d, \r\n历史数据序号：%d, \r\n历史记录日期：%@, \r\n体重：%.1f kg, \r\n体重：%.1f lb, \r\n脂肪率：%.1f %%, \r\n水分值：%.1f %%, \r\n肌肉值：%.1f %%, \r\n骨骼值：%.1f %%, \r\n卡路里：%d kcal, \r\n蛋白质:%.1f%%, \r\n内脏脂肪:%.1f%%, \r\n身体年龄:%d, \r\n健康得分:%d, \r\n皮下脂肪:%.1f%%, \r\n活动代谢:%dkcal\r\n\r\n%@", temp.deviceUserID, temp.number, temp.recordDate, temp.bodyMassKG/10.f, temp.bodyMassLB/10.f, temp.bodyFatPercentage/10.f, temp.hydro/10.f, temp.muscle/10.f, temp.bone/10.f, temp.kcal, temp.protein/10.0f, temp.visceralFat/10.0f, temp.bodyAge, temp.healthScore, temp.bcutaneousFat/10.0f, [BodyMeasure getAMR:temp.kcal :DeviceSportMode2 :DeviceGenderMale], self.lblHistory.text];
            }
            
            CGSize size = [self.lblHistory.text sizeWithFont:self.lblHistory.font constrainedToSize:CGSizeMake(self.lblHistory.frame.size.width, INT32_MAX)];
            self.lblHistory.frame = CGRectMake(0.0f, 0.0f, self.lblHistory.frame.size.width, size.height);
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, size.height);

        } else if (values && values.count > 0) {
            self.lblHistory.text = @"";
            for (int i = 0; i < [values count]; i++) {
                BodyMeasure *temp = [values objectAtIndex:i];
                if (temp.dayInterval > 0) {
                    NSDateFormatter *fmater = [[NSDateFormatter alloc] init];
                    fmater.dateFormat = @"yyyy-MM-dd";
                    NSDate *startDate = [fmater dateFromString:value.recordDate];
                    NSDate *date = [startDate dateByAddingTimeInterval:value.dayInterval];
                    fmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    NSString *newDate = [fmater stringFromDate:date];
                    
                    self.lblHistory.text = [NSString stringWithFormat:@"用户序号：%d, \r\n历史数据序号：%d, \r\n历史记录日期：%@, \r\n体重：%.1f kg, \r\n体重：%.1f lb, \r\n脂肪率：%.1f %%, \r\n水分值：%.1f %%, \r\n肌肉值：%.1f %%, \r\n骨骼值：%.1f %%, \r\n卡路里：%d kcal, \r\n蛋白质:%.1f%%, \r\n内脏脂肪:%.1f%%, \r\n身体年龄:%d, \r\n健康得分:%d, \r\n皮下脂肪:%.1f%%, \r\n活动代谢:%dkcal\r\n\r\n%@", temp.deviceUserID, temp.number, newDate, temp.bodyMassKG / 10.f, temp.bodyMassLB / 10.f, temp.bodyFatPercentage / 10.f, temp.hydro / 10.f, temp.muscle / 10.f, temp.bone / 10.f, temp.kcal, temp.protein/10.0f, temp.visceralFat/10.0f, temp.bodyAge, temp.healthScore, temp.bcutaneousFat/10.0f, [BodyMeasure getAMR:temp.kcal :DeviceSportMode2 :DeviceGenderMale], self.lblHistory.text];
                } else {
                    self.lblHistory.text = [NSString stringWithFormat:@"用户序号：%d, \r\n历史数据序号：%d, \r\n历史记录日期：%@, \r\n体重：%.1f kg, \r\n体重：%.1f lb, \r\n脂肪率：%.1f %%, \r\n水分值：%.1f %%, \r\n肌肉值：%.1f %%, \r\n骨骼值：%.1f %%, \r\n卡路里：%d kcal, \r\n蛋白质:%.1f%%, \r\n内脏脂肪:%.1f%%, \r\n身体年龄:%d, \r\n健康得分:%d, \r\n皮下脂肪:%.1f%%, \r\n活动代谢:%dkcal\r\n\r\n%@", temp.deviceUserID, temp.number, temp.recordDate, temp.bodyMassKG / 10.f, temp.bodyMassLB / 10.f, temp.bodyFatPercentage / 10.f, temp.hydro / 10.f, temp.muscle / 10.f, temp.bone / 10.f, temp.kcal, temp.protein/10.0f, temp.visceralFat/10.0f, temp.bodyAge, temp.healthScore, temp.bcutaneousFat/10.0f, [BodyMeasure getAMR:temp.kcal :DeviceSportMode2 :DeviceGenderMale], self.lblHistory.text];
                }
            }
            
            CGSize size = [self.lblHistory.text sizeWithFont:self.lblHistory.font constrainedToSize:CGSizeMake(self.lblHistory.frame.size.width, INT32_MAX)];
            self.lblHistory.frame = CGRectMake(0.0f, 0.0f, self.lblHistory.frame.size.width, size.height);
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, size.height);

        }
        
        if (value) {
            _lastBodyMeasure = value;
        }

    });
}

- (void)peripheralDidReceivedAllHistoryData:(CBPeripheral *)peripheral {
    NSLog(@"传输历史数据完成！");
}

- (IBAction)testFat:(id)sender {
    if (!_isAllowWrite || self.deviceType == SSBLESENSSUNBODY) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"not allow send" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    Unit *unit = [[Unit getHeightUnitDictionary] objectForKey:@"in"];
    int heightCM = 165;
    int heightInch = heightCM * unit.ExchangeRate;
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    CBPeripheral *peripheral = delegate.bleMgr.deviceIDToPeripheralMap.allValues.lastObject;
    [delegate.bleMgr sendSENSSUNFATTestFatWithSex:1 userID:1 age:30 heightCM:heightCM heightInch:heightInch * 10 peripheral:peripheral];
}

- (IBAction)getHistory:(id)sender {
    if (!_isAllowWrite || self.deviceType == SSBLESENSSUNBODY) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"not allow send" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 5000);
    [self.scrollView addSubview:self.lblHistory];
    self.lblHistory.frame = CGRectMake(0.0f, 0.0f, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    self.lblHistory.text = @"";
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    CBPeripheral *peripheral = delegate.bleMgr.deviceIDToPeripheralMap.allValues.lastObject;
    [delegate.bleMgr sendSENSSUNFATSearchHistoryWithUserID:1 peripheral:peripheral];
}

- (void)peripheralDidWrite:(CBPeripheral *)peripheral data:(SSBLEReadWriteData *)data {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (data.dataType == 0x10) {
            self.lblTestFat.text = @"";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送测试脂肪命令成功！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    });
}

@end
