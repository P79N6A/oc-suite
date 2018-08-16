//
//  UIView+backgroundView.m
//  wesg
//
//  Created by HG on 26/06/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "UIView+PlaceholdView.h"
#import "_EmptyDataView.h"
#import "_Foundation.h"

@implementation UIView (PlaceholdView)

- (void)setupEmptyBackgroundViewWithTintColor:(UIColor *)tintColor {
    if (self.backgroundView) {
        [self resetBackgroundView];
    }
    
    _EmptyDataView *view = [[_EmptyDataView alloc] initWithFrame:self.bounds
                                                            image:[UIImage imageNamed:@"content_empty"]
                                                      description:@"当前无内容哦"];
    view.tintColor = tintColor;
    
    self.backgroundView = view;
    
    [self addSubview:self.backgroundView];
}

- (void)setupEmptyBackgroundViewWith:(NSString *)imageName title:(NSString *)title tintColor:(UIColor *)tintColor {
    
    if (self.backgroundView) {
        [self resetBackgroundView];
    }
    
    _EmptyDataView *view = [[_EmptyDataView alloc]
                            initWithFrame:self.bounds
                                    image:[UIImage imageNamed:imageName]
                              description:title];
    
    view.tintColor = tintColor;
    
    self.backgroundView = view;
    [self addSubview:self.backgroundView];
}

- (void)setupErrorBackgroundViewWithTintColor:(UIColor *)tintColor refreshBlock:(void (^)())refresh {
    
    if (self.backgroundView) {
        [self resetBackgroundView];
    }
    
    _EmptyDataView *view = [[_EmptyDataView alloc] initWithFrame:self.bounds
                                                                    image:[UIImage imageNamed:@"404_Failed"]
                                                              description:@"网络异常，请点击刷新"
                                                               needGoHome:YES];
    view.GoHomeBlock = ^ {
        if (refresh) {
            refresh();
        }
    };
    view.tintColor = tintColor;
    
    self.backgroundView = view;
    [self addSubview:self.backgroundView];
}

- (void)resetBackgroundView {
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    objc_setAssociatedObject(self, @"backgroundView", backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)backgroundView {
    return objc_getAssociatedObject(self, @"backgroundView");
}

@end
