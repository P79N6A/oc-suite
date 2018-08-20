//
//  Monitor.m
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "Monitor.h"
#import "PresentAnimator.h"
#import "DismissAnimator.h"

@interface Monitor () <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) MonitorGateWindow *gate;

@end

@implementation Monitor

@def_singleton( Monitor )

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass methods

- (instancetype)init {
    if (self = [super init]) {
        self.config = [MonitorConfig new];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

- (void)powerOn {
    @weakify(self)
    
    self.gate = [[MonitorGateWindow alloc] initWithFrame:CGRectMake(screen_width-80, screen_height-150, 50, 50) bgcolor:[UIColor darkGrayColor] animationColor:[UIColor purpleColor]];
    
    self.gate.gateHandler = ^{
        @strongify(self)
        
        [self showMonitorView];
    };
}

- (void)powerOff {
    [self.gate dissmiss];
    
    self.gate.gateHandler = nil;
    self.gate = nil;
}

- (void)showMonitorView {
    self.navigation = [MonitorContentView withNavigation];
    self.navigation.transitioningDelegate = self;
    self.navigation.modalPresentationStyle = UIModalPresentationCustom;
    
    @weakify(self)
    [self.bridge presentViewController:self.navigation animated:YES completion:^{
        @strongify(self)
        
        [self.gate dissmiss];
    }];
}

- (void)dismissMonitorView {
    [self.bridge dismissViewControllerAnimated:YES completion:^{
        [self.gate show];
    }];
    
    self.navigation = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

////////////////////////////////////////////////////////////////////////////////
#pragma mark - XXXDataSource / XXXDelegate methods

#pragma mark - 动画代理
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    
    return nil;
}

#pragma mark - 定制转场动画 (Present 与 Dismiss动画代理)
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    // 推出控制器的动画
    return [PresentAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    DismissAnimator *dismissAnimator   = [DismissAnimator new];
    dismissAnimator.transitionDuration = 0.6f;
    
    // 退出控制器动画
    return dismissAnimator;
}

@end
