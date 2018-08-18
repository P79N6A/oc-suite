//
//  _net_error.h
//  component
//
//  Created by fallen.ink on 4/24/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_greats.h"

/**
 预定义的网络错误
 */
typedef enum : NSInteger {
    // ======= 延承 NSURLError 错误类型
    NetError_TimeOut  = NSURLErrorTimedOut,
    NetError_UnsupportedURL = NSURLErrorUnsupportedURL, // -1002
    NetError_CannotFindHost = NSURLErrorCannotFindHost, // -1003
    NetError_CannotConnectToHost = NSURLErrorCannotConnectToHost, // -1004
    NetError_NetworkConnectionLost = NSURLErrorNetworkConnectionLost, // -1005
    
    // ======= 服务器 类型
    NetError_CookieExpired = 1301,
    
    // ======= 自定义 类型
    NetError_Start = 9999,
    NetError_NetWorkBroken = 10000,
    
    NetError_UnsupportedVersion,
    NetError_JsonDataInvalid,
} NetErrorType;

#pragma mark -

@interface _NetError : NSObject

/**
 *  将错误的原因中，嵌入查问题的思路
 *
 *  @param httpError 常规HTTP错误
 *
 *  @return 嵌入信息后的错误对象
 */
+ (NSError *)visually:(NSError *)httpError;

/**
 *  检查http状态码
 *
 *  @param statusCode 状态码
 *
 *  @return NO 有错误需要关注
 */
+ (BOOL)statusCodeValidator:(NSInteger)statusCode;

@end

#pragma mark - NSError ( Network )

@interface NSError ( Network )

@error( timeoutError )

@error( networkBrokenError )

@error( cookieExpiredError )

/**
 *  请求版本不对应错误
 */
@error( unsupportedVersionError )

/**
 *  json数据不合法
 */
@error( jsonDataInvalidError )

@end
