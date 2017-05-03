//
//  WHOChildGrowthView.h
//  grow
//
//  Created by admin on 15-4-8.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowthCurve.h"

@interface WHOChildGrowthView : UIView <UIScrollViewDelegate>

//@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, assign) WHOChartType type;
@property (nonatomic, assign) BOOL zoomEnabled;

//- (void)zoomAtScale:(CGFloat)scale;

@end
