//
//  _network.m
//  component
//
//  Created by fallen.ink on 4/18/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

/**
 *  @knowledge
 *
 *  MIME
 *
 *  PNG图像 .png image/png
 *  JPEG图形 .jpeg,.jpg image/jpeg
 *  GZIP文件 .gz application/x-gzip
 
 *  其他参考：http://baike.baidu.com/link?url=GotCMW9AMjmB1Iw1lw0G7ggQUw6rWEcS8r5aDCJbLtCkN0RwHHdquiNqturYnCqzhdh-kAh6rT-2iweaIU07ua，类型大全
 */

#import "_network.h"
#import "_net_url_cache.h"

#pragma mark - _Network

@interface _Network ()

@end

@implementation _Network

@def_singleton( _Network )
@def_prop_instance( _Client, client )
@def_prop_instance( _NetConfig, config )
@def_prop_instance( _NetworkStatus, status )
@def_prop_singleton( _NetActivityManager, activityManager )
@def_prop_instance( _DownloadStore, downloadStore )

- (instancetype)init {
    if (self = [super init]) {
        UNUSED(self.downloadStore)
        
        
        // init download
        _downloader = [[_Downloader alloc] initWithDelegate:self.downloadStore];
        
        self.downloadStore.downloader = self.downloader;
        
        [self.downloadStore setupDownloadItems];
        
        [self.downloader setupWithCompletion:nil];
    }
    
    return self;
}

- (void)enableNetCache {
    [NSURLCache setSharedURLCache:[_NetUrlCache new]];
}

@end

#pragma mark - _NetworkStatus

@implementation _NetworkStatus {
    _Reachability *_reachability;
}

- (instancetype)init {
    if (self = [super init]) {
        _reachability = [_Reachability sharedInstance];
        _reachability.hostForPing = [_Network sharedInstance].config.reachableMonitorHostname;
        _reachability.autoCheckInterval = [_Network sharedInstance].config.reachableMonitorInterval;
        
        [PingHelper sharedInstance].pingTimeoutInterval = [_Network sharedInstance].config.reachableMonitorTimeout;
        
        [self initObserver];
        
//        _onReachabilityStatus = (UBSignal<ReachabilityStatusSignal> *)[[UBSignal alloc] initWithProtocol:@protocol(ReachabilityStatusSignal)];
    }
    
    return self;
}

- (void)initObserver {
    [self observeNotification:ReachabilityChangedNotification];
}

- (void)uinitObserver {
    [self unobserveAllNotifications];
}

- (void)dealloc {
    [self uinitObserver];
}

#pragma mark - Public method

- (void)start {
    // start monitor
    [_reachability startMonitoring];
}

#pragma mark - Notification handler

- (void)handleNotification:(NSNotification *)notification {
    if ([notification is:AFNetworkingReachabilityDidChangeNotification]) {
        // 这里不作处理，主要利用Block
    } else if ([notification is:ReachabilityChangedNotification]) {
        
//        self.onReachabilityStatus.fire(@(_reachability.currentReachabilityStatus));
    }
}

#pragma mark - Property

- (void)setReachingHostname:(NSString *)reachingHostname {
    if ([reachingHostname notEmpty]) {
        _reachability.hostForPing = reachingHostname;
    }
}

- (BOOL)reachable {
    return [_reachability currentReachabilityStatus] != ReachabilityStatus_NotReachable &&
    [_reachability currentReachabilityStatus] != ReachabilityStatus_Unknown;
}

- (BOOL)reachableViaWWAN {
    return [_reachability currentReachabilityStatus] == ReachabilityStatus_ViaWWAN;
}

- (BOOL)reachableViaWiFi {
    return [_reachability currentReachabilityStatus] == ReachabilityStatus_ViaWiFi;
}

#pragma mark - Helper

+ (NSString *)descriptionOfStatus:(ReachabilityStatus)status {
    NSString *description = nil;
    
    switch (status) {
        case ReachabilityStatus_Unknown: {
            description = @"未知网络";
        }
            break;
            
        case ReachabilityStatus_NotReachable: {
            description = @"没有网络";
        }
            break;
            
        case ReachabilityStatus_ViaWWAN: {
            description = @"蜂窝移动网络上网";
        }
            break;
            
        case ReachabilityStatus_ViaWiFi: {
            description = @"WiFi上网";
        }
            break;
            
        default: {
            
        }
            break;
    }
    
    return description;
}

@end

#pragma mark - _NetActivityManager

CFStringRef _NetworkUserDescription(const void *value);

CFStringRef _NetworkUserDescription(const void *value) {
    return (__bridge CFStringRef)NSStringFromClass([(__bridge id)value class]);
}

@implementation _NetActivityManager

@def_singleton( _NetActivityManager )

- (_NetActivityManager *)init {
    return [self initWithCapacity:0];
}


- (_NetActivityManager *)initWithCapacity:(NSInteger)capacity {
    self = [super init];
    if (self) {
        CFSetCallBacks callbacks = {0, NULL, NULL, _NetworkUserDescription, NULL, NULL};
        networkUsers = CFSetCreateMutable(kCFAllocatorDefault, capacity, &callbacks);
    }
    return self;
}

- (void)dealloc {
    CFRelease(networkUsers);
}

- (void)addNetworkUser:(id)aUser {
    @synchronized (self) {
        CFSetAddValue(networkUsers, (__bridge const void *)(aUser));
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)removeNetworkUser:(id)aUser {
    @synchronized (self) {
        CFSetRemoveValue(networkUsers, (__bridge const void *)(aUser));
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (CFSetGetCount(networkUsers) > 0);
    }
}

- (void)removeAllNetworkUsers {
    @synchronized (self) {
        CFSetRemoveAllValues(networkUsers);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
