//
//  UICollectionView+backgroundView.m
//  wesg
//
//  Created by HG on 04/07/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "_Foundation.h"
#import "_EmptyDataView.h"
#import "UICollectionView+PlaceholdView.h"

@implementation UICollectionView (PlaceholdView)

- (void)setupEmptyBackgroundViewWithTintColor:(UIColor *)tintColor {
    _EmptyDataView *emptyView = [[_EmptyDataView alloc] initWithFrame:CGRectMake(0, 0, screen_width, self.frame.size.height) image:[UIImage imageNamed:@"content_empty"] description:@"当前无内容哦"];
    emptyView.tintColor = tintColor;
    
    self.backgroundView = emptyView;
}

- (void)setupErrorBackgroundViewWithTintColor:(UIColor *)tintColor refreshBlock:(void (^)())refresh {
    _EmptyDataView *emptyView = [[_EmptyDataView alloc] initWithFrame:CGRectMake(0, 0, screen_width, self.frame.size.height) image:[UIImage imageNamed:@"404_Failed"] description:@"网络异常，请点击刷新" needGoHome:YES];
    emptyView.GoHomeBlock = ^ {
        if (refresh) {
            refresh();
        }
    };
    emptyView.tintColor = tintColor;
    
    self.backgroundView = emptyView;
}

- (void)resetBackgroundView {
    self.backgroundView = nil;
}

@end
