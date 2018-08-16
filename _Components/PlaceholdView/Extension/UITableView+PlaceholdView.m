//
//  UITableView+backgroundView.m
//  wesg
//
//  Created by Altair on 9/19/16.
//  Copyright © 2016 AliSports. All rights reserved.
//

#import "UITableView+PlaceholdView.h"
#import "_EmptyDataView.h"
#import "_Foundation.h"

@implementation UITableView (PlaceholdView)

- (void)setupEmptyBackgroundViewWithTintColor:(UIColor *)tintColor {
    _EmptyDataView *view = [[_EmptyDataView alloc] initWithFrame:CGRectMake(0, 0, screen_width, self.frame.size.height) image:[UIImage imageNamed:@"content_empty"] description:@"当前无内容哦"];
    view.tintColor = tintColor;
    self.backgroundView = view;
}

- (void)setupErrorBackgroundViewWithTintColor:(UIColor *)tintColor refreshBlock:(void (^)())refresh {
    _EmptyDataView *view = [[_EmptyDataView alloc] initWithFrame:CGRectMake(0, 0, screen_width, self.frame.size.height) image:[UIImage imageNamed:@"404_Failed"] description:@"网络异常，请点击刷新" needGoHome:YES];
    view.GoHomeBlock = ^ {
        if (refresh) {
            refresh();
        }
    };
    view.tintColor = tintColor;
    self.backgroundView = view;
}

- (void)resetBackgroundView {
    self.backgroundView = nil;
}

@end
