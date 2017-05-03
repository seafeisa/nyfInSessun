//
//  RecordViewController.m
//  grow
//
//  Created by admin on 15-4-22.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "UserList.h"
#import "RecordViewController.h"
//#import "AppData.h"


@interface RecordViewController ()

@property (strong, nonatomic) IBOutlet UITextField *m_iboDate;
@property (weak, nonatomic) IBOutlet UITextField *LbAndOzViewofOz;
@property (strong, nonatomic) IBOutlet UITextField *m_iboWeight;
@property (strong, nonatomic) IBOutlet UITextField *m_iboHeight;
@property (strong, nonatomic) IBOutlet UITextField *m_iboHeadCircle;

@property (strong, nonatomic) IBOutlet PickerView  *m_iboDatePicker;

@property (nonatomic, strong) IBOutlet UILabel *weightUnit;
@property (nonatomic, strong) IBOutlet UILabel *heightUnit;
@property (nonatomic, strong) IBOutlet UILabel *headCircleUnit;
@property (weak, nonatomic) IBOutlet UIView *LbAndOzView;


@end

@implementation RecordViewController
{
    NSArray *m_txtfieldArray;
    
    Record * m_sampleData;
    NSString * measureTimePick;
    //=[AppData getString:@"time"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //获取对应的文字信息
    _RecordViewAdddataname.text = [AppData getString:@"addData"];
    [_RecordViewButtonDonename setTitle:[AppData getString:@"done"] forState:UIControlStateNormal];
    _m_iboDate.placeholder = [AppData getString:@"time"];
    _m_iboHeight.placeholder = [AppData getString:@"heightIs"];
    _m_iboWeight.placeholder = [AppData getString:@"weightIs"];
    _m_iboHeadCircle.placeholder = [AppData getString:@"headsizeIs"];
    
    _weightUnit.text = [AppData getString:@"kg"];
    _heightUnit.text = [AppData getString:@"cm"];
    _headCircleUnit.text = [AppData getString:@"cm"];
    _Recordviewconfirmtitle.title = [AppData getString:@"confirm"];
    _RecordViewCanceltitle.title = [AppData getString:@"cancel"];
    _RecordViewmeasuretitle.title = [AppData getString:@"time"];
    
//    NSLog(@"44");
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // 1. 配置采样数据
    [self initSampleData];
    
    // 2. 设置各采样域
    [self initTextfield];
    
    // 3.
    [self initPicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (![identifier isEqualToString:SEGUE_SAVE_RECORD])
    {
        return YES;
    }
    
    // 校验采样信息
    if (![self isSampleComplete])
    {
        return NO;
    }
    
    // 保存记录
    switch (self.accessMode)
    {
        case ACCESS_MODE_CREATE:
            [self createRecord];
            break;
            
        case ACCESS_MODE_UPDATE:
            [self updateRecord];
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (IBAction)backToPreView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)onButtonDone:(id)sender
{
    // 校验采样信息
    if (![self isSampleComplete])
    {
        return;
    }
    
    // 保存记录
    switch (self.accessMode)
    {
        case ACCESS_MODE_CREATE:            //创建
            [self createRecord];
            break;
            
        case ACCESS_MODE_UPDATE:            //更新
            [self updateRecord];
            break;
            
        default:
            break;
    }
    
    // back to previous view
    [self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - Sample Data
- (BOOL)isSampleComplete
{
    // 检查是否填写完整
    for (UITextField *textField in m_txtfieldArray)
    {
        if (![textField.text isEqualToString:@""])
        {
            continue;
        }

        // 提示
        //获取对应的文字信息 
        NSString *confirm = [AppData getString:@"confirm"];
        NSString *Incomplete = [AppData getString:@"information lack"];
        NSString *Tips = [AppData getString:@"completeprofile-noeffect"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Incomplete/*LOCALSTR_INFO_INCOMPLETE*/
                                                        message:Tips/*LOCALSTR_FILL_TIPS*/
                                                       delegate:self
                                              cancelButtonTitle:confirm/*LOCALSTR_CONFIRM*/
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
    
    return YES;
}

- (void)initSampleData
{
    m_sampleData = [[Record alloc] initWithName:[UserList sharedInstance].currentKid.name];
    NSString *unit = [UserList sharedInstance].currentKid.unit;
    if (!unit || [unit isEqualToString:@""]) {
        unit = @"kg";
    } else if ([unit isEqualToString:@"lb:oz"]) {
        self.LbAndOzView.hidden = NO;

    }
    
    m_sampleData.unit = unit;
    self.weightUnit.text = unit;
    
    if ([unit isEqualToString:@"kg"]) {
        self.heightUnit.text = @"cm";
        self.headCircleUnit.text = @"cm";
    } else {
        self.heightUnit.text = @"inch";
        self.headCircleUnit.text = @"inch";
    }
    
//    NSString *unitWeight = [UserList sharedInstance].currentKid.unit;
//    NSString *unitLength = nil;
//    float maxHeight = DEV_SPEC_HEIGHT_MAX;
//    float minHeight = DEV_SPEC_HEIGHT_MIN;
//    float maxHeadCircle = DEV_SPEC_HEADCL_MAX;
//    float minHeadCircle = DEV_SPEC_HEADCL_MIN;
//    NSString *weightString = nil;
//    float height = 0;
//    float headCircle = 0;
//    if (!unitWeight || [unitWeight isEqualToString:@""] || [unitWeight isEqualToString:@"kg"]) {
//        unitWeight = @"kg";
//        unitLength = @"cm";
//        height = data.height;
//        headCircle = data.headCircle;
//    } else {
//        unitLength = @"inch";
//        maxHeight = floor(DEV_SPEC_HEIGHT_MAX * 101.0f / 256.0f * 10.0f) / 10.0f;
//        minHeight = floor(DEV_SPEC_HEIGHT_MIN * 101.0f / 256.0f * 10.0f) / 10.0f;
//        maxHeadCircle = floor(DEV_SPEC_HEADCL_MAX * 101.0f / 256.0f * 10.0f) / 10.0f;
//        minHeadCircle = floor(DEV_SPEC_HEADCL_MIN * 101.0f / 256.0f * 10.0f) / 10.0f;
//        height = data.height * 0.3937008f;
//        headCircle = data.headCircle * 0.3937008f;
//    }

    if (ACCESS_MODE_UPDATE == self.accessMode)
    {
        Record *currentData = [[UserList sharedInstance].currentKid getRecordByIndex:self.selectedItem];
        
        m_sampleData.measureDate = currentData.measureDate;
        m_sampleData.weight      = currentData.weight;
        m_sampleData.weightLB    = currentData.weightLB;
        m_sampleData.weightOZ    = currentData.weightOZ;
        m_sampleData.height      = currentData.height;
        m_sampleData.headCircle  = currentData.headCircle;
        //m_sampleData.unit = currentData.unit;
        if (!m_sampleData.unit || [m_sampleData.unit isEqualToString:@""]) {
            m_sampleData.unit = @"kg";
        } else if ([m_sampleData.unit isEqualToString:@"lb:oz"]) {
            
            self.LbAndOzView.hidden = NO;
            //m_sampleData.unit = @"lb:oz";//m_sampleData.unit = @"oz";
        }
    }
}

- (void)createRecord
{
    // 新建
    [self saveAllInput];
    
    // 提示覆盖?
    
    [[UserList sharedInstance].currentKid addRecord:m_sampleData];
}

- (void)updateRecord
{
    // 修改
    [self saveAllInput];

    Record *old = [[UserList sharedInstance].currentKid getRecordByIndex:self.selectedItem];

    [[UserList sharedInstance].currentKid setRecord:old withNew:m_sampleData];
}

- (void)saveAllInput {
    m_sampleData.measureDate = dateFromString(self.m_iboDate.text);
    if ([m_sampleData.unit isEqualToString:@"kg"]) {
        /**
         *  重量不小于1kg
         */
        m_sampleData.weight = round([self.m_iboWeight.text floatValue] * 1000.0f) / 1000.0f;
        if (m_sampleData.weight < DEV_SPEC_WEIGHT_MIN) {
            self.m_iboWeight.text = [NSString stringWithFormat:@"%.1f", DEV_SPEC_WEIGHT_MIN];
            m_sampleData.weight = DEV_SPEC_WEIGHT_MIN;
        }
        m_sampleData.weightLB = round(m_sampleData.weight * 2.2046226f * 100.0f) / 100.0f;
        if (![self.m_iboHeight.text isEqualToString:@""]) {
            m_sampleData.height = round([self.m_iboHeight.text floatValue] * 10.0f) / 10.0f;
        }
        if (![self.m_iboHeadCircle.text isEqualToString:@""]) {
            m_sampleData.headCircle = round([self.m_iboHeadCircle.text floatValue] * 10.0f) / 10.0f;
        }
        
    } else if ([m_sampleData.unit isEqualToString:@"lb"]) {
        m_sampleData.weightLB = round([self.m_iboWeight.text floatValue] * 100.0f) / 100.0f;
        m_sampleData.weight = round(m_sampleData.weightLB * 0.4535924f * 1000.0f) / 1000.0f;
        
        if (![self.m_iboHeight.text isEqualToString:@""]) {
            m_sampleData.height = round([self.m_iboHeight.text floatValue] * 2.54f * 10.0f) / 10.0f;
        }
        if (![self.m_iboHeadCircle.text isEqualToString:@""]) {
            m_sampleData.headCircle = round([self.m_iboHeadCircle.text floatValue] * 2.54f * 10.0f) / 10.0f;
        }
        
    } else if ([m_sampleData.unit isEqualToString:@"oz"]) {
        m_sampleData.weightLB = floor([self.m_iboWeight.text floatValue] * 0.0625f * 100.0f) / 100.0f;
        m_sampleData.weight = round(m_sampleData.weightLB * 0.4535924f * 1000.0f) / 1000.0f;
        
        if (![self.m_iboHeight.text isEqualToString:@""]) {
            m_sampleData.height = floor([self.m_iboHeight.text floatValue] * 2.54f * 10.0f) / 10.0f;
        }
        if (![self.m_iboHeadCircle.text isEqualToString:@""]) {
            m_sampleData.headCircle = floor([self.m_iboHeadCircle.text floatValue] * 2.54f * 10.0f) / 10.0f;
        }
        
    } else if ([m_sampleData.unit isEqualToString:@"lb:oz"]){
        m_sampleData.weightOZ = [self.LbAndOzViewofOz.text floatValue];
        float lb = 0;
        if (m_sampleData.weightOZ >= 16.0) {
            lb = m_sampleData.weightOZ/16;
//            NSLog(@"1==%f",lb);
            m_sampleData.weightOZ = [self.LbAndOzViewofOz.text floatValue]-(int)lb*16;
//            NSLog(@"2==%f",[self.LbAndOzViewofOz.text floatValue]);
            m_sampleData.weightLB = [self.m_iboWeight.text floatValue] + lb;
//            NSLog(@"3==%f",m_sampleData.weightLB);
           
        }else{
            
         m_sampleData.weightLB = [self.m_iboWeight.text floatValue];
            
        }
//        NSLog(@"--lb:%f--oz:%f",m_sampleData.weightLB,m_sampleData.weightOZ);
        
//        m_sampleData.weightLB = floor([self.m_iboWeight.text floatValue] * 0.0625f * 100.0f) / 100.0f;
//        m_sampleData.weight = round(m_sampleData.weightLB * 0.4535924f * 1000.0f) / 1000.0f;
        
//        NSLog(@"--------weght:%f",m_sampleData.weight);
        if (![self.m_iboHeight.text isEqualToString:@""]) {
            m_sampleData.height = floor([self.m_iboHeight.text floatValue] * 2.54f * 10.0f) / 10.0f;
        }
        if (![self.m_iboHeadCircle.text isEqualToString:@""]) {
            m_sampleData.headCircle = floor([self.m_iboHeadCircle.text floatValue] * 2.54f * 10.0f) / 10.0f;
        }
    }
}

#pragma mark - Textfield
- (void)initTextfield
{
    m_txtfieldArray = [NSArray arrayWithObjects:
                       self.m_iboDate,
                       self.m_iboWeight,
                       self.m_iboHeight,
                       self.m_iboHeadCircle,
                       nil];
    
    for (UITextField *textField in m_txtfieldArray) {
        textField.delegate = self;
    }
    
    if (ACCESS_MODE_UPDATE == self.accessMode) {
        self.m_iboDate.text = stringFromDate(m_sampleData.measureDate);
        if ([m_sampleData.unit isEqualToString:@"kg"]) {
            
            self.m_iboWeight.text = [NSString stringWithFormat:@"%.1f", m_sampleData.weight];   //kg
            
            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f", m_sampleData.height];
            
            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f", m_sampleData.headCircle];
//            if ((DEV_SPEC_HEIGHT_MIN > m_sampleData.height)) {
//                
//                NSLog(@"kg-height:%f",m_sampleData.height);
//                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHT_MIN];//  DEV_SPEC_HEIGHT_MIN;
//                
//            }else if ((DEV_SPEC_HEIGHT_MAX < m_sampleData.height)){
//                
//                
//                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHT_MAX];
//                
//            }
//            if ((DEV_SPEC_HEADCL_MIN > m_sampleData.headCircle)) {
//                
//                
//                self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCL_MIN];
//                
//            }else if ((DEV_SPEC_HEADCL_MAX < m_sampleData.headCircle)){
//                
//                
//                self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCL_MAX];
//                
//            }
            
        } else if ([m_sampleData.unit isEqualToString:@"lb"]) {
            
            self.m_iboWeight.text = [NSString stringWithFormat:@"%.1f", m_sampleData.weightLB]; //lb
            
            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f", floor(m_sampleData.height * 101.0f / 256.0f * 10.0f) / 10.0f];
            
            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f", floor(m_sampleData.headCircle * 101.0f / 256.0f * 10.0f) / 10.0f];
//            if (DEV_SPEC_HEIGHTLBOZ_MIN > m_sampleData.height) {
//                NSLog(@"lb-height:%f",m_sampleData.height);
//                
//                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MIN];
//                
//            }else if (DEV_SPEC_HEIGHTLBOZ_MAX < m_sampleData.height){
//                
//                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MAX];
//            }
//            if (DEV_SPEC_HEADCLLBOZ_MIN > m_sampleData.headCircle) {
//                
//                self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MIN];
//                
//            }else if (DEV_SPEC_HEADCLLBOZ_MAX < m_sampleData.headCircle){
//                
//                self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MAX];
//            }
            
        } else if ([m_sampleData.unit isEqualToString:@"oz"]) {
            
            self.m_iboWeight.text = [NSString stringWithFormat:@"%.1f", floor(m_sampleData.weightLB * 4100.0f / 256.0f * 10.0f) / 10.0f]; //oz
            
            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f", floor(m_sampleData.height * 101.0f / 256.0f * 10.0f) / 10.0f];
            
            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f", floor(m_sampleData.headCircle * 101.0f / 256.0f * 10.0f) / 10.0f];
//            if (DEV_SPEC_HEIGHTLBOZ_MIN > m_sampleData.height) {
//                
//                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MIN];
//                
//            }else if (DEV_SPEC_HEIGHTLBOZ_MAX < m_sampleData.height){
//                
//                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MAX];
//            }
//            if (DEV_SPEC_HEADCLLBOZ_MIN > m_sampleData.headCircle) {
//                
//                self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MIN];
//                
//            }else if (DEV_SPEC_HEADCLLBOZ_MAX < m_sampleData.headCircle){
//                
//                self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MAX];
//            }
            
        } else if ([m_sampleData.unit isEqualToString:@"lb:oz"]) {
           
            self.m_iboWeight.text = [NSString stringWithFormat:@"%.0f", m_sampleData.weightLB];
            
            self.LbAndOzViewofOz.text = [NSString stringWithFormat:@"%.0f", m_sampleData.weightOZ];
            
//            NSLog(@"lblb----:%f weight----:%f  text:%@",m_sampleData.weightLB,m_sampleData.weightOZ,self.LbAndOzViewofOz.text);
            
            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f", floor(m_sampleData.height * 101.0f / 256.0f * 10.0f) / 10.0f];
            
            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f", floor(m_sampleData.headCircle * 101.0f / 256.0f * 10.0f) / 10.0f];
//            if (DEV_SPEC_HEIGHTLBOZ_MIN > m_sampleData.height) {
//                
//                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MIN];
//                
//            }else if (DEV_SPEC_HEIGHTLBOZ_MAX < m_sampleData.height){
//                
//                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MAX];
//            }
//            if (DEV_SPEC_HEADCLLBOZ_MIN > m_sampleData.headCircle) {
//                
//                self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MIN];
//                
//            }else if (DEV_SPEC_HEADCLLBOZ_MAX < m_sampleData.headCircle){
//                
//                self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MAX];
//            }
        }
        
//        if ([m_sampleData.unit isEqualToString:@"kg"] & (DEV_SPEC_HEIGHT_MIN > m_sampleData.height)) {
//            
//
//            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHT_MIN];//  DEV_SPEC_HEIGHT_MIN;
//            
//        }else if ([m_sampleData.unit isEqualToString:@"kg"] & (DEV_SPEC_HEIGHT_MAX < m_sampleData.height)){
//            
//
//            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHT_MAX];
//            
//            }
//        if ([m_sampleData.unit isEqualToString:@"kg"] & (DEV_SPEC_HEADCL_MIN > m_sampleData.headCircle)) {
//            
//
//            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCL_MIN];
//            
//        }else if ([m_sampleData.unit isEqualToString:@"kg"] & (DEV_SPEC_HEADCL_MAX < m_sampleData.headCircle)){
//            
//
//            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCL_MAX];
//
//            }
//        if ((![m_sampleData.unit isEqualToString:@"kg"]) & (DEV_SPEC_HEIGHTLBOZ_MIN > m_sampleData.height)) {
//            
//            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MIN];
//            
//        }else if ((![m_sampleData.unit isEqualToString:@"kg"]) & (DEV_SPEC_HEIGHTLBOZ_MAX < m_sampleData.height)){
//        
//            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MAX];
//        }
//        if ((![m_sampleData.unit isEqualToString:@"kg"]) & (DEV_SPEC_HEADCLLBOZ_MIN > m_sampleData.headCircle)) {
//            
//            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MIN];
//            
//        }else if ((![m_sampleData.unit isEqualToString:@"kg"]) & (DEV_SPEC_HEADCLLBOZ_MAX < m_sampleData.headCircle)){
//            
//            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MAX];
//        }
//        if ([self.m_iboHeight.text isEqualToString:@"inch"]
//             /*|[m_sampleData.unit isEqualToString:@"oz"]
//             |[m_sampleData.unit isEqualToString:@"lb:oz"]*/
//            & (DEV_SPEC_HEADCLLBOZ_MIN > m_sampleData.height)) {
//            
//           
//             self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MIN];
////           m_sampleData.height = floor(DEV_SPEC_HEIGHT_MIN * 101.0f / 256.0f * 10.0f) / 10.0f;
//            
//        }else if ([self.m_iboHeight.text isEqualToString:@"inch"]
//                  /* |[m_sampleData.unit isEqualToString:@"oz"]
//                   |[m_sampleData.unit isEqualToString:@"lb:oz"]*/
//                  & (DEV_SPEC_HEIGHTLBOZ_MAX < m_sampleData.height)){
//            
//            
//            self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MAX];
////            m_sampleData.height = floor(DEV_SPEC_HEIGHT_MAX * 101.0f / 256.0f * 10.0f) / 10.0f;
//            
//        }
//        if ([self.m_iboHeight.text isEqualToString:@"inch"]
//            /* |[m_sampleData.unit isEqualToString:@"oz"]
//             |[m_sampleData.unit isEqualToString:@"lb:oz"]*/
//            & (DEV_SPEC_HEIGHTLBOZ_MIN > m_sampleData.headCircle)) {
//            
//            
//            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MIN];
////            m_sampleData.headCircle = floor(DEV_SPEC_HEADCL_MIN * 101.0f / 256.0f * 10.0f) / 10.0f;
//            
//        }else if ([self.m_iboHeight.text isEqualToString:@"inch"]
//                   /*|[m_sampleData.unit isEqualToString:@"oz"]
//                   |[m_sampleData.unit isEqualToString:@"lb:oz"]*/
//                  & (DEV_SPEC_HEADCLLBOZ_MAX < m_sampleData.headCircle)){
//            
//            
//            self.m_iboHeadCircle.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MAX];
////            m_sampleData.headCircle = floor(DEV_SPEC_HEADCL_MAX * 101.0f / 256.0f * 10.0f) / 10.0f;
//        
//        }
        
         
//        if ((DEV_SPEC_HEIGHT_MIN > m_sampleData.height) || (DEV_SPEC_HEIGHT_MAX < m_sampleData.height)) {
//            self.m_iboHeight.text = @"error";
//        }
//        if ((DEV_SPEC_HEADCL_MIN > m_sampleData.headCircle) || (DEV_SPEC_HEADCL_MAX < m_sampleData.headCircle)) {
//            self.m_iboHeadCircle.text = @"error";
//        }
        
        if (m_sampleData.height < DEV_SPEC_HEIGHT_MIN) {
            
//            NSLog(@"单位%@",m_sampleData.unit);
            if ([m_sampleData.unit isEqualToString:@"lb"]|[m_sampleData.unit isEqualToString:@"oz"]|[m_sampleData.unit isEqualToString:@"lb:oz"]) {
                self.m_iboHeight.text =[NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MIN];
            }else{
                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHT_MIN];
            }
        }else if (m_sampleData.height > DEV_SPEC_HEIGHT_MAX){
            if ([m_sampleData.unit isEqualToString:@"lb"]|[m_sampleData.unit isEqualToString:@"oz"]|[m_sampleData.unit isEqualToString:@"lb:oz"]) {
                self.m_iboHeight.text =[NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHTLBOZ_MAX];
            }else{
                self.m_iboHeight.text = [NSString stringWithFormat:@"%.1f",DEV_SPEC_HEIGHT_MAX];
            }
        }
        if (m_sampleData.headCircle < DEV_SPEC_HEADCL_MIN) {
//            NSLog(@"单位%@",m_sampleData.unit);
            if ([m_sampleData.unit isEqualToString:@"lb"]|[m_sampleData.unit isEqualToString:@"oz"]|[m_sampleData.unit isEqualToString:@"lb:oz"]) {
                self.m_iboHeadCircle.text =[NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MIN];
            }else{
                self.m_iboHeadCircle.text  =[NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCL_MIN];
            }
        }else if (m_sampleData.headCircle > DEV_SPEC_HEADCL_MAX){
            if ([m_sampleData.unit isEqualToString:@"lb"]|[m_sampleData.unit isEqualToString:@"oz"]|[m_sampleData.unit isEqualToString:@"lb:oz"]) {
                self.m_iboHeadCircle.text =[NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCLLBOZ_MAX];
            }else{
                self.m_iboHeadCircle.text =[NSString stringWithFormat:@"%.1f",DEV_SPEC_HEADCL_MAX];
            }
        }
        
        
        
        
    }
}

- (void)resignAllTextfield
{
    [self.view endEditing:YES];

    [self resignAllPicker];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // 焦点离开，关闭键盘
    [self resignAllTextfield];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //NSLog(@"should begin editing");
    [self resignAllTextfield];
    
    BOOL shouldKeyboardShown = YES;
    
    measureTimePick = [AppData getString:@"time"];
    
    if ([textField.placeholder isEqualToString:measureTimePick/*LOCALSTR_TIME*/])
    {
        // 不弹出键盘
        shouldKeyboardShown = NO;
        
        // 弹出picker
        [self popoverPicker:textField];
    }
    
    return shouldKeyboardShown;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //NSLog(@"did begin editing");
    // 只有shouldBegin里返回yes的能进来
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //NSLog(@"should return editing");
    // 返回前收起键盘
    [textField resignFirstResponder];
    
    if ([textField.placeholder isEqualToString:[AppData getString:@"weiht"]/*LOCALSTR_WEIGHT*/])
    {
        m_sampleData.weight = [textField.text floatValue];
    }
    else if ([textField.placeholder isEqualToString:[AppData getString:@"heiht"]/*LOCALSTR_HEIGHT*/])
    {
        m_sampleData.height = [textField.text floatValue];
    }
    else if ([textField.placeholder isEqualToString:[AppData getString:@"headsize"]/*LOCALSTR_HEADCIRCLE*/])
    {
        m_sampleData.headCircle = [textField.text floatValue];
    }
    
    return  YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //NSLog(@"should end editing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //NSLog(@"did end editing");
    [self resignAllTextfield];
}


#pragma mark Picker
- (void)initPicker
{
    self.m_iboDatePicker.delegate = self;
}

- (void)popoverPicker:(UITextField *)textField
{
    // 滑出picker
    [UIView beginAnimations:textField.placeholder context:NULL];
    [UIView setAnimationDuration:ANIM_DURATION];
    
//    NSString *measureTime = [AppData getString:@"measureTime"];
    
    if ([textField.placeholder isEqualToString:measureTimePick/*measureTime*//*LOCALSTR_TIME*/])
    {
        //[self.m_iboDatePicker changeMode:textField.placeholder];
        self.m_iboDatePicker.frame = CGRectMake(0, SCREEN_HEIGHT - PICKER_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    }
    
    [UIView commitAnimations];
}

- (void)resignAllPicker
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ANIM_DURATION];
    
    self.m_iboDatePicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    
    [UIView commitAnimations];
}

#pragma mark PickerViewDelegate
- (void)pikerviewDidHide:(PickerView *)pickerView
{
    //dbgLog(@"picker hide");
}

- (void)pikerviewDidShow:(PickerView *)pickerView
{
    //dbgLog(@"picker show");
}

- (void)pikerviewDidCancel:(PickerView *)pickerView
{
    //dbgLog(@"picker cancel");
}

- (void)pikerviewDidConfirm:(PickerView *)pickerView selectedDate:(NSDate *)date
{
    //dbgLog(@"picker %@ ok. date:%@", pickerView.title, date);
    
    m_sampleData.measureDate = date;
    self.m_iboDate.text = stringFromDate(date);
}

@end
