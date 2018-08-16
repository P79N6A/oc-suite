//
//  UICollectionView+backgroundView.h
//  wesg
//
//  Created by HG on 04/07/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (PlaceholdView)
- (void)setupEmptyBackgroundViewWithTintColor:(UIColor *)tintColor;

- (void)setupErrorBackgroundViewWithTintColor:(UIColor *)tintColor refreshBlock:(void (^)())refresh;

- (void)resetBackgroundView;
@end
