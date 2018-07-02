//
//  BaseNavigationController.h
//  component
//
//  Created by fallen.ink on 10/15/15.
//  Copyright (c) 2015 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - inspired by Safe Transition

@interface UINavigationController ( SafeTransition )

@property(nonatomic, assign, getter = isTransitionInProgress) BOOL transitionInProgress;

@end

#pragma mark -

@interface BaseNavigationController : UINavigationController

@property (nonatomic, assign) BOOL autoHideBottomBar; // default YES

#pragma mark - Style config

//// 设置背景颜色
//bar.barTintColor = PYBarTintColor;
//// 设置主题颜色
//bar.tintColor = [UIColor whiteColor];
//// 设置字体颜色
//NSDictionary *attr = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
//NSFontAttributeName : [UIFont boldSystemFontOfSize:20]
//};
//[bar setTitleTextAttributes:attr];
- (void)configNavigationBar:(void (^)(UINavigationBar *bar))handler;

#pragma mark -

- (UIViewController *)childViewControllerForStatusBarStyle;

@end
