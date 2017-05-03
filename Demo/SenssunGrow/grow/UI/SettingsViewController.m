//
//  SettingsViewController.m
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "SettingsViewController.h"
//#import "UnitSwitchViewController.h"

//#import "AppData.h"


@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *m_iboSettingList;
@property (weak, nonatomic) IBOutlet UILabel *Settingviewsettingname;

@property (strong, nonatomic) IBOutlet UILabel *m_iboVersion;
//@property (nonatomic, copy) NSString *currentUnit;
//@property (nonatomic, strong) UILabel *unitLabel;

@end

@implementation SettingsViewController
{
    
    NSArray *m_settingItems;
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
     [super viewDidLoad];
    NSString *device = [AppData getString:@"managedevice"];
    NSString *About = [AppData getString:@"about"];
    NSString *unit = [AppData getString:@"unit"];
    _m_iboVersion.text = [AppData getString:@""];
    _Settingviewsettingname.text = [AppData getString:@"setting"];
    
//    UILabel *unitLabel = [[UILabel alloc]init];
//    self.unitLabel = unitLabel;
//    
//    unitLabel.frame = CGRectMake(SCREEN_WIDTH - 80, 10, 40, 24);
//    if ([self.currentUnit isEqualToString:@"kilogramUnit"]) {
//        self.unitLabel.text = @"kg";
//    }
//    else if ([self.currentUnit isEqualToString:@"lbUnit"]) {
//        self.unitLabel.text = @"lb";
//    }
//    else if ([self.currentUnit isEqualToString:@"ozUnit"]) {
//        self.unitLabel.text = @"oz";
//    }
//    else if ([self.currentUnit isEqualToString:@"lbUnito"]) {
//        self.unitLabel.text = @"lb:oz";
//    }
//    else {
//        self.unitLabel.text = @"kg";
//    }
    //    NSLog(@"50  unit==%@",self.unitLabel);
    //    [self.m_iboSettingList reloadData];
    
    
    
    m_settingItems = @[device,About,unit];
//    [_m_iboSettingList reloadData];
    //获取对应的文字信息
    // @[LOCALSTR_DEV_MGR, LOCALSTR_ABOUT];
    
    //NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    
    //NSString *name      = [infoDic objectForKey:@"CFBundleName"];
    //NSString *version   = [infoDic objectForKey:@"CFBundleShortVersionString"];
    //NSString *build     = [infoDic objectForKey:@"CFBundleVersion"];
    //NSString *local     = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    //dbgLog(@"%@ %@.%@ local:%@",name,version,build,local);
    
    //self.m_iboVersion.text = [NSString stringWithFormat:@"Version %@.%@", version, build];
}

//-(void)viewWillAppear:(BOOL)animated {
//
//    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnit) name:UnitDidChangedNotification object:nil];
//    [self updateUnit];
//    
//}
#pragma mark 接到单位切换的通知后会调用此方法
//-(void)updateUnit {
//    self.currentUnit = [[NSUserDefaults standardUserDefaults] stringForKey:CurrentUnitKey];
////    NSLog(@"setting:====%@",self.currentUnit);
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backToPreView:(id)sender
{
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - TableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_settingItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //@"Copyright © 2015 Senssun. All Rights Reserved.";
    NSString *reuseIdentifier = @"settingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = [m_settingItems objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row)
    {
        case 0:
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"DeviceListViewController"]
                               animated:NO completion:^{}];
            break;
            
        case 1:
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"]
                               animated:NO completion:^{}];
            break;
        case 2:
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"UnitSwitchViewController"]
                               animated:NO completion:^{}];
            
        default:
            break;
    }
}

@end
