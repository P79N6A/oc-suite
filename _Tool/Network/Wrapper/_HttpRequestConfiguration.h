//
//  _HttpRequestConfiguration.h
//  AEAssistant_Network
//
//  Created by Altair on 7/27/16.
//  Copyright © 2016 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_HttpRequestUserInfo.h"

static NSString *const kErrMsgKey = @"kErrMsgKey";

#define API_RESPONSE_VALID                  (0)

#define API_RESPONSE_LOGINFAILED            (3000)
#define API_RESPONSE_USERNOTFOUND           (3001)
#define API_RESPONSE_VERIFYFAILED           (3002)
#define API_RESPONSE_LESSALIUID             (3003)
#define API_RESPONSE_LESSSID                (3004)
#define API_RESPONSE_LESSFLOWER             (3100)
#define API_RESPONSE_LESSSHELL              (3101)
#define API_RESPONSE_LESSPEARL              (3102)

#define API_RESPONSE_NEEDUPDATE             (998)
#define API_RESPONSE_OPERATIONFULLFILLED    (700)


typedef void(^ NetworkErrorBlcok) (NSError *error);
typedef void(^ NetworkSuccessBlcok) (NSDictionary *response);
typedef NSDictionary *(^ NetworkBeforeRequestBlcok) (NSDictionary *parameter);
typedef NSError *(^ResponseValidation)(NSDictionary *responseData);

@interface _HttpRequestConfiguration : NSObject <NSCopying>
//字符编码
@property (nonatomic, assign) NSStringEncoding stringEncoding;
//超时时间
@property (nonatomic, assign) NSTimeInterval timeoutSeconds;
//method
@property (nonatomic, copy) NSString *httpMethod;
//网络错误回调
@property (nonatomic, copy) NetworkErrorBlcok errorBlock;
//登出错误码
@property (nonatomic, strong) NSNumber *logoutErrorNumber;
//请求的附加用户信息
@property (nonatomic, strong) _HttpRequestUserInfo *requestUserInfo;
//是否开启日志
@property (nonatomic, assign) BOOL displayDebugInfo;
//返回值验证
@property (nonatomic, copy) ResponseValidation validationBlock;

@property (nonatomic, copy) NetworkBeforeRequestBlcok requestBeforeBlock;

//重试次数
//@property (nonatomic, assign) NSUInteger retryCount;

//默认配置
+ (instancetype)defaultConfiguration;

@end
