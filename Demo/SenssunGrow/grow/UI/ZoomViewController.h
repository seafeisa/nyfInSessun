//
//  ZoomViewController.h
//  grow
//
//  Created by admin on 15-4-30.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *ZoomViewbaifenweishuname;
@property (nonatomic, assign) WHOChartType type;
@property (nonatomic, strong) UIColor     *backgroundColor;
//@property (strong, nonatomic) IBOutlet UIView *backgoundView;
//@property (strong, nonatomic) IBOutlet WHOChildGrowthView *curveView;

@end
