//
//  LineProgressLayer.m
//  
//
//  Created by Admin on 14-12-1.
//
//

#import "LineProgressLayer.h"

@implementation LineProgressLayer

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self)
    {
        if ([layer isKindOfClass:[LineProgressLayer class]])
        {
            LineProgressLayer *other = layer;
            self.total = other.total;
            self.color = other.color;
            self.completed = other.completed;
            self.completedColor = other.completedColor;
            
            self.radius = other.radius;
            self.innerRadius = other.innerRadius;
            
            self.startAngle = other.startAngle;
            self.endAngle = other.endAngle;
            self.shouldRasterize = YES;
        }
    }
    
    return self;
}

+ (id)layer
{
    LineProgressLayer *result = [[LineProgressLayer alloc] init];
    
    return result;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"completed"])
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)contextRef
{
    CGFloat totalAngle = _endAngle - _startAngle;
    
    CGRect rect = self.bounds;
    
    CGFloat x0 = rect.size.width/2.0;
    CGFloat y0 = rect.size.height/2.0;
    
    CGContextSetLineJoin(contextRef, kCGLineJoinRound);
    //CGContextSetFlatness(contextRef, 2.0);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetShouldAntialias(contextRef, true);
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationHigh);
    
    CGContextSetLineWidth(contextRef,2.0f);     //设置线条宽度
    
    
    for (int i = 0; i < _completed; i++)
    {
        CGFloat x1 = x0 + cosf(_startAngle + totalAngle*i/(_total - 1))*_innerRadius;
        CGFloat y1 = y0+ sinf(_startAngle + totalAngle*i/(_total - 1))*_innerRadius;
        
        CGFloat x = x0 + cosf(_startAngle + totalAngle*i/(_total - 1))*_radius;
        CGFloat y = y0+ sinf(_startAngle + totalAngle*i/(_total - 1))*_radius;
        
        CGContextMoveToPoint(contextRef, x1, y1);
        
        CGContextAddLineToPoint(contextRef, x, y);
        
        CGContextSetStrokeColorWithColor(contextRef, _completedColor.CGColor);  //设置完成颜色
        CGContextSetFillColorWithColor(contextRef, _completedColor.CGColor);
        CGContextDrawPath(contextRef, kCGPathFillStroke);
        
    }
    
    for (int i = _completed; i < _total; i++)
    {
        CGFloat x1 = x0 + cosf(_startAngle + totalAngle*i/(_total - 1))*_innerRadius;
        CGFloat y1 = y0+ sinf(_startAngle + totalAngle*i/(_total - 1))*_innerRadius;
        
        CGFloat x = x0 + cosf(_startAngle + totalAngle*i/(_total - 1))*_radius;
        CGFloat y = y0 + sinf(_startAngle + totalAngle*i/(_total - 1))*_radius;
        
        CGContextMoveToPoint(contextRef, x1, y1);
        
        CGContextAddLineToPoint(contextRef, x, y);
        
        CGContextSetStrokeColorWithColor(contextRef, _color.CGColor);   //设置颜色
        CGContextSetFillColorWithColor(contextRef, _color.CGColor);
        CGContextDrawPath(contextRef, kCGPathFillStroke);
    }
    
    //画圆覆盖内部线条
//    CGContextAddArc(contextRef, x0, y0, _innerRadius, 0, 2*M_PI, 0);
//    CGContextSetFillColorWithColor(contextRef, CGColorCreateCopy(self.backgroundColor));
//    CGContextSetStrokeColorWithColor(contextRef, [UIColor clearColor].CGColor);     //设置内圆无颜色
//    CGContextDrawPath(contextRef, kCGPathFillStroke);
}

@end

