//
//  Monitor.h
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

//  静态检测

//  运行时检测大工具
//  1. clarles [网络]
//  2. xcode monitor [cpu使用, memory占用, disk使用, network流量, thread使用]
//  3. instruments

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imports

#import "MonitorGateWindow.h"
#import "MonitorContentView.h"
#import "MonitorConfig.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & Constants

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

/**
 app 监控
 */
@interface Monitor : NSObject

@singleton( Monitor )

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

@property (nonatomic, strong) UIViewController *bridge;

@property (nonatomic, strong) UINavigationController *navigation;

@property (nonatomic, strong) MonitorConfig *config;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Instance Methods

- (void)showMonitorView;
- (void)dismissMonitorView;

- (void)powerOn;
- (void)powerOff;

@end
