//
//  AEHttpRequestUserInfo.m
//  AEAssistant_Network
//
//  Created by Altair on 7/27/16.
//  Copyright © 2016 StarDust. All rights reserved.
//

#import "_HttpRequestUserInfo.h"

@implementation _HttpRequestUserInfo

+ (instancetype)infoWithAppending:(NSDictionary<NSString *,NSString *> *)appendingInfo andHeader:(NSDictionary<NSString *,NSString *> *)headerInfo {
    _HttpRequestUserInfo *info = [[_HttpRequestUserInfo alloc] init];
    info.infoAppendingAfterQueryString = appendingInfo;
    info.infoInHttpHeader = headerInfo;
    
    return info;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    _HttpRequestUserInfo *userInfo = [[_HttpRequestUserInfo alloc] init];
    [userInfo setInfoAppendingAfterQueryString:[[self infoAppendingAfterQueryString] copy]];
    [userInfo setInfoInHttpHeader:[[self infoInHttpHeader] copy]];
    
    return userInfo;
}

@end
