//
//  GrowthCurve.m
//  ChildGrowth
//
//  Created by admin on 14-11-5.
//  Copyright (c) 2014年 camry. All rights reserved.
//

#import "UserList.h"
#import "WHOStdData.h"
#import "UIBezierPath+Smoothing.h"
#import "GrowthCurve.h"

//extern NSMutableArray *g_bthData;

@implementation Line

- (id)init
{
    if(self=[super init]){
        self.width = 0.2;
        self.color = COLOR_DEFAULT_FONT;
    }
    return self;
}

@end

@implementation GrowthCurve {
    UIColor* m_grnColor;
    UIColor* m_ylwColor;
    UIColor* m_redColor;
    UIColor* m_blkColor;
    UIColor* m_bluColor;
    
    UILabel *m_yAxisUnit;   // y轴单位(cm/kg)
    UILabel *m_xAxisUnit;   // x轴单位(month/cm)
    
    NSMutableArray *m_yAxisLabels;
    NSMutableArray *m_xAxisLabels;

    NSMutableArray *m_percentilesLabels;

    CGPoint m_offset;
    CGFloat m_scale;
}

- (id)initWithFrame:(CGRect)frame
{
    // 标尺边留白
    //UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(0, 20, 20, 0));
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize
{
//    NSLog(@"66");
    _type = WHO_CHART_WFA;
    _showChart = YES;
    _showDimension = YES;
    m_scale  = 1.0;
    m_offset = CGPointZero;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    if (nil == self.m_axis)
    {
        self.m_axis = [[NSMutableArray alloc] init];
    }
    
    if (nil == self.m_usrPoints)
    {
        self.m_usrPoints = [[NSMutableArray alloc] init];
    }
    
    if (nil == m_yAxisLabels)
    {
        m_yAxisLabels = [[NSMutableArray alloc] init];
    }

    if (nil == m_xAxisLabels)
    {
        m_xAxisLabels = [[NSMutableArray alloc] init];
    }
    
    if (nil == m_yAxisUnit)
    {
        m_yAxisUnit = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 - DIMENDIONS_HEIGHT, DIMENSIONS_UNIT_WIDTH, DIMENDIONS_HEIGHT)];
        m_yAxisUnit.textColor = [UIColor whiteColor];
        m_yAxisUnit.font = [UIFont systemFontOfSize:DIMENDIONS_HEIGHT];
    }
    
    if (nil == m_xAxisUnit)
    {
        m_xAxisUnit = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height + DIMENDIONS_HEIGHT, DIMENSIONS_UNIT_WIDTH, DIMENDIONS_HEIGHT)];
        m_xAxisUnit.textColor = [UIColor whiteColor];
        m_xAxisUnit.font = [UIFont systemFontOfSize:DIMENDIONS_HEIGHT];
    }
    
    [self setAxesUnit];
    
    m_grnColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.0 alpha:1];
    m_ylwColor = [UIColor colorWithRed:0.8 green:0.3 blue:0.0 alpha:1];
    m_redColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1];
    m_blkColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    m_bluColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.8 alpha:1];
}

//- (void)willMoveToWindow:(UIWindow *)newWindow
//{
    // 重复绘制会产生重影，使字体变粗
    //[self setNeedsDisplay];
//}

- (void)setType:(WHOChartType)type
{
    _type = type;

    [self setAxesUnit];

    [self setNeedsDisplay];
}

- (void)setShowChart:(BOOL)flag
{
    _showChart = flag;
    
    [self setNeedsDisplay];
}

- (void)setShowDimension:(BOOL)flag
{
    _showDimension = flag;
    
    [self setNeedsDisplay];
}

