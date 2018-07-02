//
//  PopViewController.m
//  consumer
//
//  Created by fallen on 16/9/14.
//
//

#import "PopViewController.h"

@interface PopViewController ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIWindow *originalKeyWindow;

@property (nonatomic, strong) UIMotionEffectGroup *motionEffectGroup;

@property (nonatomic, assign) PopViewControllerAnimateType animateType;

@end

@implementation PopViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.masksToBounds = YES;
    
//    TODO("可以选择以下效果")
    // http://www.code4app.com/forum.php?mod=viewthread&tid=10726&extra=page%3D1%26filter%3Dsortid%26sortid%3D1
    // https://github.com/1em0nsOft/LemonKit4Android
    // https://github.com/1em0nsOft/LemonKit4iOS
    // https://github.com/1em0nsOft/LemonKit4iOS-Swift
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Aniamte

- (void)addMotionEffects {
    [self.view addMotionEffect:self.motionEffectGroup];
}

- (void)removeMotionEffects {
    [self.view removeMotionEffect:self.motionEffectGroup];
}

#pragma mark - Public

- (UIView *)viewShouldDisplay3D {
    return nil;
}

- (UIView *)viewShouldDisplayMask {
    return nil;
}

- (void)showWithAnimateType:(PopViewControllerAnimateType)animateType animateStartBlock:(Block)startHandler animateEndBlock:(Block)endHandler {
    if (animateType == PopViewControllerAnimateType_Default) {
        [self showDefaultWithAnimateStartBlock:startHandler animateEndBlock:endHandler];
    } else if (animateType == PopViewControllerAnimateType_3D) {
        [self show3DWithAnimateStartBlock:startHandler animateEndBlock:endHandler];
    }
    
    self.animateType = animateType;
}

- (void)dismissWithAnimateStartBlock:(Block)startHandler animateEndBlock:(Block)endHandler animateCompleteBlock:(Block)completeHandler {
    if (self.animateType == PopViewControllerAnimateType_Default) {
        [self dismissDefaultWithAnimateStartBlock:startHandler animateEndBlock:endHandler animateCompleteBlock:completeHandler];
    } else if (self.animateType == PopViewControllerAnimateType_3D) {
        [self dismiss3DWithAnimateStartBlock:startHandler animateEndBlock:endHandler animateCompleteBlock:completeHandler];
    }
}

#pragma mark - Public PopViewControllerAnimateType_Default

- (void)showDefaultWithAnimateStartBlock:(Block)startHandler animateEndBlock:(Block)endHandler {
    // 窗口设置
    {
        self.originalKeyWindow = [UIApplication sharedApplication].keyWindow;
        [self.window makeKeyAndVisible];
        
        // If we start in landscape mode also update the windows frame to be accurate
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            self.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
        }
    }
    
    // UIViewController config
    {
        [self viewWillAppear:YES];
        
        self.window.rootViewController = self;
        
        [self viewDidAppear:YES];
    }
    
    // Animate
    {
        if (startHandler) {
            startHandler();
        }
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (endHandler) {
                endHandler();
            }
            
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)dismissDefaultWithAnimateStartBlock:(Block)startHandler animateEndBlock:(Block)endHandler animateCompleteBlock:(Block)completeHandler {
    if (startHandler) {
        startHandler();
    }
    
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        if (endHandler) {
            endHandler();
        }
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self viewWillDisappear:YES];
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [self didMoveToParentViewController:nil];
        [self viewDidDisappear:YES];
        
        [self.window resignKeyWindow];
        [self.originalKeyWindow makeKeyAndVisible];
        self.window = nil;
        
        if (completeHandler) {
            completeHandler();
        }
    }];
}

#pragma mark - Public PopViewControllerAnimateType_3D

- (void)show3DWithAnimateStartBlock:(Block)startHandler animateEndBlock:(Block)endHandler {
    // 窗口设置
    {
        self.originalKeyWindow = [UIApplication sharedApplication].keyWindow;
        [self.window makeKeyAndVisible];
        
        // If we start in landscape mode also update the windows frame to be accurate
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            self.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
        }
    }
    
    // UIViewController config
    {
        [self viewWillAppear:YES];
        
        self.window.rootViewController = self;
        
        [self viewDidAppear:YES];
    }
    
    // Animate
    {
        UNUSED(startHandler)
        UNUSED(endHandler)

        [CATransaction begin];
        [CATransaction setAnimationDuration:0.2];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [self.viewShouldDisplayMask.layer addAnimation:self.dimingAnimation forKey:@"diming"];
        [self.viewShouldDisplay3D.layer addAnimation:self.showMenuAnimation forKey:@"showMenu"];
        [CATransaction commit];
    }
}

