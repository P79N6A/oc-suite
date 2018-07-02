//
//  ShapeView.m
//  hairdresser
//
//  Created by fallen.ink on 9/5/16.
//
//

#import "UIShapeView.h"

@implementation ShapeView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

@end

#pragma mark - Triangle

@implementation TriangleView

- (void)initViews {
    self.triangleStyle = DrawTriangleStyle_Top;
    self.fillColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawTriangle {
    [self.backgroundColor set];//设置背景颜色
    
    UIRectFill([self bounds]);//拿到当前视图准备好的画板
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextBeginPath(context);
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    switch (self.triangleStyle) {
        case DrawTriangleStyle_Top:{
            CGContextMoveToPoint(context,0, height);//设置起点
            CGContextAddLineToPoint(context,width, height);
            CGContextAddLineToPoint(context,width/2, 0);
        }
            break;
        case DrawTriangleStyle_Bottom:{
            CGContextMoveToPoint(context,0, 0);//设置起点
            CGContextAddLineToPoint(context,width, 0);
            CGContextAddLineToPoint(context,width/2, height);
        }
            break;
        case DrawTriangleStyle_Left:{
            CGContextMoveToPoint(context,width, 0);//设置起点
            CGContextAddLineToPoint(context,width, height);
            CGContextAddLineToPoint(context,0, height/2);
        }
            break;
        case DrawTriangleStyle_Right:{
            CGContextMoveToPoint(context,0, 0);//设置起点
            CGContextAddLineToPoint(context,0, height);
            CGContextAddLineToPoint(context,width, height/2);
        }
            break;
        default:
            break;
    }
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    [self.fillColor setFill];//设置填充色
    [self.fillColor setStroke];//设置边框颜色
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
}

- (void)drawRect:(CGRect)rect {
    [self drawTriangle];
}

@end

#pragma mark - Circle

@implementation CircleView

- (void)drawCircle:(CGRect)rect {
    CGRect bounds = self.bounds;
    
    [[UIColor whiteColor] set];
    UIRectFill(bounds);
    
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:bounds.size.height/2] addClip];
    
    [self.image drawInRect:bounds];
}

- (void)drawRect:(CGRect)rect {
    [self drawCircle:rect];
}

- (void)initViews {
    self.imageView = [UIImageView new];
    self.imageView.bounds = self.bounds;
}

#pragma mark - Property

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self setNeedsDisplay];
}

- (UIImage*)image {
    return self.imageView.image;
}

@end
