//
//  BMYScrollableNavigationBarViewController.h
//  BMYScrollableNavigationBarDemo
//
//  Created by Alberto De Bortoli on 17/07/14.
//  Copyright (c) 2014 Beamly. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 
 Usage
 
 1. 继承
 
 @interface BMYViewController : BMYScrollableNavigationBarViewController
 
 2. 配置
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 self.title = @"ScrollableNavigationBar";
 [self.view addSubview:self.tableView];
 
 self.enableScrollableNavigationBar = YES;
 [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:209.0f/255.0f green:0.0f/255.0f blue:58.0f/255.0f    alpha:1.0f]];
 
 self.tableView.frame = self.view.bounds;
 [self.navigationController.navigationBar setTranslucent:kNavigationBarIsTranslucent];
 [self bindNavigationBarToScrollView:self.tableView];
 }
 
 */
@interface BMYScrollableNavigationBarViewController : UIViewController

@property (nonatomic, assign) BOOL enableScrollableNavigationBar;

/**
 *  Call this method to bind the navigation bar to a scrollView.
 *  Need to provide a scrollView with the frame already set.
 *
 *  @param scrollView The scrollView to bind to the navigation bar.
 */
- (void)bindNavigationBarToScrollView:(UIScrollView *)scrollView;

@end
