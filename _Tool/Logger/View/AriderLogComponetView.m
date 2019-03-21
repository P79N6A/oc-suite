//
//  AriderLogComponetView.m
//  LogTest
//
//  Created by 君展 on 13-8-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogComponetView.h"
#import <QuartzCore/QuartzCore.h>
#import "AriderLogManager.h"
#import "AriderTool.h"

@interface AriderLogComponetView ()

@end

@implementation AriderLogComponetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self setFrameWhenAwake];
    [self setupContentView];
    [self setupLoggo];
}

- (void)setFrameWhenAwake{
    if(isiPhoneX){
        self.frame = CGRectMake(0, ALOG_STATUS_BAR_HEIGHT*2, [AriderTool screenWidth], [AriderTool screenHeight]-ALOG_STATUS_BAR_HEIGHT*2);
    }else{
        self.frame = CGRectMake(0, ALOG_STATUS_BAR_HEIGHT, [AriderTool screenWidth], [AriderTool screenHeight]-ALOG_STATUS_BAR_HEIGHT);
    }
    self.menuScrollView.frame = CGRectMake(0, 0, [AriderTool screenWidth], ALOG_SEGMENT_HEIGHT);
    self.menuSegmentedControl.frame = CGRectMake(-10, 0, 10+[AriderTool screenWidth]+10, self.menuSegmentedControl.bounds.size.height);
    self.contentView.frame = CGRectMake(0, ALOG_SEGMENT_HEIGHT, [AriderTool screenWidth], ALOG_SUB_COMPONET_VIEW_HEIGHT);
}

- (void)setupContentView{
    self.logDisplayView = [[[NSBundle mainBundle] loadNibNamed:@"AriderLogDisplayView" owner:self options:nil] objectAtIndex:0];
    self.logFilterView = [[[NSBundle mainBundle] loadNibNamed:@"AriderLogFilterView" owner:self options:nil] objectAtIndex:0];
    self.logConfigView = [[[NSBundle mainBundle] loadNibNamed:@"AriderLogConfigView" owner:self options:nil] objectAtIndex:0];
    [self.menuSegmentedControl removeAllSegments];
    [self insertSegmentWithTitle:@"日志" view:self.logDisplayView atIndex:0];
    [self insertSegmentWithTitle:@"过滤" view:self.logFilterView atIndex:1];
    [self insertSegmentWithTitle:@"设置" view:self.logConfigView atIndex:2];
    [self showSegmentAtIndex:0];
}

- (void)setupLoggo{
    if(isiPhoneX){
        _loggoWindow = [[UIWindow alloc] initWithFrame:CGRectMake([AriderTool screenWidth]-83, 0, 44, ALOG_STATUS_BAR_HEIGHT)];
    }else{
        _loggoWindow = [[UIWindow alloc] initWithFrame:CGRectMake([AriderTool screenWidth]-120, 0, 44, ALOG_STATUS_BAR_HEIGHT)];
    }
    _loggoWindow.windowLevel = UIWindowLevelAlert+1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowChange:) name:UIWindowDidBecomeKeyNotification object:nil];
    
    if([AriderTool isSystemVersionGreaterThan7]){
        _loggoWindow.layer.borderColor = [UIColor orangeColor].CGColor;
        _loggoWindow.backgroundColor = [UIColor orangeColor];
        _loggoWindow.layer.borderWidth = 1;
    }
    
    _loggoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loggoButton.frame = _loggoWindow.bounds;
    [_loggoButton setTitle:@"ALog" forState:UIControlStateNormal];
    [_loggoButton addTarget:self action:@selector(loggoButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [_loggoWindow addSubview:_loggoButton];
    
    _loggoWindow.hidden = NO;
}

- (void)windowChange:(NSNotification *)notification{
//    NSLog(@"windowChange=%@", notification);
    if([notification.name isEqualToString:UIWindowDidBecomeKeyNotification] && notification.object == _loggoWindow){
//        NSLog(@"notification.object == _loggoWindow");
        [[[[UIApplication sharedApplication] delegate] window]
         makeKeyWindow];
    }
}

#pragma mark property

- (NSMutableArray *)segmentModelArray{
    if(!_segmentModelArray){
        _segmentModelArray = [[NSMutableArray alloc] init];
    }
    return _segmentModelArray;
}
#pragma mark action
- (void)loggoButtonPress:(UIButton *)sender{
    if([AriderLogManager sharedManager].isShowLogView){
        [[AriderLogManager sharedManager] hideLogView];
    }else{
        [[AriderLogManager sharedManager] showLogView];
    }
}

- (IBAction)logComponetSegmentChanged:(UISegmentedControl *)sender {
    [self showSegmentAtIndex:sender.selectedSegmentIndex];
}
#pragma mark segment operation

- (void)insertSegmentWithTitle:(NSString *)title view:(UIView *)view atIndex:(NSUInteger)segment{
    AriderLogSegmentModel *segmentModel = [[AriderLogSegmentModel alloc] initWithTitle:title view:view];
    [self.segmentModelArray insertObject:segmentModel atIndex:segment];
    
    self.menuSegmentedControl.frame = CGRectMake(0, 0, MAX(self.segmentModelArray.count*60, [AriderTool screenWidth]), self.menuSegmentedControl.bounds.size.height);
    self.menuScrollView.contentSize = CGSizeMake(self.menuSegmentedControl.frame.size.width, self.menuScrollView.bounds.size.height);
    [self.menuSegmentedControl insertSegmentWithTitle:title atIndex:segment animated:NO];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment{
    [self.menuSegmentedControl removeSegmentAtIndex:segment animated:NO];
    [self.segmentModelArray removeObjectAtIndex:segment];
}

- (void)showSegmentAtIndex:(NSUInteger)segment{
    for (AriderLogSegmentModel *model in self.segmentModelArray){
        [model.view removeFromSuperview];
    }
    AriderLogSegmentModel *selectedModel = [self.segmentModelArray objectAtIndex:segment];
    [self.contentView addSubview:selectedModel.view];
    self.menuSegmentedControl.selectedSegmentIndex = segment;
}

@end

@implementation AriderLogSegmentModel
- (id)initWithTitle:(NSString *)title view:(UIView *)view{
    self = [super init];
    if(self){
        self.title = title;
        self.view = view;
    }
    return self;
}
@end