- (void)dismiss3DWithAnimateStartBlock:(Block)startHandler animateEndBlock:(Block)endHandler animateCompleteBlock:(Block)completeHandler {
    UNUSED(startHandler)
    UNUSED(endHandler)
    
    [self.view setNeedsUpdateConstraints];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setCompletionBlock:^{
//        [self removeFromSuperview];
//        [menu removeFromSuperview];
        
        [self willMoveToParentViewController:nil];
        [self viewWillDisappear:YES];
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [self didMoveToParentViewController:nil];
        [self viewDidDisappear:YES];
        
        [self.window resignKeyWindow];
        [self.originalKeyWindow makeKeyAndVisible];
        self.window = nil;
        
        if (completeHandler) {
            completeHandler();
        }
    }];
    [self.viewShouldDisplayMask.layer addAnimation:self.lightingAnimation forKey:@"lighting"];
    [self.viewShouldDisplay3D.layer addAnimation:self.dismissMenuAnimation forKey:@"dismissMenu"];
    [CATransaction commit];
}

#pragma mark -

- (CAAnimation *)dimingAnimation {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    opacityAnimation.fromValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor];
    opacityAnimation.toValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.4] CGColor];
    [opacityAnimation setRemovedOnCompletion:YES];
    [opacityAnimation setFillMode:kCAFillModeBoth];
    return opacityAnimation;
}

- (CAAnimation *)lightingAnimation {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    opacityAnimation.fromValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.4] CGColor];
    opacityAnimation.toValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor];
    [opacityAnimation setRemovedOnCompletion:YES];
    [opacityAnimation setFillMode:kCAFillModeBoth];
    return opacityAnimation;
}

- (CAAnimation *)showMenuAnimation {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D t = CATransform3DIdentity;
    t.m34 = 1 / -500.0f;
    CATransform3D from = CATransform3DRotate(t, -30.0f * M_PI / 180.0f, 1, 0, 0);
    CATransform3D to = CATransform3DIdentity;
    [rotateAnimation setFromValue:[NSValue valueWithCATransform3D:from]];
    [rotateAnimation setToValue:[NSValue valueWithCATransform3D:to]];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnimation setFromValue:@0.9];
    [scaleAnimation setToValue:@1.0];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [positionAnimation setFromValue:[NSNumber numberWithFloat:50.0]];
    [positionAnimation setToValue:[NSNumber numberWithFloat:0.0]];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacityAnimation setFromValue:@0.0];
    [opacityAnimation setToValue:@1.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setAnimations:@[rotateAnimation, scaleAnimation, opacityAnimation, positionAnimation]];
    [group setRemovedOnCompletion:YES];
    [group setFillMode:kCAFillModeBoth];
    return group;
}

- (CAAnimation *)dismissMenuAnimation {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D t = CATransform3DIdentity;
    t.m34 = 1 / -500.0f;
    CATransform3D from = CATransform3DIdentity;
    CATransform3D to = CATransform3DRotate(t, -30.0f * M_PI / 180.0f, 1, 0, 0);
    [rotateAnimation setFromValue:[NSValue valueWithCATransform3D:from]];
    [rotateAnimation setToValue:[NSValue valueWithCATransform3D:to]];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnimation setFromValue:@1.0];
    [scaleAnimation setToValue:@0.9];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [positionAnimation setFromValue:[NSNumber numberWithFloat:0.0]];
    [positionAnimation setToValue:[NSNumber numberWithFloat:50.0]];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacityAnimation setFromValue:@1.0];
    [opacityAnimation setToValue:@0.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setAnimations:@[rotateAnimation, scaleAnimation, opacityAnimation, positionAnimation]];
    [group setRemovedOnCompletion:YES];
    [group setFillMode:kCAFillModeBoth];
    return group;
}

#pragma mark - Property

- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.windowLevel = UIWindowLevelNormal; // 不隐藏状态栏
    }
    
    return _window;
}


@end
