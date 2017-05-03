//
//  CurveViewController.m
//  grow
//
//  Created by admin on 15-4-10.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "WHOChildGrowthView.h"
#import "ZoomViewController.h"
#import "CurveViewController.h"
//#import "AppData.h"


@interface CurveViewController ()

@property (strong, nonatomic) IBOutlet WHOChildGrowthView *m_iboWeightView;
@property (strong, nonatomic) IBOutlet WHOChildGrowthView *m_iboHeightView;
@property (strong, nonatomic) IBOutlet WHOChildGrowthView *m_iboHeadcircleView;
@property (strong, nonatomic) IBOutlet WHOChildGrowthView *m_iboWFHView;


@end

@implementation CurveViewController

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
   
    [_CurveViewAlldataTitle setTitle:[AppData getString:@"allData"] forState:UIControlStateNormal];
    _CurveViewgrowthname.text = [AppData getString:@"growthCurve"];
    _Heightforweight.text = [AppData getString:@"height-weight"];
    _baifenweishudown.text = [AppData getString:@"percentage"];
    _Ageforheadsize.text = [AppData getString:@"head-age"];
    _baifenweishudown1.text = [AppData getString:@"percentage"];
    _TextNamegrowthcurve.text = [AppData getString:@"growthCurve"];
    [_ButtontitleAlldata setTitle:[AppData getString:@"allData"] forState:UIControlStateNormal];
    _Ageforweight.text = [AppData getString:@"weit-age"];
    _baifenweishu.text = [AppData getString:@"percentage"];
    _Ageforheight.text = [AppData getString:@"height-age"];
    _baifenweishu1.text = [AppData getString:@"percentage"];
 
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_iboWeightView.type = WHO_CHART_WFA;
    
    self.m_iboHeightView.type = WHO_CHART_HFA;
    
    self.m_iboHeadcircleView.type = WHO_CHART_HCFA;
    
    self.m_iboWFHView.type = WHO_CHART_WFH;
    //self.m_iboWFHView.zoomEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView
{
    self.m_iboWeightView.type = WHO_CHART_WFA;
    self.m_iboHeightView.type = WHO_CHART_HFA;
    self.m_iboHeadcircleView.type = WHO_CHART_HCFA;
    self.m_iboWFHView.type = WHO_CHART_WFH;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    ZoomViewController *destVC = [segue destinationViewController];
    if ([segue.identifier isEqualToString:SEGUE_ZOOMIN_WFA])
    {
        destVC.type            = WHO_CHART_WFA;
        destVC.backgroundColor = self.m_iboWeightView.backgroundColor;
    }
    else if ([segue.identifier isEqualToString:SEGUE_ZOOMIN_HFA])
    {
        destVC.type            = WHO_CHART_HFA;
        destVC.backgroundColor = self.m_iboHeightView.backgroundColor;
    }
    else if ([segue.identifier isEqualToString:SEGUE_ZOOMIN_HCFA])
    {
        destVC.type            = WHO_CHART_HCFA;
        destVC.backgroundColor = self.m_iboHeadcircleView.backgroundColor;
    }
    else if ([segue.identifier isEqualToString:SEGUE_ZOOMIN_WFH])
    {
        destVC.type            = WHO_CHART_WFH;
        destVC.backgroundColor = self.m_iboWFHView.backgroundColor;
    }
}

- (IBAction)backToPreView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)backToLastPage:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Action

@end