// 标注坐标轴单位
- (void)setAxesUnit
{
    NSDictionary *yUnits = @{[NSNumber numberWithInt:WHO_CHART_WFA]:  @"kg",
                             [NSNumber numberWithInt:WHO_CHART_HFA]:  @"cm",
                             [NSNumber numberWithInt:WHO_CHART_HCFA]: @"cm",
                             [NSNumber numberWithInt:WHO_CHART_WFH]:  @"kg",
                             };
    NSDictionary *xUnits = @{[NSNumber numberWithInt:WHO_CHART_WFA]:  [AppData getString:@"Yues"]/*LOCALSTR_AGE_FOR_MONTH*/,
                             [NSNumber numberWithInt:WHO_CHART_HFA]:  [AppData getString:@"Yues"]/*LOCALSTR_AGE_FOR_MONTH*/,
                             [NSNumber numberWithInt:WHO_CHART_HCFA]: [AppData getString:@"Yues"]/*LOCALSTR_AGE_FOR_MONTH*/,
                             [NSNumber numberWithInt:WHO_CHART_WFH]:  @"cm",
                             };
    m_yAxisUnit.text = [yUnits objectForKey:[NSNumber numberWithInt:self.type]];
    m_xAxisUnit.text = [xUnits objectForKey:[NSNumber numberWithInt:self.type]];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Drawing code
    //dbgLog(@"drawing...");

    // 标尺
    [self drawAxis];
    
    if (_showChart)
    {
        // 标准曲线
        [self drawStdCurve];
        
        // 用户曲线
        [self drawUserCurve];
    }
}

- (void)drawAxis
{
    // 清除标注
    for (UILabel *label in m_yAxisLabels)
    {
        [label removeFromSuperview];
    }
    [m_yAxisLabels removeAllObjects];
    for (UILabel *label in m_xAxisLabels)
    {
        [label removeFromSuperview];
    }
    [m_xAxisLabels removeAllObjects];
    
    NSArray *axis = [self AxisLinesMakeWithRange:0 to:[self endOfXCoordiante]];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetStrokeColorWithColor(context, COLOR_DEFAULT_FONT.CGColor);
    CGContextSetLineWidth(context, 0.2);
    CGContextSetLineCap(context, kCGLineCapSquare);
    
    if (_showChart)
    {
        // 标尺
        for (Line *line in axis)
        {
            CGContextMoveToPoint(context, line.startPoint.x, line.startPoint.y);
            CGContextAddLineToPoint(context, line.endPoint.x, line.endPoint.y);
            CGContextSetLineWidth(context, line.width);
            CGContextSetStrokeColorWithColor(context, line.color.CGColor);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }

    if (_showDimension)
    {
        [self addSubview:m_yAxisUnit];
        [self addSubview:m_xAxisUnit];
        
        for (UILabel *label in m_yAxisLabels)
        {
            [self addSubview:label];
        }
        for (UILabel *label in m_xAxisLabels)
        {
            [self addSubview:label];
        }
    }
}

- (void)drawStdCurve
{
    NSArray *color = [NSArray arrayWithObjects:
                      m_redColor,//[UIColor redColor],
                      m_ylwColor,//[UIColor yellowColor],
                      m_grnColor,//[UIColor greenColor],
                      m_ylwColor,//[UIColor yellowColor],
                      m_redColor,//[UIColor redColor],
                      nil];

    // 百分位数
    if (nil == m_percentilesLabels)
    {
        m_percentilesLabels = [[NSMutableArray alloc] init];

        NSArray *percentiles = @[@"3rd", @"15th", @"50th", @"85th", @"97th"];
        for (NSString *text in percentiles)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, DIMENSIONS_UNIT_WIDTH, DIMENDIONS_HEIGHT)];
            label.text = text;
            label.font = [UIFont systemFontOfSize:DIMENSIONS_FONT_SIZE - 2];
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = [UIColor clearColor];

            [self addSubview:label];
            [m_percentilesLabels addObject:label];
        }
    }

    // 标准曲线
    for (int index = WHO_EXP_PMIN; index < WHO_EXP_PMAX; index++)
    {
        [[UIColor colorWithCIColor:[[CIColor alloc] initWithColor:color[index]]] set];
        
        NSArray *points = [self WHOCurveMake:index from:0 to:[self endOfXCoordiante]];
        [self drawSmoothBezier:points];

        CGPoint pt = [[points lastObject] CGPointValue];

        UILabel *label = [m_percentilesLabels objectAtIndex:index];
        label.frame = CGRectMake(pt.x - label.frame.size.width, pt.y - label.frame.size.height/2, label.frame.size.width, label.frame.size.height);
        label.textColor = color[index];
    }
}

