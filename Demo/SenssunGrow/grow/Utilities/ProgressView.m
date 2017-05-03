//
//  ProgressView.m
//  ProgressView
//
//  Created by Admin on 9/27/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import "ProgressView.h"
#import "UIColor+RGBValues.h"

@interface ProgressView ()
@property (nonatomic) CGFloat offset;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat stripeWidth;
@property (nonatomic, strong) UIImage *gradientProgress;
@property (nonatomic) CGSize stripeSize;

// Animation of progress
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic) CGFloat progressToAnimateTo;

//@property (nonatomic) CGFloat progress;
@end

@implementation ProgressView
@synthesize animate=_animate, color=_color;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    
    _color    = [UIColor whiteColor];
    _type     = ProgressSolid;
    _showText = @YES;
    _flat     = @YES;
    _animate  = @NO;
    _minValue = 0.0;
    _maxValue = 1.0;
    _value    = 0.0;
    _borderRadius = @5;
    _groundColor  = [UIColor colorWithRed:0.99 green:0.84 blue:0.68 alpha:1.0];
    _unit = @"cm";
}

- (void)setValue:(CGFloat)currentValue
{
    if (currentValue < _minValue)
    {
        _value = _minValue;
    }
    else if (currentValue > _maxValue)
    {
        _value = _maxValue;
    }
    else
    {
        _value = currentValue;
    }

    self.progress = (_value - _minValue) / (_maxValue - _minValue);
    if (0 == self.progress)
    {
        _showText = @NO;
    }
    else
    {
        _showText = @YES;
    }
}

- (void)setAnimate:(NSNumber *)animate {
    _animate = animate;
    if ([animate boolValue]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementOffset) userInfo:nil repeats:YES];
    } else if (self.timer) {
        [self.timer invalidate];
    }
}

- (void)setProgress:(CGFloat)progress {
    if ([_animate boolValue])
    {
        self.progressToAnimateTo = progress;
        if (self.animationTimer) {
            [self.animationTimer invalidate];
        }
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(incrementAnimatingProgress) userInfo:nil repeats:YES];
    }
    else
    {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

//- (CGFloat)progress
//{
//    CGFloat p;
//    if (_currentValue < _minValue)
//    {
//        p = 0.0;
//    }
//    else if (_currentValue > _maxValue)
//    {
//        p = 1.0;
//    }
//    else
//    {
//        p = (_currentValue - _minValue) / (_maxValue - _minValue);
//    }
//    
//    return p;
//}

- (void)incrementAnimatingProgress
{
    if ((_progress >= self.progressToAnimateTo - 0.01) && (_progress <= self.progressToAnimateTo + 0.01))
    {
        _progress = self.progressToAnimateTo;
        [self.animationTimer invalidate];
        [self setNeedsDisplay];
    }
    else
    {
        _progress = (_progress < self.progressToAnimateTo) ? _progress + 0.01 : _progress - 0.01;
        [self setNeedsDisplay];
    }
}

- (void)incrementOffset {
    if (self.offset >= 0) {
        self.offset = -self.stripeWidth;
    } else {
        self.offset += 1;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawProgressBackground:context inRect:rect];
//    if (self.progress > 0) {
//        [self drawProgress:context withFrame:rect];
//    }
    [self drawProgress:context withFrame:rect];
}

- (void)drawProgressBackground:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.borderRadius.floatValue];
    CGContextSetFillColorWithColor(context, self.groundColor.CGColor);
    [roundedRect fill];
    
//    UIBezierPath *roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect:CGRectMake(-10, -10, rect.size.width+10, rect.size.height+10)];
//    [roundedRectangleNegativePath appendPath:roundedRect];
//    roundedRectangleNegativePath.usesEvenOddFillRule = YES;
//
//    CGSize shadowOffset = CGSizeMake(0.5, 1);
//    CGContextSaveGState(context);
//    CGFloat xOffset = shadowOffset.width + round(rect.size.width);
//    CGFloat yOffset = shadowOffset.height;
//    CGContextSetShadowWithColor(context,
//            CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)), 5, [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor);
//
//    [roundedRect addClip];
//    CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(rect.size.width), 0);
//    [roundedRectangleNegativePath applyTransform:transform];
//    [[UIColor grayColor] setFill];
//    [roundedRectangleNegativePath fill];
    CGContextRestoreGState(context);
//
//    // Add clip for drawing progress
//    [roundedRect addClip];
}

