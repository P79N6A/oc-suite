//
//  _app_config.m
//  student
//
//  Created by fallen.ink on 13/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_app_config.h"

@implementation _AppConfig

@def_singleton( _AppConfig )

@def_prop_singleton( _AppRater, rater )

- (instancetype)init {
    if (self = [super init]) {
        self.enabledLaunchAdvertise = NO;
        self.launchAdvertiseDuration = 3.f;
        
        //
        _platformName       = @"ios";
        _appName            = app_display_name;
        _appVersion         = app_version;
        
        NSString *bundleId = app_bundle_id;
        NSArray *bundleStrs = [bundleId componentsSeparatedByString:@"."];
        _appIdentifier = [bundleStrs safeStringAtIndex:2];
        
        NSString *appVersionSerialString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFApplicationVersionSerial"];
        _appVersionSerial = [appVersionSerialString intValue];
    }
    
    return self;
}

// 后台请求统一添加appplatform, appname, appversion三个字段，方便线上问题紧急修复（带URL域名）
// 后台请求统一添加guid（唯一标示符），方便后台分析日志（带URL域名）
- (NSString *)appDescription {
    static NSString *const apppltFirstSubStr = @"?appplatform=";
    static NSString *const appnameFirstSubStr = @"?appname=";
    static NSString *const appverFirstSubStr = @"?appversion=";
    static NSString *const guidFirstSubStr = @"?guid=";
    
    static NSString *const apppltNotFirstSubStr = @"&appplatform=";
    static NSString *const appnameNotFirstSubStr = @"&appname=";
    static NSString *const appverNotFirstSubStr = @"&appversion=";
    static NSString *const guidNotFirstSubStr = @"&guid=";
    
    NSMutableString *resultString = [NSMutableString new];
    if (([resultString rangeOfString:apppltFirstSubStr].location == NSNotFound) && ([resultString rangeOfString:apppltNotFirstSubStr].location == NSNotFound)) {
        [resultString appendFormat:@"%@%@", ([resultString rangeOfString:@"?"].location == NSNotFound) ? apppltFirstSubStr : apppltNotFirstSubStr, self.platformName];
    }
    if (([resultString rangeOfString:appnameFirstSubStr].location == NSNotFound) && ([resultString rangeOfString:appnameNotFirstSubStr].location == NSNotFound)) {
        [resultString appendFormat:@"%@%@", appnameNotFirstSubStr, self.appName];
    }
    if (([resultString rangeOfString:appverFirstSubStr].location == NSNotFound) && ([resultString rangeOfString:appverNotFirstSubStr].location == NSNotFound)) {
        [resultString appendFormat:@"%@%@", appverNotFirstSubStr, app_bundle_name];
    }
    if (([resultString rangeOfString:guidFirstSubStr].location == NSNotFound) && ([resultString rangeOfString:guidNotFirstSubStr].location == NSNotFound)) {
        [resultString appendFormat:@"%@%@", guidNotFirstSubStr, [[_Device sharedInstance] deviceUDID]];
    }
    
    return resultString;
}

@end