- (NSArray *)AxisLinesMakeWithRange:(NSInteger)startPos to:(NSInteger)endPos
{
    // 获取图表属性
    WHOChartProperty property = [self ChartPropertyWithRange:startPos to:endPos];
    
    // 构造坐标系
    NSMutableArray *axis = [[NSMutableArray alloc] init];
    
    // x axis
    for (NSInteger i = 0, yCoordinate = property.minY; i <= property.numberOfYUnits; i++, yCoordinate++)
    {
        Line *line = [[Line alloc] init];
        line.startPoint = CGPointMake(0,                     self.frame.size.height - property.yUnit * i);
        line.endPoint   = CGPointMake(self.frame.size.width, self.frame.size.height - property.yUnit * i);
        [axis addObject:line];
        
        // 纵坐标
        if (![self needsYDimensions:yCoordinate]) continue;
        [self addDimensions:yCoordinate atPoint:line.startPoint forAxis:AXIS_Y];

        //line.width = 0.3;
        line.color = [UIColor blackColor];
    }
    
    // y axis
    for (NSInteger i = 0, xCoordinate = property.minX; i <= property.numberOfXUnits; i++, xCoordinate++)
    {
        if ((WHO_CHART_WFH == _type) && (0 != i % 2)) continue;

        Line *line = [[Line alloc] init];
        line.startPoint = CGPointMake(property.xUnit * i, self.frame.size.height);
        line.endPoint   = CGPointMake(property.xUnit * i, 0);
        [axis addObject:line];
        
        if (WHO_CHART_WFH == _type)
        {
            xCoordinate = MIN_X_WFH + i/2;
            
            if (0 == xCoordinate % 5)
            {
                line.width = 0.3;
                line.color = [UIColor blackColor];
            }
        }
        else
        {
            if (0 == xCoordinate % MONTHS_PER_YEAR)
            {
                line.width = 0.5;
                line.color = [UIColor blackColor];
            }
        }
        
        // 横坐标
        if (![self needsXDimensions:xCoordinate]) continue;
        [self addDimensions:xCoordinate atPoint:line.startPoint forAxis:AXIS_X];
    }
    
    return axis;
}

- (NSArray *)WHOCurveMake:(WHOExpID)curveID from:(NSInteger)startPos to:(NSInteger)endPos
{
    // 获取标准数据表
    NSInteger totalStdPoints = 0;
    const float (*expArray)[WHO_EXP_PMAX] = [self getWHODataTableByType:_type total:&totalStdPoints];
    
    // 获取图表属性
    WHOChartProperty property = [self ChartPropertyWithRange:startPos to:endPos];
    
    // 构造标准点序列
    NSMutableArray * points = [[NSMutableArray alloc] init];
    for (int i = 0; i <= property.numberOfXUnits; i++)
    {
        CGPoint pt = CGPointMake(property.xUnit * i, self.frame.size.height - (expArray[property.minX + i][curveID] - property.minY) * property.yUnit);
        
        [points addObject:[NSValue valueWithCGPoint:pt]];
    }
    
    // 插入控制点调整起始线形
    [self insertCtrlPointInArray:points];
    
    return points;
}

- (void)drawSmoothBezier:(NSArray *)points
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path setLineWidth: 1];
    [path setLineCapStyle:kCGLineCapRound];
    
    // 始点
    [path moveToPoint: [points[0] CGPointValue]];
    
    NSInteger numberOfPoints = [points count];
    for(int i = 1; i < numberOfPoints; i++)
    {
        // 只选其中几个特征点，更平滑
        if (!([self isKeyPoint:i] || (i == numberOfPoints - 1))) continue;
        
        CGPoint pt = [points[i] CGPointValue];
        
        [path addLineToPoint: pt];
    }
    
    // 平滑处理
    UIBezierPath *smoothPath = [path smoothedPathWithGranularity:20 minY:0 maxY:self.frame.size.height];
    //[smoothPath stroke];
    [smoothPath strokeWithBlendMode:kCGBlendModeNormal alpha:0.5];
}

- (void)drawUserCurve
{
    // 获取用户数据
    UserProfile *currentKid = [UserList sharedInstance].currentKid;
    NSArray *datelist = [currentKid sortRecordKeys];

    NSMutableArray *usrPoints = [NSMutableArray array];
    for (NSDate *date in datelist)
    {
        Record *userData = [currentKid.recordList objectForKey:date];
        
        CGPoint point = [self UserPointMake:userData];
        if ((-1 == point.x) || (-1 == point.y))
        {
            // invalid data
            continue;
        }
        
        [usrPoints addObject:[NSValue valueWithCGPoint:point]];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 1);
    
    // 连线
    NSInteger numberOfPoints = [usrPoints count];
    for (int i = 0 ; i < numberOfPoints - 1; i++)
    {
        CGPoint startPoint  = [[usrPoints objectAtIndex:i] CGPointValue];
        CGPoint endPoint    = [[usrPoints objectAtIndex:(i + 1)] CGPointValue];
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        
        [m_bluColor set];
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    // 画点
    for (int i = 0 ; i < numberOfPoints; i++)
    {
        CGFloat radius = 3;
        CGPoint point  = [[usrPoints objectAtIndex:i] CGPointValue];
        CGContextSetFillColorWithColor(context, m_bluColor.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(point.x - radius, point.y - radius, 2 * radius, 2 * radius));

        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(point.x - radius/2, point.y - radius/2, radius, radius));
        
        //CGContextFillPath(context);
    }
}

