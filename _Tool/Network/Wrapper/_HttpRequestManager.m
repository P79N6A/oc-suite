//
//  _HttpRequestManager.m
//  wesg
//
//  Created by Altair on 8/5/16.
//  Copyright © 2016 AliSports. All rights reserved.
//

#import "_HttpCookieManager.h"
#import "_HttpRequestManager.h"
#import "_HttpRequestHandler.h"
#import "_HttpRequestConfiguration.h"
#import "AEDKReachability.h"
#import "_MD5.h"

NSString *const kRequestParamKeyPartner = @"partner";
NSString *const kRequestParamKeyUUID = @"uuid";
NSString *const kRequestParamKeyDevice = @"device";
NSString *const kRequestParamKeyNet = @"net";
NSString *const kRequestParamKeyScreen = @"screen";
NSString *const kRequestParamKeyOS = @"os";
NSString *const kRequestParamKeyOSVersion = @"osVer";
NSString *const kRequestParamKeyClientVersion = @"clientVer";

static NSString *const syncKey = @"syncKey";

@interface _HttpRequestManager ()

- (void)setupParams;

@end

@implementation _HttpRequestManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupParams];
    }
    return self;
}

@def_singleton( _HttpRequestManager )

#pragma mark Private methods

   //* 1. 参数加入时间戳字段,字段名称: timestamp
   //* 2. 对所有参数按照key升序排列
   //* 3. 将所有的参数以 key+value 的方式拼接为字符串
   //* 4. 在字符串尾部加固定字符串,占定 '123456789abc'
   //* 5. 将字符串用md5加密后,取5-20位,得到签名字符串,字段名称sign
   //* 6. 将sign放在参数中传到服务器端

- (NSDictionary *)signedDictionaryForParameter:(NSDictionary *)parameter {
   NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithDictionary:parameter];
   
   NSString *timestampString = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970] ];
   [tempDictionary setObject:timestampString forKey:@"timestamp"];
   
   NSString *signString = [self codeSignStringForParameter:tempDictionary];
   [tempDictionary setObject:signString forKey:@"sign_string"];
   
   return tempDictionary;
}

- (NSString *)codeSignStringForParameter:(NSDictionary *)parameter{
    NSString *keyValueString = [self keyValueSortedStringForDictionary:parameter];
    keyValueString = [keyValueString stringByAppendingString:@"123456789abc"];
   
    NSString *uuidString = self.uid ?: @""; // [AESUser currentUser]
    
    if (uuidString.length > 0) {
       uuidString = [uuidString substringWithRange:NSMakeRange(2, 6)];
    }
   
    uuidString = [uuidString stringByAppendingString:keyValueString];
   
    NSString *md5String = [[uuidString stringFromMD5] substringWithRange:NSMakeRange(4, 16)];
    return md5String;
}


- (NSString *)keyValueSortedStringForDictionary:(NSDictionary *)dictionary {
   NSArray *keys = [dictionary allKeys];
   NSArray *sortedKyes = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
       return [obj1 compare:obj2 options:NSNumericSearch];
   }];
   
   NSString *string = @"";
   for (NSString *key in sortedKyes) {
       NSString *valueString = nil;
       id value = dictionary[key];
       if ([value isKindOfClass:[NSNumber class]]) {
           valueString = [value stringValue];
       } else {
           valueString = value;
       }
    
       if ([valueString isKindOfClass:[NSString class]] ) {
           string = [string stringByAppendingString:key];
           string = [string stringByAppendingString:valueString];
       }
   }
   return string;
}

- (void)setupParams {
    NSString *netStatus = @"unknown";
    switch ([[AEDKReachability sharedInstance] status]) {
        case AEDKNetworkStatusNotReachable:
        {
            netStatus = @"off";
        }
            break;
        case AEDKNetworkStatusCellType2G:
        {
            netStatus = @"2G";
        }
            break;
        case AEDKNetworkStatusCellType3G:
        {
            netStatus = @"3G";
        }
            break;
        case AEDKNetworkStatusCellType4G:
        {
            netStatus = @"4G";
        }
            break;
        case AEDKNetworkStatusReachableViaWiFi: {
            netStatus = @"wifi";
        }
            break;
        default:
            break;
    }
    
    if (!_params) {
        //未设置
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        
        
        //partner
        [tempDic setObject:@"AppStore" forKey:kRequestParamKeyPartner];
        //uuid
        NSString *udid = [[_Device sharedInstance] deviceUDID];
        if (udid) {
            [tempDic setObject:udid forKey:kRequestParamKeyUUID];
        }
        //device
        NSString *device = [[_Device sharedInstance] deviceVersion];
        if (device) {
            [tempDic setObject:device forKey:kRequestParamKeyDevice];
        }
        //screen
        [tempDic setObject:[NSString stringWithFormat:@"%.f*%.f", screen_width * 2, screen_height * 2] forKey:kRequestParamKeyScreen];
        //os
        [tempDic setObject:@"iOS" forKey:kRequestParamKeyOS];
        //osVer
        NSString *osVer = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] systemVersion]];
        if (osVer) {
            [tempDic setObject:osVer forKey:kRequestParamKeyOSVersion];
        }
        
        NSString *clientVer = app_version;
        if (clientVer) {
            [tempDic setObject:clientVer forKey:kRequestParamKeyClientVersion];
        }
        //net
        [tempDic setObject:netStatus forKey:kRequestParamKeyNet];
        
        @synchronized (syncKey) {
            _params = [tempDic copy];
        }
    } else {
        //已设置
        NSMutableDictionary *tempDic = [_params mutableCopy];
        
        
        //net
        [tempDic setObject:netStatus forKey:kRequestParamKeyNet];
        
        @synchronized (syncKey) {
            _params = [tempDic copy];
        }
    }
}

