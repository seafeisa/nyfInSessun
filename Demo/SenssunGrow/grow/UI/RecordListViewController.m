//
//  RecordListViewController.m
//  grow
//
//  Created by admin on 15-4-22.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "UserList.h"
#import "RecordViewController.h"
#import "RecordListViewController.h"

#define FMT_USER_RECORD @"%@:%.1f%@\t%@:%.1f%@\t%@:%.1f%@"

#define FMT_KG_WEIGHT_LABEL @"%.1f"
#define FMT_LB_WEIGHT_LABEL @"%.1f"
#define FMT_OZ_WEIGHT_LABEL @"%.1f"
#define FMT_LBOZ_WEIGHT_LABEL @"%.0f:%.0f"


@interface RecordListViewController ()
{

    NSMutableArray *DataOfCell;
    NSArray *TwoText;
    NSDate  *key;
    NSArray *sortKeys;
    NSString *one;
}

@property (strong, nonatomic) IBOutlet UITableView *m_iboRecordList;

@end

@implementation RecordListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(NSMutableArray *)DataOfCell{
//
//    if (DataOfCell == nil) {
//        DataOfCell = [NSMutableArray array];
//    }
//    return DataOfCell;
//}

- (void)viewDidLoad
{
    _RecordListAlldataname.text = [AppData getString:@"allData"];

    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    /**
     *  通知单位的监听转换
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnit) name:UnitDidChangedNotification object:nil];
    [self updateUnit];
    [self.m_iboRecordList reloadData];
    
}
#pragma mark 接到单位切换的通知后会调用此方法
-(void)updateUnit {
    self.currentUnit = [[NSUserDefaults standardUserDefaults] stringForKey:CurrentUnitKey];

    if ([self.currentUnit isEqualToString:@"kilogramUnit"]) {
        one = @"kg";
    }
    else if ([self.currentUnit isEqualToString:@"lbUnit"]) {
        one = @"lb";
    }
    else if ([self.currentUnit isEqualToString:@"ozUnit"]) {
        one = @"oz";
    }
    else if ([self.currentUnit isEqualToString:@"lbUnito"]) {
        one = @"lb:oz";
    }
    else {
        one = @"kg";
    }

    [[UserList sharedInstance].currentKid saveUserUnit:one];

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

    RecordViewController *destVC = [segue destinationViewController];
    if ([segue.identifier isEqualToString:SEGUE_ADD_RECORD])
    {
        destVC.accessMode = ACCESS_MODE_CREATE;
    }
    else if ([segue.identifier isEqualToString:SEGUE_EDIT_RECORD])
    {
        NSIndexPath *indexPath = [self.m_iboRecordList indexPathForCell:sender];
        destVC.selectedItem = indexPath.row;

        destVC.accessMode = ACCESS_MODE_UPDATE;
    }
}

- (IBAction)backToPreView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{}];
}




#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [[UserList sharedInstance].currentKid.recordList count];
}



//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:self atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

/** 编辑tableview进行删除*/
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    sortKeys = [[UserList sharedInstance].currentKid sortRecordKeys];
    
    key = [sortKeys objectAtIndex:indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[UserList sharedInstance].currentKid.recordList removeObjectForKey:key];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
//        else if (editingStyle == UITableViewCellEditingStyleInsert){
//
//        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//    }
    [self deleteData];
//    [tableView reloadData];
   

}

-(void)deleteData
{
    
    /* - (void)delRecord:(Record *)record
     {
     [self.recordList removeObjectForKey:record.measureDate];
     
     if (![m_db deleteRecord:record.measureDate fromUser:record.userName])
     {
     dbgLog(@"failed to delete[%@ %@] from db", record.userName, record.measureDate);
     }
     [m_db dump];
     }*/
    
    Record *recordDelete =[[Record alloc]init];
    recordDelete.userName = [UserList sharedInstance].currentKid.name;
    recordDelete.measureDate = key;
    [[UserList sharedInstance].currentKid delRecord:recordDelete];
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"userDataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
//    NSArray *
    sortKeys = [[UserList sharedInstance].currentKid sortRecordKeys];
    
//    NSLog(@"sortkeys内容为%@",sortKeys);
//    DataOfCell = [NSMutableArray arrayWithArray:sortKeys];
    
    
//    /* NSDate  * */key  = [DataOfCell objectAtIndex:indexPath.row];
        key = [sortKeys objectAtIndex:indexPath.row];
    
    
    Record  *data = [[UserList sharedInstance].currentKid.recordList objectForKey:key];
    
    NSString *unitWeight = [UserList sharedInstance].currentKid.unit;
    NSString *unitLength = nil;
    float maxHeight = DEV_SPEC_HEIGHT_MAX;
    float minHeight = DEV_SPEC_HEIGHT_MIN;
    float maxHeadCircle = DEV_SPEC_HEADCL_MAX;
    float minHeadCircle = DEV_SPEC_HEADCL_MIN;
//    float maxHeightlboz = DEV_SPEC_HEIGHTLBOZ_MAX;
//    float minHeightlboz = DEV_SPEC_HEIGHTLBOZ_MIN;
//    float maxHeadCirclelboz = DEV_SPEC_HEADCLLBOZ_MAX;
//    float minHeadCirclelboz = DEV_SPEC_HEADCLLBOZ_MIN;
//#define DEV_SPEC_HEIGHTLBOZ_MAX 32.0
//#define DEV_SPEC_HEIGHTLBOZ_MIN 18.0
//#define DEV_SPEC_HEADCLLBOZ_MAX 23.0
//#define DEV_SPEC_HEADCLLBOZ_MIN 12.0
    
    NSString *weightString = nil;
    float height = 0;
    float headCircle = 0;
    if (!unitWeight || [unitWeight isEqualToString:@""] || [unitWeight isEqualToString:@"kg"]) {
        unitWeight = @"kg";
        unitLength = @"cm";
        height = data.height;
        headCircle = data.headCircle;
    } else {
        unitLength = @"inch";
        maxHeight = floor(DEV_SPEC_HEIGHT_MAX * 101.0f / 256.0f * 10.0f) / 10.0f;
        minHeight = floor(DEV_SPEC_HEIGHT_MIN * 101.0f / 256.0f * 10.0f) / 10.0f;
        maxHeadCircle = floor(DEV_SPEC_HEADCL_MAX * 101.0f / 256.0f * 10.0f) / 10.0f;
        minHeadCircle = floor(DEV_SPEC_HEADCL_MIN * 101.0f / 256.0f * 10.0f) / 10.0f;
//        maxHeightlboz = floor(DEV_SPEC_HEIGHTLBOZ_MAX * 101.0f / 256.0f * 10.0f) / 10.0f;
//        minHeightlboz = floor(DEV_SPEC_HEIGHTLBOZ_MIN * 101.0f / 256.0f * 10.0f) / 10.0f;
//        maxHeadCirclelboz = floor(DEV_SPEC_HEADCLLBOZ_MAX * 101.0f / 256.0f * 10.0f) / 10.0f;
//        minHeadCirclelboz = floor(DEV_SPEC_HEADCLLBOZ_MIN * 101.0f / 256.0f * 10.0f) / 10.0f;
        height = data.height * 0.3937008f;
        headCircle = data.headCircle * 0.3937008f;
    }
    
    if ([unitWeight isEqualToString:@"kg"]) {
        weightString = [NSString stringWithFormat:FMT_KG_WEIGHT_LABEL, data.weight];
    } else if ([unitWeight isEqualToString:@"lb"]) {
        weightString = [NSString stringWithFormat:FMT_LB_WEIGHT_LABEL, data.weightLB];
    } else if ([unitWeight isEqualToString:@"oz"]) {
        weightString = [NSString stringWithFormat:FMT_OZ_WEIGHT_LABEL, floor(data.weightLB * 4100.0f / 256.0f * 10.0f) / 10.0f];
    } else if ([unitWeight isEqualToString:@"lb:oz"]) {
//        data.weightLB
//        float lb = 0;
//        if (data.weightOZ >= 16.0) {
//            float oz = data.weightOZ;
//            lb = oz/16.0;
//            oz = oz - lb * 16.0;
//            data.weightLB = data.weightLB + lb;
//            data.weightOZ = oz;
//            
//            
//        }else{
//            data.weightLB = data.weightLB + lb;
//            data.weightOZ = data.weightOZ;
//            
//        }
        weightString = [NSString stringWithFormat:@"%.0f:%0.f",data.weightLB,data.weightOZ];
//        NSLog(@"===%@===",weightString);
//        float oz = floor(data.weightLB * 4100.0f / 256.0f * 10.0f) / 10.0f;
//        float lb = floor(oz * 0.0625f);
//        oz = oz - lb * 16.0f;
//        weightString = [NSString stringWithFormat:FMT_LBOZ_WEIGHT_LABEL, lb, oz];
    }
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ \t\t%@", stringFromDate(data.measureDate), [[UserList sharedInstance].currentKid ageOnDate:data.measureDate]];

    NSString *title = stringFromDate(data.measureDate);
    title = [title stringByAppendingString:@"\t\t\t"];
    NSUInteger startPos = title.length;
    title = [title stringByAppendingString:[[UserList sharedInstance].currentKid ageOnDate:data.measureDate]];
    

    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedTitle setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(startPos, title.length - startPos)];
    cell.textLabel.attributedText = attributedTitle;
    
//    NSLog(@"celltextlabeltext里面的内容为%@",cell.textLabel.text);
    
    //cell.textLabel.text = stringFromDate(data.measureDate);
    
//    cell.detailTextLabel.text = [NSString stringWithFormat:FMT_USER_RECORD,
//                                 LOCALSTR_WEIGHT, data.weight, unitWeight,
//                                 LOCALSTR_HEIGHT, data.height, unitLength,
//                                 LOCALSTR_HEADCIRCLE, data.headCircle, unitLength
//                                ];
    //获取对应的文字信息 
    NSString *weight = [NSString stringWithFormat:@"%@:%@%@",[AppData getString:@"weiht"]/*LOCALSTR_WEIGHT*/, weightString, unitWeight];
    NSString *heights = [NSString stringWithFormat:@"%@:%.1f%@",[AppData getString:@"heiht"]/*LOCALSTR_HEIGHT*/, height, unitLength];
    NSString *headcl = [NSString stringWithFormat:@"%@:%.1f%@", [AppData getString:@"headsize"]/*LOCALSTR_HEADCIRCLE*/, headCircle, unitLength];
    
    if (minHeadCircle > headCircle) {
        headcl = [NSString stringWithFormat:@"%@:%.1f%@", [AppData getString:@"headsize"]/*LOCALSTR_HEADCIRCLE*/, minHeadCircle, unitLength];
    }else if (maxHeadCircle < headCircle){
        headcl = [NSString stringWithFormat:@"%@:%.1f%@", [AppData getString:@"headsize"]/*LOCALSTR_HEADCIRCLE*/, maxHeadCircle, unitLength];
    }
    if (minHeight > height){
        heights = [NSString stringWithFormat:@"%@:%.1f%@", [AppData getString:@"heiht"]/*LOCALSTR_HEIGHT*/, minHeight, unitLength];
    }else if (maxHeight < height){
        heights = [NSString stringWithFormat:@"%@:%.1f%@", [AppData getString:@"heiht"]/*LOCALSTR_HEIGHT*/, maxHeight, unitLength];
    }
    
//    if ((minHeadCircle > headCircle) || (maxHeadCircle < headCircle))
//    {
//        headcl = [NSString stringWithFormat:@"%@:%@%@", [AppData getString:@"headsize"]/*LOCALSTR_HEADCIRCLE*/, @" 不合理 ", unitLength];
//    }
//    if ((minHeight > height) || (maxHeight < height))
//    {
//        heights = [NSString stringWithFormat:@"%@:%@%@", [AppData getString:@"heiht"]/*LOCALSTR_HEIGHT*/, @" -- ", unitLength];
//    }

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t%@\t%@", weight, heights, headcl];
//    NSLog(@"celldetailtextlabel里面的内容为%@",cell.detailTextLabel.text);

//    NSLog(@"%@",[UserList sharedInstance].currentKid.recordList);
    
//    DataOfCell = [NSMutableArray
//                  arrayWithObject:[UserList sharedInstance].currentKid.recordList];
    
//    NSLog(@"数组内容为%@",DataOfCell);
    
    
    return cell;
    
}

@end
