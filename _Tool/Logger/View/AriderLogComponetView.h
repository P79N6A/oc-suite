//
//  AriderLogComponetView.h
//  LogTest
//
//  Created by 君展 on 13-8-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//  http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <UIKit/UIKit.h>
#import "AriderLogFilterView.h"
#import "AriderLogDisplayView.h"
#import "AriderLogConfigView.h"
@interface AriderLogComponetView : UIView
@property (nonatomic, strong) NSMutableArray *segmentModelArray;
@property (strong, readonly) UIWindow *loggoWindow;
@property (strong, readonly) UIButton *loggoButton;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) AriderLogDisplayView *logDisplayView;
@property (strong, nonatomic) AriderLogFilterView *logFilterView;
@property (strong, nonatomic) AriderLogConfigView *logConfigView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *menuSegmentedControl;
@property (strong, nonatomic) IBOutlet UIScrollView *menuScrollView;

- (void)insertSegmentWithTitle:(NSString *)title view:(UIView *)view atIndex:(NSUInteger)segment;

- (void)removeSegmentAtIndex:(NSUInteger)segment;

- (void)showSegmentAtIndex:(NSUInteger)segment;
@end


@interface AriderLogSegmentModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIView *view;
- (id)initWithTitle:(NSString *)title view:(UIView *)view;
@end