#pragma mark Public methods

- (void)asyncSetupRequestConfiguration {
    [self setupRequestConfiguration:YES];
}

- (void)syncSetupRequestConfiguration {
    [self setupRequestConfiguration:NO];
}

- (void)setupRequestConfiguration:(BOOL)async {
    if (async) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self setupParams];
            [[_HttpCookieManager sharedInstance] setIcsonCookieWithName:@"version" andValue:app_version];
            [[_HttpCookieManager sharedInstance] setIcsonCookieWithName:@"device_token" andValue:[[_Device sharedInstance] deviceUDID]];
            _HttpRequestConfiguration *config = [self commonHttpRequestConfiguration];
            [_HttpRequestHandler setCommonRequestConfiguration:config];
        });
    } else {
        [self setupParams];
        [[_HttpCookieManager sharedInstance] setIcsonCookieWithName:@"version" andValue:app_version];
        [[_HttpCookieManager sharedInstance] setIcsonCookieWithName:@"device_token" andValue:[[_Device sharedInstance] deviceUDID]];
        _HttpRequestConfiguration *config = [self commonHttpRequestConfiguration];
        [_HttpRequestHandler setCommonRequestConfiguration:config];
    }
}

- (void)resetRequestConfiguration {
    @synchronized (syncKey) {
        _params = nil;
        [_HttpRequestHandler setCommonRequestConfiguration:[self commonHttpRequestConfiguration]];
    }
}

- (_HttpRequestConfiguration *)commonHttpRequestConfiguration {
    _HttpRequestConfiguration *requestConfig = [_HttpRequestConfiguration defaultConfiguration];
    
    //query append info
    if ([self.params count] > 0) {
        if (!requestConfig.requestUserInfo) {
            requestConfig.requestUserInfo = [_HttpRequestUserInfo infoWithAppending:nil andHeader:nil];
        }
        NSString *userAgentString = @"esports-platform;iOS";
        requestConfig.requestUserInfo.infoInHttpHeader = [NSDictionary dictionaryWithObjectsAndKeys:userAgentString, @"User-Agent", [[UIDevice currentDevice] systemVersion], @"sys-version", nil];
    }
    //response validation
    [requestConfig setValidationBlock:^(NSDictionary *responseData) {
        if (responseData == nil) {
            NSError *error = [NSError errorWithDomain:@"Http request client. ResponseObject nil." code:-301 userInfo:nil];
            return error;
        }
        if (responseData == NULL) {
            NSError *error = [NSError errorWithDomain:@"Http request client. ResponseObject  NULL." code:-302 userInfo:nil];
            return error;
        }
        if (![responseData isKindOfClass:[NSDictionary class]]) {
            NSError *error = [NSError errorWithDomain:@"Http request client. ResponseObject not Object." code:-303 userInfo:nil];
            return error;
        }
        NSInteger errorNo = [[responseData objectForKey:@"res_code"] integerValue];
        if (errorNo != API_RESPONSE_VALID) {
            if (errorNo == API_RESPONSE_OPERATIONFULLFILLED) {
                LOG(@"操作已完成");
            } else {
                NSError *error = nil;
                if ([responseData objectForKey:@"res_msg"]) {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[responseData objectForKey:@"res_msg"] forKey:kErrMsgKey];
                    error = [NSError errorWithDomain:@"Http request client." code:errorNo userInfo:userInfo];
                }
                if (errorNo == API_RESPONSE_LOGINFAILED || errorNo == API_RESPONSE_USERNOTFOUND || errorNo == API_RESPONSE_VERIFYFAILED || errorNo == API_RESPONSE_LESSALIUID || errorNo == API_RESPONSE_LESSSID) {
                    //登录失效
                    if (self.shouldLogoutHandler) self.shouldLogoutHandler(responseData);
                }
                if (errorNo == API_RESPONSE_NEEDUPDATE) {
                    
                    //需要更新
                    if (self.shouldUpdateAppHandler) self.shouldUpdateAppHandler(responseData);
                }
                
                return error;
            }
        }
        
        return (NSError *)nil;
    }];
    

    weakly(self)
    
    // 配置请求参数
    [requestConfig setRequestBeforeBlock:^(NSDictionary *originalParameter){
        
        NSDictionary *signedDictionary = [_ signedDictionaryForParameter:originalParameter];
        NSLog(@"signedDictionary **************** originalParameter:%@  \n signedDictionary : %@ ",originalParameter,signedDictionary);
        
        return signedDictionary;
    }];
    
    //log
#ifdef DEBUG
    requestConfig.displayDebugInfo = YES;
#else
    requestConfig.displayDebugInfo = NO;
#endif
    
    return requestConfig;
}




@end
