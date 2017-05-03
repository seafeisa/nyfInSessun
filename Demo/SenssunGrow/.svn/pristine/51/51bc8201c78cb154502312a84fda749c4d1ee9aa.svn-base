//
//  ZoomViewController.m
//  grow
//
//  Created by admin on 15-4-30.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "WHOChildGrowthView.h"
#import "ZoomViewController.h"
//#import "AppData.h"


@interface ZoomViewController ()

@property (strong, nonatomic) IBOutlet WHOChildGrowthView *m_curveView;
@property (strong, nonatomic) IBOutlet UILabel *m_title;

@end

@implementation ZoomViewController

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
    _ZoomViewbaifenweishuname.text = [AppData getString:@"percentage"];
//    NSLog(@"42");
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //获取对应的文字信息 
    
    NSDictionary *dic = @{[NSNumber numberWithInt:WHO_CHART_WFA]:  [AppData getString:@"weit-age"]/*LOCALSTR_WEIGHT_FOR_AGE*/,
                          [NSNumber numberWithInt:WHO_CHART_HFA]:  [AppData getString:@"height-age"]/*LOCALSTR_HEIGHT_FOR_AGE*/,
                          [NSNumber numberWithInt:WHO_CHART_HCFA]: [AppData getString:@"head-age"]/*LOCALSTR_HEADCIRCLE_FOR_AGE*/,
                          [NSNumber numberWithInt:WHO_CHART_WFH]:  [AppData getString:@"height-weight"]/*LOCALSTR_WEIGHT_FOR_HEIGHT*/,
                         };

    self.m_title.text = [dic objectForKey:[NSNumber numberWithInt:self.type]];
    
    self.m_curveView.type = self.type;
    self.m_curveView.backgroundColor = self.backgroundColor;
    self.m_curveView.zoomEnabled = YES;
    
    // 添加双击手势关闭视图
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onDoubleTapView:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
    //WHOChildGrowthView *curveView = [[WHOChildGrowthView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
    //[self.m_backgoundView addSubview:curveView];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    //旋转当前的View
//    self.m_backgoundView.transform = CGAffineTransformMakeRotation(M_PI/2);
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    //CGRect frame = [UIScreen mainScreen].applicationFrame;
    //self.m_backgoundView.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    dbgLog(@"willRotateToInterfaceOrientation %zu, bg bounds:%@, curve bounds:%@", toInterfaceOrientation, NSStringFromCGRect(self.m_backgoundView.frame), NSStringFromCGRect(self.m_iboCurveView.frame));
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    dbgLog(@"didRotateFromInterfaceOrientation %zu, scrn:%@, bg:%@, curve:%@", fromInterfaceOrientation, NSStringFromCGRect([UIScreen mainScreen].bounds), NSStringFromCGRect(self.m_backgoundView.frame), NSStringFromCGRect(self.m_iboCurveView.frame));
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

#pragma mark - Actions
// 关闭视图
- (void)onDoubleTapView:(UITapGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:^{}];

    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
