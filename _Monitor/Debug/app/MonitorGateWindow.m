//
//  MonitorGateWindow.m
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>
#import "UIImage+Round.h"
#import "MonitorGateWindow.h"

#define kk_WIDTH self.frame.size.width
#define kk_HEIGHT self.frame.size.height

#define animateDuration 0.3         //位置改变动画时间
#define showDuration 0.1            //展开动画时间
#define statusChangeDuration  4.0   //状态改变时间
#define normalAlpha  1.0            //正常状态时背景alpha值
#define sleepAlpha  0.5             //隐藏到边缘时的背景alpha值
#define myBorderWidth 1.0           //外框宽度
#define marginWith  5               //间隔
#define readyPosition                    CGPointMake(screen_width-80, screen_height-150)

#define WZFlashInnerCircleInitialRaius  20

@interface MonitorGateWindow ()

//@property (nonatomic, assign) NSInteger frameWidth;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIButton *mainImageButton;
@property (nonatomic, strong) CAAnimationGroup *animationGroup;
@property (nonatomic, strong) CAShapeLayer *circleShape;
@property (nonatomic, strong) UIColor *animationColor;

@end

@implementation MonitorGateWindow

#pragma mark - Initialize

- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor {
    return [self initWithFrame:frame bgcolor:bgcolor animationColor:nil];
}

- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor animationColor:animationColor {
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.windowLevel = UIWindowLevelAlert + 1;  //如果想在 alert 之上，则改成 + 2
        
        self.rootViewController = [UIViewController new];
        
        [self makeKeyAndVisible];
        
        self.animationColor = animationColor ? animationColor : bgcolor;
        
        _mainImageButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_mainImageButton setTitle:@"大叔" forState:UIControlStateNormal];
        [_mainImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_mainImageButton setFrame:(CGRect){0, 0,frame.size.width, frame.size.height}];
        
        // 加圆角
        {
            UIImage *backgroundImage = [UIImage _imageWithColor:bgcolor size:frame.size];
            backgroundImage = [backgroundImage _imageWithRoundedCornersSize:frame.size.width/2];
            [_mainImageButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        }
        
        // 加圆角
        {
//            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_mainImageButton.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(frame.size.width, frame.size.height)];
//            
//            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//            
//            maskLayer.frame = _mainImageButton.bounds;
//            
//            maskLayer.path = maskPath.CGPath;
//            
//            _mainImageButton.layer.mask = maskLayer;
        }
        
        // 还是加圆角
        {
//            _mainImageButton.layer.cornerRadius = frame.size.width/2;
        }
        
        _mainImageButton.alpha = normalAlpha;
        [_mainImageButton addTarget:self action:@selector(onTrigger:) forControlEvents:UIControlEventTouchUpInside];
        [_mainImageButton addTarget:self action:@selector(onLongTap) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:_mainImageButton];
        
        // 长按操作
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan:)];
        _pan.delaysTouchesBegan = NO;
        [self addGestureRecognizer:_pan];
        
        //
        [self show];
        
        //
        [self onIdle];
    }
    
    return self;
}


#pragma mark - Public

- (void)dissmiss {
    self.hidden = YES;
}

- (void)show {
    self.hidden = NO;
}

#pragma mark - Action handler

- (void)onIdle { // 闲置
    [self performSelector:@selector(animateOut) withObject:nil afterDelay:statusChangeDuration];
    
    [self moveOut];
}

- (void)cancelIdle {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateOut) object:nil];
}

- (void)onLongTap { // 准备好
    [self cancelIdle];
    
    [self performSelector:@selector(animationWave) withObject:nil afterDelay:0.5];
}

- (void)onTrigger:(UITapGestureRecognizer *)tap {
    [self cancelIdle];
    
    [self stopAnimation];
    
    // 如果当前处于半隐藏，则先出来
    if (_mainImageButton.alpha < normalAlpha) {
        _mainImageButton.alpha = normalAlpha;
        
        // animate in
        if (self.center.x == 0) {
            self.center = CGPointMake(kk_WIDTH/2, self.center.y);
        } else if (self.center.x == screen_width) {
            self.center = CGPointMake(screen_width - kk_WIDTH/2, self.center.y);
        } else if (self.center.y == 0) {
            self.center = CGPointMake(self.center.x, kk_HEIGHT/2);
        } else if (self.center.y == screen_height) {
            self.center = CGPointMake(self.center.x, screen_height - kk_HEIGHT/2);
        }
    } else {
        if (self.gateHandler) {
            
            self.gateHandler();
        }
    }
    
    [self onIdle];
}

- (void)onPan:(UIPanGestureRecognizer *)p {
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(p.state == UIGestureRecognizerStateBegan) {
        [self cancelIdle];

        _mainImageButton.alpha = normalAlpha;
    } else if(p.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    } else if(p.state == UIGestureRecognizerStateEnded) {
        [self stopAnimation];
        
        [self onIdle];
    }
}

#pragma mark - Position adaptive