- (CGPoint)UserPointMake:(Record *)userData
{
    NSDateComponents *age = [[UserList sharedInstance].currentKid ageWithDate:userData.measureDate];
    
    CGFloat y = userData.weight;
    CGFloat x = age.year * MONTHS_PER_YEAR + age.month + age.day / WHO_DAYS_PER_MONTH;
    
    // 获取图表属性
    WHOChartProperty property = [self ChartPropertyWithRange:0 to:[self endOfXCoordiante]];
    
    switch (_type)
    {
        case WHO_CHART_WFA:
            y = userData.weight;
            break;
            
        case WHO_CHART_HFA:
            y = userData.height;
            break;
            
        case WHO_CHART_HCFA:
            y = userData.headCircle;
            break;
            
        case WHO_CHART_WFH:
            y = userData.weight;
            x = (userData.height - MIN_X_WFH) * 2;
            break;
            
        case WHO_CHART_BMI:
            y = userData.BMI;
            break;
            
        default:
            break;
    }

    if ((x < property.minX) || (x > property.maxX))
    {
        x = -1;
    }
    else
    {
        x = (x - property.minX) * property.xUnit;
    }

    if ((y < property.minY) || (y > property.maxY))
    {
        y = -1;
    }
    else
    {
        y = (property.maxY - y) * property.yUnit;
    }

    return CGPointMake(x, y);
}

- (WHOChartProperty)ChartPropertyWithRange:(NSInteger)minPos to:(NSInteger)maxPos
{
    // 根据图表类型和性别获取标准数据表
    NSInteger totalStdPoints = 0;
    const float (*expArray)[WHO_EXP_PMAX] = [self getWHODataTableByType:_type total:&totalStdPoints];
    
    // 参数校验
    [self WHOPointsVerify:totalStdPoints start:&minPos end:&maxPos];
    
    // max min integer y value
    NSInteger maxY = expArray[maxPos][WHO_EXP_P97];
    NSInteger minY = expArray[minPos][WHO_EXP_P3];
    
    for (NSInteger i = minPos; i <= maxPos; i++)
    {
        maxY = (maxY < expArray[i][WHO_EXP_P97]) ? expArray[i][WHO_EXP_P97] : maxY;
    }
    maxY += CURVE_TOP_MARGIN;
    
    for (NSInteger i = minPos; i <= maxPos; i++)
    {
        minY = (minY > expArray[i][WHO_EXP_P3]) ? expArray[i][WHO_EXP_P3] : minY;
    }
    minY -= CURVE_BOTTOM_MARGIN;
    
    // max min integer x value
    NSInteger maxX = maxPos;
    NSInteger minX = minPos;
    
    // 标尺数
    NSInteger numberOfYUnits = maxY - minY;
    NSInteger numberOfXUnits = maxX - minX;
    
    // 单位长度
    CGFloat yUnit = self.frame.size.height / numberOfYUnits;
    CGFloat xUnit = self.frame.size.width / numberOfXUnits;
    
    WHOChartProperty property = {0};
    property.maxX = maxX;
    property.minX = minX;
    property.maxY = maxY;
    property.minY = minY;
    property.xUnit = xUnit;
    property.yUnit = yUnit;
    property.numberOfXUnits = numberOfXUnits;
    property.numberOfYUnits = numberOfYUnits;
    
    return property;
}

