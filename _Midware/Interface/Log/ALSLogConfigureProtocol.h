//
//  ALSLogConfigureProtocol.h
//  wesg
//
//  Created by 7 on 22/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

// 日志模块需要 组件化设计
// Log
// LogConfig
// LogUpload
// CrashReport
@protocol ALSLogConfigureProtocol <NSObject>

@property (nonatomic, assign) BOOL enabledLocalLog;
@property (nonatomic, assign) BOOL enabledRemoteLog;


@end
