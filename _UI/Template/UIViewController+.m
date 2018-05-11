//
//  UIViewController+.m
//  XFAnimations
//
//  Created by fallen.ink on 12/8/15.
//  Copyright © 2015 fallen.ink. All rights reserved.
//

#import "UIViewController+.h"

@implementation UIViewController ( Extension )

- (id)_initWithNib {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (instancetype)controller {
    return [self controllerWithNibName:NSStringFromClass([self class])];
}

+ (instancetype)controllerWithNibName:(NSString *)nibName {
    return [[self alloc] initWithNibName:nibName bundle:nil];
}

@end

@implementation UIViewController ( Template )

- (void)initDefault {
    
}

- (void)initViews {
    
}

- (void)initNavigationBar {
    
}

- (void)restoreNavigationBar {
    
}

- (void)initData {
    
}

- (void)initDataSource {
    
}

- (void)initScrollView {
    
}

- (void)initTableView {
    
}

- (void)initCollectionView {
    
}

- (void)initChildViewController {
    
}

- (void)initViewStrategy {
    
}

@end


