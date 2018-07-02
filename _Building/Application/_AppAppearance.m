//
//  _app_appearance.m
//  student
//
//  Created by fallen.ink on 12/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_app_appearance.h"
#import "BaseViewController.h"

@implementation _AppAppearance

@def_singleton( _AppAppearance )

@def_prop_strong( UIColor *, themeColor )
@def_prop_strong( UIColor *, viewBackgroundColor )
@def_prop_strong( UIColor *, navigationBarBackgroundColor )

@def_prop_strong( NSString *, navigationBarBackButtonImage )

#pragma mark - set default

- (void)build {
    /**
     *  状态栏
     */
    [self statusBarAppearance];
    
    /**
     *  导航栏
     */
    [self navigationBarAppearance];
    
    /**
     *  选项卡
     */
    [self tabBarItemAppearance];
    
    /**
     *  UITextField
     */
    [self textFieldAppearance];
    
    /**
     *  UITextView
     */
    [self textViewAppearance];
    
    /**
     * 公共资源
     */
    [self buildResource];
}

- (void)buildResource {
    [BaseViewController setBackButtonImageName:self.navigationBarBackButtonImage];
}

#pragma mark - Initialization

/**
 *  UIStatusBarStyleLightContent    白色字样
 *  UIStatusBarStyleDefault         黑色字样
 */
- (void)statusBarAppearance {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)navigationBarAppearance {
    
    [[UINavigationBar appearance] setBarTintColor:self.navigationBarBackgroundColor]; // The tint color to apply to the navigation bar background.
    [[UINavigationBar appearance] setTintColor:self.navigationBarForegroundColor]; // The tint color to apply to the navigation items and bar button items.
    
    if (IOS8_OR_LATER) {
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
    UIFont *font = [UIFont systemFontOfSize:POUND_18];
    UIColor *foregroundColor = self.navigationBarForegroundColor;
    UIColor *backgroundColor = self.navigationBarBackgroundColor;
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          foregroundColor, NSForegroundColorAttributeName,
                                                          backgroundColor, NSBackgroundColorAttributeName,
                                                          font, NSFontAttributeName,
                                                          nil]];
    
    //隐藏导航栏文字
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                        forBarMetrics:UIBarMetricsDefault];
    
    {
        // 初始化其他UI组件的默认值
        
        BaseViewController.preferredNavigationBarColor = self.navigationBarBackgroundColor;
        
        if (self.navigationBarBackgroundColor.yValue > 0.5) { // 颜色浅
            BaseViewController.userPreferredStatusBarStyle = UIStatusBarStyleDefault;
        } else {
            BaseViewController.userPreferredStatusBarStyle = UIStatusBarStyleLightContent;
        }
        
        BaseViewController.preferredViewBackgroundColor = self.viewBackgroundColor;
    }
}

- (void)tabBarItemAppearance {
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       color_with_rgb(134, 135, 136),
                                                       NSForegroundColorAttributeName,
                                                       [UIFont systemFontOfSize:12.0], NSFontAttributeName,
                                                       nil]
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       self.themeColor, NSForegroundColorAttributeName,
                                                       [UIFont systemFontOfSize:12.0], NSFontAttributeName,
                                                       nil]
                                             forState:UIControlStateSelected];
    
    // UITabBar,移除顶部的阴影
//    [[UITabBar appearance] setShadowImage:[UIImage new]];
//    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
}

- (void)textFieldAppearance {
    [[UITextField appearance] setTintColor:[UIColor fontDeepBlackColor]];
}

- (void)textViewAppearance {
    [[UITextView appearance] setTintColor:[UIColor fontDeepBlackColor]];
}

@end
