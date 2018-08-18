//
//  _net_error.m
//  component
//
//  Created by fallen.ink on 4/24/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_net_error.h"

#pragma mark -

@implementation _NetError

+ (NSError *)visually:(NSError *)httpError {
    switch (httpError.code) {
        case NetError_TimeOut:
        case NetError_UnsupportedURL:
        case NetError_CannotFindHost:
        case NetError_CannotConnectToHost:
        case NetError_NetworkConnectionLost:
        {
            return [NSError networkBrokenError];
        }
            break;
            
        case NetError_CookieExpired:
        {
            return [NSError cookieExpiredError];
        }
            break;
            
        default:
        {
            return httpError;
        }
            break;
    }
    
    
    
}

+ (BOOL)statusCodeValidator:(NSInteger)statusCode {
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

@end

#pragma mark - NSError ( Network )

@implementation NSError ( Network )

@def_error( timeoutError, NetError_TimeOut, @"请求超时" )

@def_error( networkBrokenError, NetError_NetWorkBroken, @"您的网络不给力" )

@def_error( cookieExpiredError, NetError_CookieExpired, @"请重新登陆" )

@def_error( unsupportedVersionError, NetError_UnsupportedVersion, @"The current server version does not support our request.");

@def_error( jsonDataInvalidError, NetError_JsonDataInvalid, @"Json data is not valid.")

@end
