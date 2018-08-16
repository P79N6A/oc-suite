//
//  UIView+backgroundView.h
//  wesg
//
//  Created by HG on 26/06/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PlaceholdView)

- (void)setupEmptyBackgroundViewWith:(NSString *)imageName title:(NSString *)title tintColor:(UIColor *)tintColor;

- (void)setupEmptyBackgroundViewWithTintColor:(UIColor *)tintColor;

- (void)setupErrorBackgroundViewWithTintColor:(UIColor *)tintColor refreshBlock:(void(^)())refresh;

- (void)resetBackgroundView;

@end
