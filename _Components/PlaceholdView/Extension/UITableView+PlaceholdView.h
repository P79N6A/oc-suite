//
//  UITableView+backgroundView.h
//  wesg
//
//  Created by Altair on 9/19/16.
//  Copyright © 2016 AliSports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (PlaceholdView)

- (void)setupEmptyBackgroundViewWithTintColor:(UIColor *)tintColor;

- (void)setupErrorBackgroundViewWithTintColor:(UIColor *)tintColor refreshBlock:(void(^)())refresh;

- (void)resetBackgroundView;

@end
