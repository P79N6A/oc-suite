//
// UIScrollView+SVInfiniteScrolling.h
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>

@class InfiniteScrollingView;

@interface UIScrollView ( InfiniteScrolling )

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler;

- (void)infiniteEndRefreshing; // 还有数据可加载，调用

- (void)infiniteFailedRefreshing; // 没有数据可加载了，调用

- (void)triggerInfiniteScrolling;

@property (nonatomic, strong, readonly) InfiniteScrollingView *infiniteScrollingView;

@property (nonatomic, assign) BOOL showsInfiniteScrolling; // 设置为NO，会导致上拉事件被屏蔽

@end


enum {
	InfiniteScrollingStateStopped = 0,
    InfiniteScrollingStateTriggered,
    InfiniteScrollingStateLoading,
    InfiniteScrollingStateAll = 10
};

typedef NSUInteger InfiniteScrollingState;

@interface InfiniteScrollingView : UIView

@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@property (nonatomic, readonly) InfiniteScrollingState state;
@property (nonatomic, readwrite) BOOL enabled;

- (void)setCustomView:(UIView *)view forState:(InfiniteScrollingState)state;

- (void)startAnimating;
- (void)stopAnimating;

@end
