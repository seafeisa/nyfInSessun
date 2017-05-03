//
//  AboutViewController.m
//  grow
//
//  Created by admin on 15-7-1.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "AboutViewController.h"



@interface AboutViewController ()

@property (strong, nonatomic) IBOutlet UILabel *m_iboAppName;
@property (strong, nonatomic) IBOutlet UITableView *m_iboAboutTable;

@end

@implementation AboutViewController
{
    NSArray *m_tableItems;
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
    _AboutViewLabelname.text = [AppData getString:@"about"];
    _Aboutxiangshanhengqi.text = [AppData getString:@"SenssunBaby"];
    _m_iboAppName.text = [AppData getString:@"Senssun baby"];
    
    NSString *Version = [AppData getString:@"version"];
    
    NSString *lateatVersion = [AppData getString:@"checknewvers"];
    
//    NSLog(@"52");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *section1 =@[Version]; /*@[LOCALSTR_VERSION];*/
    NSArray *section2 =@[lateatVersion]; //@[LOCALSTR_CHECK_VERSION];
    m_tableItems = @[section1, section2];

//    NSDictionary *infoDic  = [[NSBundle mainBundle] infoDictionary];
//    self.m_iboAppName.text = [infoDic objectForKey:@"CFBundleName"];
//    self.m_iboAppName.text = [[NSBundle mainBundle] localizedStringForKey:@"CFBundleName" value:@"宝贝成长" table:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self startConnectTimer];
}

- (void)startConnectTimer
{
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerConnect:) userInfo:nil repeats:NO];
}

- (void)timerConnect:(NSTimer *)timer
{
    NSString *URL = @"http://itunes.apple.com/lookup?id=965683200";
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString:URL]];
    [req setHTTPMethod:@"POST"];
    NSData *rcvData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
//    NSString *results = [[NSString alloc] initWithBytes:rcvData.bytes length:rcvData.length encoding:NSUTF8StringEncoding];
    //dbgLog(@"ver result:%@",results);
//    NSDictionary *dict = [results JSONValue];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rcvData options:NSJSONReadingMutableContainers error:nil];
    //dbgLog(@"ver dict:%@",dict);
    NSInteger resultCnt = [[dict objectForKey:@"resultCount"] integerValue];
    if (1 == resultCnt)
    {
        NSDictionary *releaseInfo = [[dict objectForKey:@"results"] firstObject];
        NSString *latestVersion = [releaseInfo objectForKey:@"version"];
        
        dbgLog(@"latestVer:%@",latestVersion);
    }
}

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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [m_tableItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[m_tableItems objectAtIndex:section] count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *header = @"";
//    if (1 == section)
//    {
//        header = @"  ";
//    }
//    
//    return header;
//}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    NSString *footer = @"";
//    if (0 == section)
//    {
//        footer = @"  ";
//    }
//    
//    return footer;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"versionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    NSString *title = [[m_tableItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *version     = [infoDic objectForKey:@"CFBundleShortVersionString"];
    //NSString *build       = [infoDic objectForKey:@"CFBundleVersion"];
    
    //获取对应的文字信息 
    if ([title isEqualToString:[AppData getString:@"version"]/*LOCALSTR_VERSION*/])
    {
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@.%@", version, build];
        cell.detailTextLabel.text = version;
    }
    else if ([title isEqualToString:[AppData getString:@"checknewvers"]/*LOCALSTR_CHECK_VERSION*/])
    {
        cell.detailTextLabel.text = [AppData getString:@"latestversion"]/*LOCALSTR_LATEST_VERSION*/;
    }
    
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
