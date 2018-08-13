//
//  _net_config.h
//  component
//
//  Created by fallen.ink on 4/22/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_vendor_afnetworking.h"
#import "_UrlArgumentsFilterProtocol.h"

// ----------------------------------
// 说明：
// ----------------------------------

// 统一设置网络请求的 服务器地址 和 CDN 的地址
// 主服务地址：
// CND 地址：大部分企业应用都需要对一些静态资源（例如图片、js、css）使用CDN

//

#pragma mark -

@interface _NetConfig : NSObject

/**
 *  Url 信息
 */
@property (nonatomic, strong) NSString  *cdnUrl;
@property (nonatomic, strong) NSString  *baseUrl; // 主服务url

@property (nonatomic, strong) NSString *imageUrl; // 图片服务地址

@property (nonatomic, strong) NSString *imageStoreUrl; // 图片存储服务器

@property (nonatomic, strong) NSString *advertiseHtmlUrl; // 广告相关url

@property (nonatomic, strong) NSString *staticHtmlUrl; // 常规静态页面url

/**
 *  请求、应答的nsdata编码
 */
@property (nonatomic, assign) NSStringEncoding dataEncoding;


/**
 *  安全
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/**
 *  超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  重试机制
 */
@property (nonatomic, assign) NSInteger retryCount;

/**
 *  Host name of user wanna ping to .
 */
@property (nonatomic, strong) NSString *reachableMonitorHostname;

/**
 *  Time interval of reachability monitor checking cycle.
 
 *  In minutes.
 */
@property (nonatomic, assign) NSTimeInterval reachableMonitorInterval;

/**
 *  Time out of reachability monitor checking once.
 
 *  In seconds
 */
@property (nonatomic, assign) NSTimeInterval reachableMonitorTimeout;

/**
 *  默认实例
 
 *  url 信息无法默认
 
 *  security:
 
 *  重试次数: 3
 */
+ (instancetype)defaultConfig;

- (void)addUrlFilter:(id<_UrlArgumentsFilterProtocol>)filter;

@end

#pragma mark - Url helper

@protocol _NetModelProtocol;

@interface _NetConfig ( HttpHelper )

/**
 *  拼装 URL
 */
- (NSString *)buildRequestUrlWithNetModelProtocol:(id<_NetModelProtocol>)prot;

/**
*  重试机制，要好好处理
*/

/**
*  兼容cdn url列表？？？
*/


@end
