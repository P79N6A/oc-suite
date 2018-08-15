//
//  BaseNavigationController.m
//  component
//
//  Created by fallen.ink on 10/15/15.
//  Copyright (c) 2015 OpenTeam. All rights reserved.
//

#import "BaseNavigationController.h"
#import "BaseNavigationBar.h"
#import "UIImage+Extension.h"

typedef void (^APTransitionBlock)(void);

@interface BaseNavigationController () <UINavigationControllerDelegate> {
    BOOL _transitionInProgress;
    NSMutableArray *_peddingBlocks;
    CGFloat _systemVersion;
}

@end

@implementation BaseNavigationController

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super initWithNavigationBarClass:[BaseNavigationBar class] toolbarClass:nil]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[BaseNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[rootViewController];
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    // To override the opacity of CRNavigationBar's barTintColor, set this value to YES.
    ((BaseNavigationBar *)self.navigationBar).overrideOpacity = NO;
    
    _transitionInProgress = NO;
    _peddingBlocks = [NSMutableArray arrayWithCapacity:2];
    _systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    _autoHideBottomBar = YES;
}

#pragma mark - Pushing and Popping Stack Items

- (void)ap_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (_systemVersion >= 8.0) {
        [super pushViewController:viewController animated:animated];
    }
    else {
        [self addTransitionBlock:^{
            [super pushViewController:viewController animated:animated];
        }];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *poppedViewController = nil;
    if (_systemVersion >= 8.0) {
        poppedViewController = [super popViewControllerAnimated:animated];
    }
    else {
        __weak BaseNavigationController *weakSelf = self;
        [self addTransitionBlock:^{
            UIViewController *viewController = [super popViewControllerAnimated:animated];
            if (viewController == nil) {
                weakSelf.transitionInProgress = NO;
            }
        }];
    }
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *poppedViewControllers = nil;
    if (_systemVersion >= 8.0) {
        poppedViewControllers = [super popToViewController:viewController animated:animated];
    }
    else {
        __weak BaseNavigationController *weakSelf = self;
        [self addTransitionBlock:^{
            if ([weakSelf.viewControllers containsObject:viewController]) {
                NSArray *viewControllers = [super popToViewController:viewController animated:animated];
                if (viewControllers.count == 0) {
                    weakSelf.transitionInProgress = NO;
                }
            }
            else {
                weakSelf.transitionInProgress = NO;
            }
        }];
    }
    return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray *poppedViewControllers = nil;
    if (_systemVersion >= 8.0) {
        poppedViewControllers = [super popToRootViewControllerAnimated:animated];
    }
    else {
        __weak BaseNavigationController *weakSelf = self;
        [self addTransitionBlock:^{
            NSArray *viewControllers = [super popToRootViewControllerAnimated:animated];
            if (viewControllers.count == 0) {
                weakSelf.transitionInProgress = NO;
            }
        }];
    }
    return poppedViewControllers;
}

#pragma mark - Accessing Items on the Navigation Stack

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    if (_systemVersion >= 8.0) {
        [super setViewControllers:viewControllers animated:animated];
    }
    else {
        __weak BaseNavigationController *weakSelf = self;
        [self addTransitionBlock:^{
            NSArray *originalViewControllers = weakSelf.viewControllers;
            NSLog(@"%s", __FUNCTION__);
            [super setViewControllers:viewControllers animated:animated];
            if (!animated || originalViewControllers.lastObject == viewControllers.lastObject) {
                weakSelf.transitionInProgress = NO;
            }
        }];
    }
}

#pragma mark - Transition Manager

- (void)addTransitionBlock:(void (^)(void))block {
    if (![self isTransitionInProgress]) {
        self.transitionInProgress = YES;
        block();
    }
    else {
        [_peddingBlocks addObject:[block copy]];
    }
}

- (BOOL)isTransitionInProgress {
    return _transitionInProgress;
}

- (void)setTransitionInProgress:(BOOL)transitionInProgress {
    _transitionInProgress = transitionInProgress;
    if (!transitionInProgress && _peddingBlocks.count > 0) {
        _transitionInProgress = YES;
        [self runNextTransition];
    }
}

- (void)runNextTransition {
    APTransitionBlock block = _peddingBlocks.firstObject;
    [_peddingBlocks removeObject:block];
    block();
}

#pragma mark - Life cycle

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0 &&
        self.autoHideBottomBar) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    return [self ap_pushViewController:viewController animated:animated];
}

#pragma mark - Style config

- (void)configNavigationBar:(void (^)(UINavigationBar *))handler {
    if (handler) {
        handler(self.navigationBar);
    }
    
}

// [[AUIThemeManager manager] currentTheme].navibarBGColor;
- (void)setNavigationBarBackgroundColor:(UIColor *)color alpha:(CGFloat)alpha  {
    if (alpha >= 1) {
        [self.navigationBar setTranslucent:NO];
    } else {
        [self.navigationBar setTranslucent:YES];
    }
    
    UIImage *image = [UIImage imageWithColor:[color colorWithAlphaComponent:alpha]];
    [self.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

#pragma mark - 

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [[self topViewController] preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [[self topViewController] prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return [[self topViewController] preferredStatusBarUpdateAnimation];
}

@end
