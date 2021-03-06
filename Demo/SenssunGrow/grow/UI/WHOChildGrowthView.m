//
//  WHOChildGrowthView.m
//  grow
//
//  Created by admin on 15-4-8.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "WHOChildGrowthView.h"

@implementation WHOChildGrowthView
{
    UIScrollView *m_scrollView;     // 滑动、缩放
    GrowthCurve  *m_contentView;    // 图表
    GrowthCurve  *m_dimensionView;  // 标注尺寸
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize
{
//    NSLog(@"61");
    self.layer.cornerRadius = 8;
    
    _type        = WHO_CHART_WFA;
    _zoomEnabled = NO;
    
    // 页边空白
    UIEdgeInsets margin = UIEdgeInsetsMake(10, 20, 20, 10);
    CGRect scrollRect = CGRectMake(margin.left, margin.top,
                             self.bounds.size.width - margin.left -margin.right,
                             self.bounds.size.height - margin.top - margin.bottom);
    
    // 添加标尺层
    if (nil == m_dimensionView)
    {
        m_dimensionView = [[GrowthCurve alloc] initWithFrame:scrollRect];
    }
    m_dimensionView.type = _type;
    [self addSubview:m_dimensionView];

    // 添加scrollView，以支持缩放
    if (nil == m_scrollView)
    {
        m_scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
    }
    m_scrollView.contentSize = CGSizeMake(m_scrollView.bounds.size.width * 1, m_scrollView.bounds.size.height * 1);
    m_scrollView.backgroundColor = [UIColor whiteColor];
    m_scrollView.showsHorizontalScrollIndicator = NO;
    m_scrollView.showsVerticalScrollIndicator   = NO;
    //m_scrollView.directionalLockEnabled         = YES;
    m_scrollView.decelerationRate = 0;
    m_scrollView.bounces = NO;
    m_scrollView.bouncesZoom = NO;
    m_scrollView.maximumZoomScale = 2.0;
    m_scrollView.minimumZoomScale = 1.0;
    //m_scrollView.delegate = self;
    [self addSubview:m_scrollView];
    
    // contentView的可视区为scrollView的内容区
    CGRect contentRect = CGRectMake(0, 0, m_scrollView.contentSize.width, m_scrollView.contentSize.height);
    if (nil == m_contentView)
    {
        m_contentView = [[GrowthCurve alloc] initWithFrame:contentRect];
    }
    m_contentView.type = _type;
    m_contentView.showDimension = NO;
    [m_scrollView addSubview:m_contentView];
}

- (void)setType:(WHOChartType)type
{
    _type = type;
    
    // todo:设置curveView类型
    m_contentView.type = type;
    m_dimensionView.type = type;
}

- (void)setZoomEnabled:(BOOL)flag
{
    _zoomEnabled = flag; // 直接对变量赋值，不通过访问方法
    
    if (YES == flag)
    {
        m_scrollView.delegate = self;
    }
    else
    {
        m_scrollView.delegate = nil;
    }
}

//- (void)zoomAtScale:(CGFloat)scale
//{
//    m_scrollView.contentSize = CGSizeMake(m_scrollView.bounds.size.width * scale, m_scrollView.bounds.size.height * scale);
//    m_scrollView.contentOffset = CGPointMake(0, m_scrollView.bounds.size.height * (scale - 1));
//
//    m_contentView.frame = CGRectMake(0, 0, m_scrollView.contentSize.width, m_scrollView.contentSize.height);
//    [m_contentView setNeedsDisplay];
//    
//    [m_dimensionView repositionDimensionsWithOffset:CGPointZero atScale:scale];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //dbgLog(@"scrollViewDidScroll, offset:%@, size:%@, scale:%.1f", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize), scrollView.zoomScale);
    [m_dimensionView repositionDimensionsWithOffset:scrollView.contentOffset atScale:scrollView.zoomScale];
}

// 设置放大缩小的视图，要uiscrollview的subview
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //dbgLog(@"viewForZoomingInScrollView");
    
    return m_contentView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    //dbgLog(@"scrollViewWillBeginZooming, scale:%.1f", scrollView.zoomScale);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //dbgLog(@"scrollViewDidZoom, scale:%.1f", scrollView.zoomScale);
    [m_dimensionView repositionDimensionsWithOffset:scrollView.contentOffset atScale:scrollView.zoomScale];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //dbgLog(@"scrollViewDidEndZooming, scale:%.1f, offset:%@, size:%@", scale, NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize));
}

@end