- (void)drawProgress:(CGContextRef)context withFrame:(CGRect)frame
{
    CGRect rectToDrawIn = CGRectMake(0, 0, frame.size.width * self.progress, frame.size.height);
    //CGRect insetRect = CGRectInset(rectToDrawIn, self.progress > 0.03 ? 0.5 : -0.5, 0.5);
    CGRect insetRect = CGRectInset(rectToDrawIn, 0, 0);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:self.borderRadius.floatValue];
    if ([self.flat boolValue])
    {
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        [roundedRect fill];
    }
    else
    {
//        CGContextSaveGState(context);
//        [roundedRect addClip];
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGFloat locations[] = {0.0, 1.0};
//        NSArray *colors = @[(__bridge id)[self.color lighterColor].CGColor, (__bridge id)[self.color darkerColor].CGColor];
//        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
//        
//        CGContextDrawLinearGradient(context, gradient, CGPointMake(insetRect.size.width / 2, 0), CGPointMake(insetRect.size.width / 2, insetRect.size.height), 0);
//        CGContextRestoreGState(context);
//        
//        CGGradientRelease(gradient);
//        CGColorSpaceRelease(colorSpace);
    }

    if (self.progress != 1.0) {
        switch (self.type) {
            case ProgressGradient:
                [self drawGradients:context inRect:insetRect];
                break;
            case ProgressStripes:
                [self drawStripes:context inRect:insetRect];
                break;
            default:
                break;
        }
    }
    //CGContextSetStrokeColorWithColor(context, [[self.color darkerColor] darkerColor].CGColor);
    //[roundedRect stroke];

    if ([self.showText boolValue])
    {
        [self drawLabelInRect:frame];
    }
}

- (void)drawGradients:(CGContextRef)context inRect:(CGRect)rect {
    self.stripeSize = CGSizeMake(self.stripeWidth, rect.size.height);
    CGContextSaveGState(context);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.borderRadius.floatValue] addClip];
    CGFloat xStart = self.offset;
    while (xStart < rect.size.width) {
        [self.gradientProgress drawAtPoint:CGPointMake(xStart, 0)];
        xStart += self.stripeWidth;
    }
    CGContextRestoreGState(context);
}

- (void)drawStripes:(CGContextRef)context inRect:(CGRect)rect {
    CGContextSaveGState(context);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.borderRadius.floatValue] addClip];
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor);
    CGFloat xStart = self.offset, height = rect.size.height, width = self.stripeWidth;
    while (xStart < rect.size.width) {
        CGContextSaveGState(context);
        CGContextMoveToPoint(context, xStart, height);
        CGContextAddLineToPoint(context, xStart + width * 0.25, 0);
        CGContextAddLineToPoint(context, xStart + width * 0.75, 0);
        CGContextAddLineToPoint(context, xStart + width * 0.50, height);
        CGContextClosePath(context);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
        xStart += width;
    }
    CGContextRestoreGState(context);
}

- (void)drawRightAlignedLabelInRect:(CGRect)rect {
    if (rect.size.width > 40) {
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentRight;
        label.text = [NSString stringWithFormat:@"%.0f%%", self.progress*100];
        label.font = [UIFont boldSystemFontOfSize:17];
        UIColor *baseLabelColor = [self.color isLighterColor] ? [UIColor blackColor] : [UIColor whiteColor];
        label.textColor = [baseLabelColor colorWithAlphaComponent:0.6];
        [label drawTextInRect:CGRectMake(6, 0, rect.size.width-12, rect.size.height)];
    }
}

- (void)drawLabelInRect:(CGRect)rect
{
    CGRect left, right, frame;
    NSTextAlignment align;
    CGFloat width = rect.size.width * self.progress;
    CGRectDivide(rect, &left, &right, width, CGRectMinXEdge);
    
    NSString *title = [NSString stringWithFormat:@"%.1f%@", _value, _unit];
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSBackgroundColorAttributeName : [UIColor clearColor],
                                 };
    CGSize textSize = [title sizeWithAttributes:attributes];
    
    if (textSize.width > width)
    {
        frame = right;
        align = NSTextAlignmentLeft;
    }
    else
    {
        frame = left;
        align = NSTextAlignmentRight;
    }

    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = align;
    [label setAttributedText:[[NSAttributedString alloc] initWithString:title attributes:attributes]];
    [label drawTextInRect:frame];
}

#pragma mark - Accessors

- (UIImage *)gradientProgress {
    if (!_gradientProgress) {
        UIGraphicsBeginImageContext(self.stripeSize);
        CGContextRef imageCxt = UIGraphicsGetCurrentContext();

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = {0.0, 0.5, 1.0};
        NSArray *colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[[[self.color darkerColor] darkerColor] colorWithAlphaComponent:0.3].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);

        CGContextDrawLinearGradient(imageCxt, gradient, CGPointMake(0, self.stripeSize.height / 2), CGPointMake(self.stripeSize.width, self.stripeSize.height / 2), 0);

        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);

        _gradientProgress = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _gradientProgress;
}

- (NSNumber *)animate {
    if (_animate == nil) {
        return @YES;
    }
    return _animate;
}

- (NSNumber *)showText {
    if (_showText == nil) {
        return @YES;
    }
    return _showText;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.gradientProgress = nil;
}

- (UIColor *)color {
    if (!_color) {
        return [UIColor colorWithRed:0.07 green:0.56 blue:1.0 alpha:1.0];
    }
    return _color;
}

- (UIColor *)groundColor {
    if (!_groundColor) {
        return [UIColor colorWithRed:0.99 green:0.84 blue:0.68 alpha:1.0];
    }
    return _groundColor;
}

- (CGFloat)stripeWidth {
    switch (self.type) {
        case ProgressGradient:
            _stripeWidth = 15;
            break;
        default:
            _stripeWidth = 50;
            break;
    }
    return _stripeWidth;
}

- (NSNumber *)borderRadius {
    if (!_borderRadius) {
        return @(self.frame.size.height / 2.0);
    }
    return _borderRadius;
}

@end