- (const float (*)[WHO_EXP_PMAX])getWHODataTableByType:(WHOChartType)chartType total:(NSInteger*)numberOfPoints //gender:(BOOL)isFemale
{
    // 根据图表类型和性别获取标准数据表
    const float (*expArray)[WHO_EXP_PMAX] = boysWFA;
    *numberOfPoints = sizeof(boysWFA) / (sizeof(float) * WHO_EXP_PMAX);
    
    ENGender gender = [UserList sharedInstance].currentKid.gender;
    switch (chartType)
    {
        case WHO_CHART_WFA:
        {
            expArray = (GENDER_FEMALE == gender) ? girlsWFA : boysWFA;
            *numberOfPoints = sizeof(boysWFA) / (sizeof(float) * WHO_EXP_PMAX);
            break;
        }
            
        case WHO_CHART_HFA:
        {
            expArray = (GENDER_FEMALE == gender) ? girlsHFA : boysHFA;
            *numberOfPoints = sizeof(boysHFA) / (sizeof(float) * WHO_EXP_PMAX);
            break;
        }
            
        case WHO_CHART_WFH:
        {
            expArray = (GENDER_FEMALE == gender) ? girlsWFH : boysWFH;
            *numberOfPoints = sizeof(boysWFH) / (sizeof(float) * WHO_EXP_PMAX);
            break;
        }
            
        case WHO_CHART_BMI:
        {
            expArray = (GENDER_FEMALE == gender) ? girlsBMI : boysBMI;
            *numberOfPoints = sizeof(boysBMI) / (sizeof(float) * WHO_EXP_PMAX);
            break;
        }
            
        case WHO_CHART_HCFA:
        {
            expArray = (GENDER_FEMALE == gender) ? girlsHCFA : boysHCFA;
            *numberOfPoints = sizeof(boysHCFA) / (sizeof(float) * WHO_EXP_PMAX);
            break;
        }
            
        default:
            break;
    }
    
    return expArray;
}

- (void)WHOPointsVerify:(NSInteger)totalStdPoints start:(NSInteger*)startPos end:(NSInteger*)endPos
{
    // 参数校验
    if (*startPos < 0)
    {
        *startPos = 0;
    }
    if (*startPos > (totalStdPoints - 2))
    {
        *startPos = totalStdPoints - 2;
    }
    
    if (MAX_POS == *endPos)
    {
        *endPos = totalStdPoints - 1;
    }
    if (*endPos < 1)
    {
        *endPos = 1;
    }
    if (*endPos > (totalStdPoints - 1))
    {
        *endPos = totalStdPoints - 1;
    }
    
    if (*endPos <= *startPos)
    {
        *endPos = *startPos + 1;
    }
}

- (BOOL)isKeyPoint:(NSInteger)pos //forChart:(WHOChartType)type
{
    BOOL result = YES;
    switch (_type)
    {
        case WHO_CHART_WFA:
            result = ((pos == 1) || (pos == 7));
            break;

        case WHO_CHART_HFA:
        case WHO_CHART_HCFA:
            result = ((pos == 1) || (pos == 5) || (pos == 12));
            break;

        case WHO_CHART_WFH:
            result = ((pos == 10) || (pos == 30) || (pos == 90));
            break;
            
        case WHO_CHART_BMI:
            result = ((pos == 1) || (pos == 6) || (pos == 20));
            break;
            
        default:
            break;
    }
    
    return result;
}

- (void)insertCtrlPointInArray:(NSMutableArray *)pointsArray //forChart:(WHOChartType)type
{
    CGFloat X0 = [pointsArray[0] CGPointValue].x;
    CGFloat Y0 = [pointsArray[0] CGPointValue].y;
    CGPoint ctrlPt;
    switch (_type)
    {
        case WHO_CHART_WFA:
            [pointsArray insertObject:pointsArray[0] atIndex:1];
            break;
            
        case WHO_CHART_HFA:
            ctrlPt = CGPointMake(X0 + 1, Y0 - 3);   // 可能要考虑缩放变化，不能写死
            [pointsArray insertObject:[NSValue valueWithCGPoint:ctrlPt] atIndex:1];
            break;
            
        case WHO_CHART_WFH:
            break;
            
        case WHO_CHART_BMI:
            ctrlPt = CGPointMake(X0 + 1, Y0 + 6);
            [pointsArray insertObject:[NSValue valueWithCGPoint:ctrlPt] atIndex:1];
            break;
            
        case WHO_CHART_HCFA:
            ctrlPt = CGPointMake(X0 + 1, Y0 - 3);
            [pointsArray insertObject:[NSValue valueWithCGPoint:ctrlPt] atIndex:1];
            break;
            
        default:
            break;
    }
    
}

