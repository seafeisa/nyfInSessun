//
//  LineProgressView.m
//  
//
//  Created by Admin on 14-12-1.
//
//

#import "LineProgressView.h"

@implementation LineProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (void)_defaultInit
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.layer.shouldRasterize = YES;
    
    self.total = 51;
    self.color = [UIColor yellowColor];
    self.completed = 0;
    self.completedColor = [UIColor whiteColor];
    
    CGFloat r = MIN(self.frame.size.width, self.frame.size.height) / 2;
    self.radius = 0.875 * r;//r - 15;//105.0;
    self.innerRadius = 0.7 * r;//0.8 * (r - 15);//85.0;
    
    self.startAngle = M_PI * 0.72;
    self.endAngle = M_PI * 2.28;
    
    self.animationDuration = 2.0;
}

+ (Class)layerClass
{
    return [LineProgressLayer class];
}

- (void)setValue:(CGFloat)value
{
    if (value < _minValue)
    {
        _value = _minValue;
    }
    else if (value > _maxValue)
    {
        _value = _maxValue;
    }
    else
    {
        _value = value;
    }
    
    self.completed = roundf((_value - _minValue) / (_maxValue - _minValue) * _total);
}

- (void)setTotal:(int)total
{
    _total = total;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.total = total;
    [layer setNeedsDisplay];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.color = color;
    [layer setNeedsDisplay];
}

- (void)setCompletedColor:(UIColor *)completedColor
{
    _completedColor = completedColor;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.completedColor = completedColor;
    [layer setNeedsDisplay];
}

-(void)setCompleted:(int)completed
{
    [self setCompleted:completed animated:NO];
}

- (void)setCompleted:(int)completed animated:(BOOL)animated
{
    if (completed == self.completed)
    {
        return;
    }
    
    _completed = completed;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    if (animated && self.animationDuration > 0.0f)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"completed"];
        animation.duration = self.animationDuration;
        animation.fromValue = [NSNumber numberWithFloat:self.completed];
        animation.toValue = [NSNumber numberWithFloat:completed];
        animation.delegate = self;
        [self.layer addAnimation:animation forKey:@"currentAnimation"];
    }
    
    layer.completed = completed;
    [layer setNeedsDisplay];
}


- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.radius = radius;
    [layer setNeedsDisplay];
}

- (void)setInnerRadius:(CGFloat)innerRadius
{
    _innerRadius = innerRadius;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.innerRadius = innerRadius;
    [layer setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.startAngle = startAngle;
    [layer setNeedsDisplay];
}

- (void)setEndAngle:(CGFloat)endAngle
{
    _endAngle = endAngle;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.endAngle = endAngle;
    [layer setNeedsDisplay];
}

- (void)setAnimationDuration:(CFTimeInterval)animationDuration
{
    _animationDuration = animationDuration;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.animationDuration = animationDuration;
    [layer setNeedsDisplay];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(LineProgressViewAnimationDidStart:)]) {
        [self.delegate LineProgressViewAnimationDidStart:self];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(LineProgressViewAnimationDidStop:)]) {
        [self.delegate LineProgressViewAnimationDidStop:self];
    }
}

@end

