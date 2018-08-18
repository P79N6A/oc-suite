//
//  AEReachability.h
//  AEAssistant
//
//  Created by Qian Ye on 16/4/22.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NetKNetworkStatusUnknown = -1,
    NetKNetworkStatusNotReachable = 0,
    NetKNetworkStatusCellType2G = 1,
    NetKNetworkStatusCellType3G = 2,
    NetKNetworkStatusCellType4G = 3,
    NetKNetworkStatusReachableViaWiFi = 4,
}NetKNetworkStatus;

@interface NetKReachability : NSObject

@property (strong, nonatomic) NSString *domain;

@property (nonatomic, readonly) BOOL isNetworkStatusOK;

@property (nonatomic, readonly) NetKNetworkStatus status;

@property (nonatomic, readonly) BOOL isMonitoring;

+ (instancetype)sharedInstance;

//开始网络状态监控
- (void)startNetworkMonitoringWithStatusChangeBlock:(void(^)(NetKNetworkStatus status))block;
//停止网络状态监控
- (void)stopNetworkStatusMonitoring;

@end
