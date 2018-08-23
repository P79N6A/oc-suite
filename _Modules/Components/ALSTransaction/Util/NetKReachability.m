//
//  AEReachability.m
//  AEAssistant
//
//  Created by Qian Ye on 16/4/22.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "NetKReachability.h"
#import "NetKNetworkReachabilityManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

static NetKReachability *_sharedManager = nil;

@interface NetKReachability ()

@property (nonatomic, strong) NetKNetworkReachabilityManager *reachabilityManager;

@end

@implementation NetKReachability
@synthesize domain;
@synthesize isNetworkStatusOK = _isNetworkStatusOK;
@synthesize reachabilityManager;
@synthesize status = _status;

- (id)init
{
    self = [super init];
    if (self) {
        //默认有效,因为监控开始时网络状态未知
        _isNetworkStatusOK = YES;
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate = 0;
    
    dispatch_once(&predicate, ^ (void) {
        _sharedManager = [[NetKReachability alloc] init];
    });
    
    return _sharedManager;
}

- (void)startNetworkMonitoringWithStatusChangeBlock:(void (^)(NetKNetworkStatus))block
{
    //初始化网络状态监控
    if (self.domain && ![self.domain isEqualToString:@""]) {
        self.reachabilityManager = [NetKNetworkReachabilityManager managerForDomain:self.domain];
    } else {
        self.reachabilityManager = [NetKNetworkReachabilityManager sharedManager];
    }
    [self.reachabilityManager startMonitoring];
    _isMonitoring = YES;
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.reachabilityManager setReachabilityStatusChangeBlock:^(NetKNetworkReachabilityStatus status){
        NetKNetworkStatus netStatus = NetKNetworkStatusUnknown;
        switch (status) {
            case NetKNetworkReachabilityStatusUnknown:
            {
                _isNetworkStatusOK = NO;
                _status = NetKNetworkStatusUnknown;
                netStatus = NetKNetworkStatusUnknown;
            }
                break;
            case NetKNetworkReachabilityStatusNotReachable:
            {
                _isNetworkStatusOK = NO;
                _status = NetKNetworkStatusNotReachable;
                netStatus = NetKNetworkStatusNotReachable;
            }
                break;
            case NetKNetworkReachabilityStatusReachableViaWWAN:
            {
                _isNetworkStatusOK = YES;
                //os version > 7.0
                CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
                NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
                if (currentRadioAccessTechnology) {
                    if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                        _status = NetKNetworkStatusCellType4G;
                        netStatus = NetKNetworkStatusCellType4G;
                    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                        _status = NetKNetworkStatusCellType2G;
                        netStatus = NetKNetworkStatusCellType2G;
                    } else {
                        _status = NetKNetworkStatusCellType3G;
                        netStatus = NetKNetworkStatusCellType3G;
                    }
                }
            }
                break;
            case NetKNetworkReachabilityStatusReachableViaWiFi:
            {
                _isNetworkStatusOK = YES;
                _status = NetKNetworkStatusReachableViaWiFi;
                netStatus = NetKNetworkStatusReachableViaWiFi;
            }
                break;
            default:
                break;
        }
        
        if (block) {
            block(netStatus);
        }
    }];
    
}


- (void)stopNetworkStatusMonitoring
{
    [[NetKNetworkReachabilityManager sharedManager] stopMonitoring];
    
    _isNetworkStatusOK = NO;
    _isMonitoring = NO;
}

@end