- (BOOL)needsXDimensions:(NSInteger)value //byChart:(WHOChartType)type
{
    BOOL result = YES;
    switch (_type)
    {
        case WHO_CHART_WFA:
        case WHO_CHART_HFA:
        case WHO_CHART_BMI:
        case WHO_CHART_HCFA:
            result = (0 == value % 2) && (0 != value);
            break;
            
        case WHO_CHART_WFH:
            result = (0 == value % 5);
            break;
            
        default:
            break;
    }
    
    return result;
}

- (BOOL)needsYDimensions:(NSInteger)value //byChart:(WHOChartType)type
{
    BOOL result = YES;
    switch (_type)
    {
        case WHO_CHART_WFA:
        case WHO_CHART_WFH:
        case WHO_CHART_HCFA:
            result = (0 == value % 2);
            break;
            
        case WHO_CHART_HFA:
            result = (0 == value % 5);
            break;
            
        case WHO_CHART_BMI:
            result = (0 == value % 1);
            break;
            
        default:
            break;
    }
    
    return result;
}

- (void)addDimensions:(NSInteger)value atPoint:(CGPoint)point forAxis:(ENAxisType)axis
{
    CGFloat x = point.x - DIMENSIONS_WIDTH/2;
    CGFloat y = point.y;
    if (AXIS_Y == axis)
    {
        x = point.x - DIMENSIONS_WIDTH;
        y = point.y - DIMENDIONS_HEIGHT/2;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, DIMENSIONS_WIDTH, DIMENDIONS_HEIGHT)];
    label.text = [NSString stringWithFormat:@"%ld", (long)value];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:DIMENDIONS_HEIGHT];

    if (AXIS_Y == axis)
    {
        [m_yAxisLabels addObject:label];
    }
    else
    {
        [m_xAxisLabels addObject:label];
    }
}

- (NSInteger)endOfXCoordiante
{
    return (WHO_CHART_WFH == _type) ? MAX_POS : 2 * MONTHS_PER_YEAR;
}

//- (void)repositionDimensionsWithScale:(CGFloat)scale
//{
//    CGPoint viewOrg = CGPointMake(0, self.bounds.size.height);
//    CGPoint userOrg = CGPointMake(0, self.bounds.size.height);
//    
//    for (UILabel *label in m_yAxisLabels)
//    {
//        // y'=Yo'+(y-Yo)*S
//        CGFloat y = userOrg.y + (label.center.y - viewOrg.y) * scale/m_scale - DIMENDIONS_HEIGHT/2;
//        label.frame = CGRectMake(label.frame.origin.x, y, label.bounds.size.width, label.bounds.size.height);
//        
//        label.hidden = ((label.center.y < 0-0.1) || (label.center.y > self.bounds.size.height+0.1)) ? YES : NO;
//    }
//    
//    for (UILabel *label in m_xAxisLabels)
//    {
//        CGFloat x = userOrg.x + (label.center.x - viewOrg.x) * scale/m_scale - DIMENSIONS_WIDTH/2;
//        label.frame = CGRectMake(x, label.frame.origin.y, label.bounds.size.width, label.bounds.size.height);
//        
//        label.hidden = ((label.center.x < 0-0.1) || (label.center.x > self.bounds.size.width+0.1)) ? YES : NO;
//    }
//    
//    m_scale  = scale;
//    m_offset = CGPointMake(0, self.bounds.size.height * (scale - 1));
//}

- (void)repositionDimensionsWithOffset:(CGPoint)offset atScale:(CGFloat)scale
{
    for (UILabel *label in m_yAxisLabels)
    {
        // y"=(y'+offset')*s"/s'-offset"
        CGFloat y = (label.center.y + m_offset.y) * scale / m_scale - offset.y - DIMENDIONS_HEIGHT/2;
        label.frame = CGRectMake(label.frame.origin.x, y, label.bounds.size.width, label.bounds.size.height);
        
        label.hidden = ((label.center.y < 0-0.1) || (label.center.y > self.bounds.size.height+0.1)) ? YES : NO;
    }
    
    for (UILabel *label in m_xAxisLabels)
    {
        // x"=(x'+offset')*s"/s'-offset"
        CGFloat x = (label.center.x + m_offset.x) * scale / m_scale - offset.x - DIMENSIONS_WIDTH/2;
        label.frame = CGRectMake(x, label.frame.origin.y, label.bounds.size.width, label.bounds.size.height);
        
        label.hidden = ((label.center.x < 0-0.1) || (label.center.x > self.bounds.size.width+0.1)) ? YES : NO;
    }
    
    m_scale  = scale;
    m_offset = offset;
}

@end