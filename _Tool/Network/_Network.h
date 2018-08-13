//
//  _network.h
//  component
//
//  Created by fallen.ink on 4/18/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_greats.h"
#import "_vendor_afnetworking.h"
#import "_net_error.h"
#import "_client.h"
#import "_net_config.h"
#import "_real_reachability.h"

#import "loader/_loader.h"

#import "extension/NSHTTPCookieStorage+JKFreezeDry.h"
#import "extension/NSMutableURLRequest+JKUpload.h"
#import "extension/NSString+JKHTML.h"
#import "extension/NSString+JKMIME.h"
#import "extension/NSString+Rest.h"
#import "extension/NSURLRequest+JKParamsFromDictionary.h"
#import "extension/NSURLSession+JKSynchronousTask.h"
#import "extension/NSURL+Extension.h"
#import "extension/NSURL+JKParam.h"
#import "extension/NSURL+JKQueryDictionary.h"

#pragma mark -

@class _NetworkStatus;
@class _NetActivityManager;

#pragma mark - _Network

@interface _Network : NSObject

@singleton( _Network )

@prop_instance( _Client, client )
@prop_instance( _NetConfig, config )
@prop_instance( _NetworkStatus, status )
@prop_instance( _DownloadStore, downloadStore )
@prop_singleton( _NetActivityManager, activityManager )

@property (nonatomic, strong, readonly) _Downloader *downloader;

/**
 *  Enable net cache, when u use GET?????
 */
- (void)enableNetCache;

@end

#define networkInst [_Network sharedInstance]

#pragma mark - _NetworkStatus

/**
 *  侦测网络状态变化
 */

@interface _NetworkStatus : NSObject

/**
 *  Whether or not the network is currently reachable.
 */
@property (readonly, nonatomic, assign) BOOL reachable;

/**
 *  Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign) BOOL reachableViaWWAN;

/**
 *  Whether or not the network is currently reachable via WiFi.
 */
@property (readonly, nonatomic, assign) BOOL reachableViaWiFi;

/**
 *  网络状态 信号观察
 */
// Usage: https://github.com/uber/signals-ios
//@property (nonatomic, readonly) UBSignal<ReachabilityStatusSignal> *onReachabilityStatus;

/**
 *  Start to monitor network reachability status
 */
- (void)start;

/**
 *  Utility method for description of network reachability status
 *
 *  @param status ReachabilityStatus
 *
 *  @return Description of network reachability status
 */
+ (NSString *)descriptionOfStatus:(ReachabilityStatus)status;

@end

#pragma mark - _NetActivityManager

@interface _NetActivityManager : NSObject {
    CFMutableSetRef networkUsers;
}

@singleton( _NetActivityManager )

- (_NetActivityManager *)initWithCapacity:(NSInteger)capacity;

- (void)addNetworkUser:(id)aUser;

- (void)removeNetworkUser:(id)aUser;

- (void)removeAllNetworkUsers;

@end