- (void)moveOut {
    CGPoint panPoint = readyPosition;
    
    if(panPoint.x <= screen_width/2) {
        if(panPoint.y <= 40+kk_HEIGHT/2 && panPoint.x >= 20+kk_WIDTH/2) {
            [UIView animateWithDuration:animateDuration animations:^{
                self.center = CGPointMake(panPoint.x, kk_HEIGHT/2);
            }];
        } else if(panPoint.y >= screen_height-kk_HEIGHT/2-40 && panPoint.x >= 20+kk_WIDTH/2) {
            [UIView animateWithDuration:animateDuration animations:^{
                self.center = CGPointMake(panPoint.x, screen_height-kk_HEIGHT/2);
            }];
        } else if (panPoint.x < kk_WIDTH/2+20 && panPoint.y > screen_height-kk_HEIGHT/2) {
            [UIView animateWithDuration:animateDuration animations:^{
                self.center = CGPointMake(kk_WIDTH/2, screen_height-kk_HEIGHT/2);
            }];
        } else {
            CGFloat pointy = panPoint.y < kk_HEIGHT/2 ? kk_HEIGHT/2 :panPoint.y;
            [UIView animateWithDuration:animateDuration animations:^{
                self.center = CGPointMake(kk_WIDTH/2, pointy);
            }];
        }
    } else if(panPoint.x > screen_width/2) {
        if(panPoint.y <= 40+kk_HEIGHT/2 && panPoint.x < screen_height-kk_WIDTH/2-20 ) {
            [UIView animateWithDuration:animateDuration animations:^{
                self.center = CGPointMake(panPoint.x, kk_HEIGHT/2);
            }];
        } else if(panPoint.y >= screen_height-40-kk_HEIGHT/2 && panPoint.x < screen_width-kk_WIDTH/2-20) {
            [UIView animateWithDuration:animateDuration animations:^{
                self.center = CGPointMake(panPoint.x, screen_height-kk_HEIGHT/2);
            }];
        } else if (panPoint.x > screen_width-kk_WIDTH/2-20 && panPoint.y < kk_HEIGHT/2) {
            [UIView animateWithDuration:animateDuration animations:^{
                self.center = CGPointMake(screen_width-kk_WIDTH/2, kk_HEIGHT/2);
            }];
        } else {
            CGFloat pointy = panPoint.y > screen_height-kk_HEIGHT/2 ? screen_height-kk_HEIGHT/2 :panPoint.y;
            [UIView animateWithDuration:animateDuration animations:^{
                self.center = CGPointMake(screen_width-kk_WIDTH/2, pointy);
            }];
        }
    }
    
}

- (void)animateOut {
    [UIView animateWithDuration:1.0 animations:^{
        _mainImageButton.alpha = sleepAlpha;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat x = self.center.x < 20+kk_WIDTH/2 ? 0 :  self.center.x > screen_width - 20 -kk_WIDTH/2 ? screen_width : self.center.x;
        CGFloat y = self.center.y < 40 + kk_HEIGHT/2 ? 0 : self.center.y > screen_height - 40 - kk_HEIGHT/2 ? screen_height : self.center.y;
        
        //禁止停留在4个角
        if((x == 0 && y ==0) || (x == screen_width && y == 0) || (x == 0 && y == screen_height) || (x == screen_width && y == screen_height)){
            y = self.center.y;
        }
        self.center = CGPointMake(x, y);
    }];
}

- (void)animationWave {
    self.layer.masksToBounds = NO;
    
    CGFloat scale = 1.0f;
    CGFloat width = self.mainImageButton.bounds.size.width, height = self.mainImageButton.bounds.size.height;
    CGFloat biggerEdge = width > height ? width : height, smallerEdge = width > height ? height : width;
    CGFloat radius = smallerEdge / 2 > WZFlashInnerCircleInitialRaius ? WZFlashInnerCircleInitialRaius : smallerEdge / 2;
    
    scale = biggerEdge / radius + 0.5;
    _circleShape = [self createCircleShapeWithPosition:CGPointMake(width/2, height/2)
                                              pathRect:CGRectMake(0, 0, radius * 3, radius * 3)
                                                radius:radius];
    
    [self.mainImageButton.layer addSublayer:_circleShape];
    
    CAAnimationGroup *groupAnimation = [self createFlashAnimationWithScale:scale duration:1.0f];
    
    [_circleShape addAnimation:groupAnimation forKey:nil];
}

#pragma mark -

- (void)stopAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationWave) object:nil];
    
    if (_circleShape) {
        [_circleShape removeFromSuperlayer];
    }
}

- (CAShapeLayer *)createCircleShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect radius:(CGFloat)radius {
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = [self createCirclePathWithRadius:rect radius:radius];
    circleShape.position = position;
    
    // 雷达覆盖区域
    circleShape.bounds = CGRectMake(0, 0, radius * 3, radius * 3);
    circleShape.fillColor = self.animationColor.CGColor;
    
    circleShape.opacity = 0;
    circleShape.lineWidth = 1;
    
    return circleShape;
}

- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    _animationGroup = [CAAnimationGroup animation];
    _animationGroup.animations = @[scaleAnimation, alphaAnimation];
    _animationGroup.duration = duration;
    _animationGroup.repeatCount = INFINITY;
    _animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return _animationGroup;
}


- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius {
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}

@end
