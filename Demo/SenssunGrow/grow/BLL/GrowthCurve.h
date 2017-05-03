//
//  GrowthCurve.h
//  ChildGrowth
//
//  Created by admin on 14-11-5.
//  Copyright (c) 2014年 camry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct _stWHOChartProperty
{
    NSInteger maxY;     // y轴最大值
    NSInteger minY;     // y轴最小值
    NSInteger maxX;     // x轴最大值
    NSInteger minX;     // x轴最小值
    
    NSInteger numberOfYUnits;   // y轴单位长度数
    NSInteger numberOfXUnits;   // x轴单位长度数
    
    CGFloat yUnit;      // y轴单位长度
    CGFloat xUnit;      // x轴单位长度
} WHOChartProperty;

typedef enum _tagWHOChartType
{
    WHO_CHART_WFA = 0,
    WHO_CHART_HFA,
    WHO_CHART_WFH,
    WHO_CHART_BMI,
    WHO_CHART_HCFA,
    
    WHO_CHART_BUTT
} WHOChartType;

typedef enum _tagAxisType
{
    AXIS_X = 0,
    AXIS_Y
    
} ENAxisType;

enum
{
    DAYS_PER_WEEK    = 7,
    DAYS_PER_MONTH   = 30,
    WEEKS_PER_SEASON = 13,
    MONTHS_PER_YEAR  = 12,

    CHART_ORIGIN_X  = 30,
    CHART_ORIGIN_Y  = 300,
    
    CHART_WIDTH     = (320 - 30 -20),
    CHART_HEIGHT    = 300,
    
    CURVE_TOP_MARGIN = 1,
    CURVE_BOTTOM_MARGIN = 1,
    
    CHART_ZOOM_RATE = 25,
    
    DIMENSIONS_UNIT_WIDTH = 80,
    DIMENSIONS_WIDTH = 20,
    DIMENDIONS_HEIGHT = 10,
    DIMENSIONS_FONT_SIZE = 10,
    
    MIN_X_WFH = 45,
    
    MALE   = 0,
    FEMALE = 1,
    
    MAX_POS = -1,
    
    CHART_BUTT
};

// 直线
@interface Line : NSObject

@property (nonatomic, assign) CGPoint  startPoint;
@property (nonatomic, assign) CGPoint  endPoint;
@property (nonatomic, assign) CGFloat  width;
@property (nonatomic, strong) UIColor* color;

@end

// 绘图
@interface GrowthCurve : UIView

@property (nonatomic, assign) WHOChartType type;
@property (nonatomic, assign) BOOL showDimension;
@property (nonatomic, assign) BOOL showChart;

@property (nonatomic, strong) NSMutableArray* m_axis;       // 标尺线
//@property (nonatomic, strong) NSMutableArray* m_lines;      // 直线
//@property (nonatomic, strong) NSMutableArray* m_stdPoints;  // 标准空间, NSValue <-> CGPoint 对象
@property (nonatomic, strong) NSMutableArray* m_usrPoints;  // 用户空间, NSValue <-> CGPoint 对象

//- (void)repositionDimensionsWithScale:(CGFloat)scale;
- (void)repositionDimensionsWithOffset:(CGPoint)offset atScale:(CGFloat)scale;

@end
