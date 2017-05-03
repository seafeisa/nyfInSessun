//
//  UnitSwitchViewController.m
//  grow
//
//  Created by admin on 16/8/11.
//  Copyright © 2016年 senssun. All rights reserved.
//

#import "UnitSwitchViewController.h"

@interface UnitSwitchViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger current;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *currentUnit;


@end

@implementation UnitSwitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.905 green:0.914 blue:0.939 alpha:1.000];
    
    //    [self setupNAV];
    [self setupTableView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnit) name:UnitDidChangedNotification object:nil];
    current = [[NSUserDefaults standardUserDefaults] integerForKey:SavedUnitKey];
    [self updateUnit];
}

#pragma mark 接到单位切换的通知后会调用此方法
-(void)updateUnit {
    self.currentUnit = [[NSUserDefaults standardUserDefaults] stringForKey:CurrentUnitKey];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)current] forKey:SavedUnitKey];
    //    [[NSNotificationCenter defaultCenter]postNotificationName:UnitDidChangedNotification object:self];
}

-(void)setupTableView
{
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 150) style:UITableViewStylePlain];
    
    self.tableView = tableView;
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    tableView.bounces = NO;
    
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:tableView];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
}
- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:^{}];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *unit = [[UILabel alloc]init];
    
    unit.textAlignment = NSTextAlignmentCenter;
    
    unit.frame = CGRectMake((SCREEN_WIDTH * 0.5 - 30),10, 60, 30);
    //    unit.backgroundColor = [UIColor redColor];
    [cell.contentView addSubview:unit];
    indexPath.row == current ? (cell.accessoryType =UITableViewCellAccessoryCheckmark) : (cell.accessoryType =UITableViewCellAccessoryNone );
    if (indexPath.row == 0) {
        unit.text = @"kg";
    }
    else if (indexPath.row == 1) {
        unit.text = @"lb";
    }
    else if (indexPath.row == 2) {
        unit.text = @"oz";
    }
    //    else{
    //        unit.text = @"lb:oz";
    //    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType =UITableViewCellAccessoryCheckmark ;
    
    if (indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:kilogramUnit forKey:CurrentUnitKey];
    }else if (indexPath.row == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:lbUnit forKey:CurrentUnitKey];
    }
    else if (indexPath.row == 2){
        [[NSUserDefaults standardUserDefaults] setObject:ozUnit forKey:CurrentUnitKey];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:lbUnito forKey:CurrentUnitKey];
    }
    current = indexPath.row ;
    [self.tableView reloadData];
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType =UITableViewCellAccessoryNone ;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
