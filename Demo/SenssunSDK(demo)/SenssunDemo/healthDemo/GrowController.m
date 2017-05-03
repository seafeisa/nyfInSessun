#import "GrowController.h"
#import "SSBLEDeviceManager.h"
#import "AppDelegate.h"
#import "Unit.h"


@interface GrowController () <SSBLEDeviceDelegate> {
    BOOL _isConnected;
    BOOL _isAllowWrite;
    int _userNO;
    BodyMeasure *_lastBodyMeasure;
}
@end


@implementation GrowController

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
    //[delegate.bleMgr connect:@{self.deviceID: self.advertiseName}];
    [delegate.bleMgr connectWithSerialNO:@{self.serialNO: self.advertiseName}];
    [delegate.bleMgr addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //[delegate.bleMgr disconnect:self.deviceID];
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
                self.lblWeightKg.text = [NSString stringWithFormat:@"体重：%.3fkg", value.bodyMassKG / 1000.0f];
                self.lblWeightlb.text = [NSString stringWithFormat:@"体重：%.3flb", value.bodyMassLB / 100.0f];
                self.lblStable.text = [NSString stringWithFormat:@"数据：%@", (value.ifStable ? @"稳定" : @"不稳定")];
                self.lblHeightCM.text = [NSString stringWithFormat:@"身高：%.1fCM", value.heightCM / 10.0f];
            }
            
        } else if (value && value.dataType == DataTypeHistory) {
            BodyMeasure *temp = value;
            self.lblHistory.text = [NSString stringWithFormat:@"用户序号：%d, \r\n历史数据序号：%d, \r\n历史记录日期：%@, \r\n体重：%.3f kg, \r\n身高：%.1f cm\r\n\r\n%@", temp.deviceUserID, temp.number, temp.recordDate, temp.bodyMassKG / 1000.f, temp.heightCM / 10.f, self.lblHistory.text];
                
            CGSize size = [self.lblHistory.text sizeWithFont:self.lblHistory.font constrainedToSize:CGSizeMake(self.lblHistory.frame.size.width, INT32_MAX)];
                self.lblHistory.frame = CGRectMake(0.0f, 0.0f, self.lblHistory.frame.size.width, size.height);
            
        } else if (values && values.count > 0) {
            self.lblHistory.text = @"";
            for (int i = 0; i < [values count]; i++) {
                BodyMeasure *temp = [values objectAtIndex:i];
                self.lblHistory.text = [NSString stringWithFormat:@"用户序号：%d, \r\n历史数据序号：%d, \r\n历史记录日期：%@, \r\n体重：%.3f kg, \r\n身高：%.1f cm\r\n\r\n%@", temp.deviceUserID, temp.number, temp.recordDate, temp.bodyMassKG / 1000.f, temp.heightCM / 10.f, self.lblHistory.text];
            }
            
            CGSize size = [self.lblHistory.text sizeWithFont:self.lblHistory.font constrainedToSize:CGSizeMake(self.lblHistory.frame.size.width, INT32_MAX)];
            self.lblHistory.frame = CGRectMake(0.0f, 0.0f, self.lblHistory.frame.size.width, size.height);
            
        }
        
        if (value) {
            _lastBodyMeasure = value;
        }
    });
}

- (IBAction)userAdd:(id)sender {
    if (!_isAllowWrite) {
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
    [delegate.bleMgr sendSENSSUNGROWTHUserAdd:1 :peripheral];
}

- (IBAction)userdelete:(id)sender {
    if (!_isAllowWrite) {
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
    [delegate.bleMgr sendSENSSUNGROWTHUserDelete:1 :peripheral];
}

- (IBAction)userSet:(id)sender {
    if (!_isAllowWrite) {
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
    [delegate.bleMgr sendSENSSUNGROWTHUserSet:1 :peripheral];
}

- (IBAction)getHistory:(id)sender {
    if (!_isAllowWrite) {
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
    [delegate.bleMgr sendSENSSUNGROWTHSyncDataShallow:1 :peripheral];
}

- (void)peripheralDidWrite:(CBPeripheral *)peripheral data:(SSBLEReadWriteData *)data {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"操作成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    });
}

- (void)peripheralDidFailToWrite:(CBPeripheral *)peripheral data:(SSBLEReadWriteData *)data {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"操作失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    });
}

@end
