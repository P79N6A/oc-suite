//
//  BaseTabBarController.m
//  component
//
//  Created by fallen.ink on 4/28/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "UIViewController+Extension.h"
#import "BaseTabBarController.h"
#import "_geometry.h"
#import "_frame.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavLeftItemWithImage:@"top_backbutton" target:self action:@selector(onBack)];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    /**
     *  inspired by http://www.jianshu.com/p/f334cbaa41bf
     */
    if (self.isTabBarHeightCustomized) {
        CGRectSetHeight(self.tabBar.frame, self.tabBarHeight);
    }
//    [self.tabBar bringSubviewToFront:self.bottomToolView];
}

#pragma mark -

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Status style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
