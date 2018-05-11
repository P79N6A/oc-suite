//
//  UIViewController+.h
//  XFAnimations
//
//  Created by fallen.ink on 12/8/15.
//  Copyright © 2015 fallen.ink. All rights reserved.
//

#import "_precompile.h"

@interface UIViewController ( Extension )

- (id)_initWithNib;

+ (instancetype)controller;
+ (instancetype)controllerWithNibName:(NSString *)nibName;

@end

@interface UIViewController ( Template )

#pragma mark - Views operations: overrided if needed

- (void)initDefault;

- (void)initViews;

- (void)initNavigationBar;

- (void)restoreNavigationBar;

- (void)initData;

- (void)initDataSource;

- (void)initScrollView;

- (void)initTableView;

- (void)initCollectionView;

- (void)initChildViewController;

/**
 *  当UIViewController有两种展示方式，则可以调用该策略view初始化
 */
- (void)initViewStrategy;

#pragma mark - Constraints operations: Need to be overrided

// mark template

#pragma mark - Initialize
#pragma mark - Life cycle
#pragma mark - Update
#pragma mark - Action handler && Notification handler &&
#pragma mark - ANY delegate
#pragma mark - Property
#pragma mark -

@end
