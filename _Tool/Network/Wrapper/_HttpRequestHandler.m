//
//  _HttpRequestHandler.m
//  AEAssistant_Network
//
//  Created by Altair on 7/25/16.
//  Copyright © 2016 StarDust. All rights reserved.
//

#import "_HttpRequestHandler.h"
#import "AEDKReachability.h"
#import "_HttpCookieManager.h"
#import "_ApiManager.h"
#import "_MissionListener.h"
#import "_HttpRequestManager.h"

NSString *const kHandledServerResponsedLogoutNotification = @"kHandledServerResponsedLogoutNotification";
static _HttpRequestConfiguration *_commonConfig = nil;

@interface _HttpRequestHandler ()

@property (nonatomic, strong) NSDate *startTime;

@property (nonatomic, strong) NSDate *endTime;

@property (nonatomic, strong) NSURLSessionTask *requestTask;

@property (nonatomic, copy) NSString *queryString;

- (NSStringEncoding)configStringEncoding;

- (NSTimeInterval)configTimeoutSeconds;

- (NSString *)configHttpMethod;

- (NetworkErrorBlcok)configErrorBlock;

- (NSError *)configValidResponse:(NSDictionary *)respData;

- (NSNumber *)configLogoutErrorNumber;

- (_HttpRequestUserInfo *)configRequestUserInfo;

- (BOOL)configDisplayDebugInfo;

- (NSURLRequest *)builtHttpRequest;

- (void)logBeforeRequest;

@end

@implementation _HttpRequestHandler
@synthesize urlString = _urlString, urlAliasName = _urlAliasName;
@synthesize requestDurationTime = _requestDurationTime;

#pragma mark Initialization

+ (instancetype)clientWithUrlString:(NSString *)url {
    return [[_HttpRequestHandler alloc] initWithUrlString:url];
}

- (instancetype)initWithUrlString:(NSString*)url {
    self = [self init];
    if (self) {
        self.urlString = url;
    }
    return self;
}

+ (instancetype)clientWithUrlAliasName:(NSString *)name {
    
    // fallenink
    [[_HttpRequestManager sharedInstance] syncSetupRequestConfiguration];
    
    return [[_HttpRequestHandler alloc] initWithUrlAliasName:name];
}

- (instancetype)initWithUrlAliasName:(NSString *)name {
    self = [self init];
    if (self) {
        self.urlAliasName = name;
    }
    return self;
}

#pragma mark Setter & Getter

+ (void)setCommonRequestConfiguration:(_HttpRequestConfiguration *)config {
    _commonConfig = config;
}


- (NSTimeInterval)requestDurationTime {
    NSTimeInterval duration = [self.endTime timeIntervalSinceDate:self.startTime];
    _requestDurationTime = duration;
    
    return _requestDurationTime;
}

- (void)setUrlAliasName:(NSString *)urlAliasName {
    _urlAliasName = urlAliasName;
    self.urlString = [[_ApiManager sharedInstance] getURLStringWithAliasName:urlAliasName];
}

#pragma mark Request

- (void)startHttpRequestWithSuccess:(void (^)(_HttpRequestHandler *, NSDictionary *))success failure:(void (^)(_HttpRequestHandler *, NSError *))failure {
    __weak typeof(self) weakSelf = self;
    NetworkErrorBlcok errorBlock = [weakSelf configErrorBlock];
    
    // fallenink: 生成签名后的参数
    NSDictionary *signedParameter = [self configRequestBeforeResponse:self.originalParam];
    
    if (![[AEDKReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    //请求时间置零
    _requestDurationTime = 0;
    NSURLRequest *request = [self builtHttpRequest];
    NSStringEncoding stringEncoding = [self configStringEncoding];
    [self logBeforeRequest];
    self.startTime = [NSDate date];
    
    
    
    self.requestTask = [_HttpRequestWrapper requestWithUrlRequest:request stringEncoding:stringEncoding parameter:signedParameter  success:^(NSURLRequest *request, id responseObject) {
        weakSelf.endTime = [NSDate date];
        
        [weakSelf configDisplayDebugInfo];
        
        NSError *error  = [weakSelf configValidResponse:responseObject];
        
        NSLog(@"request=%@, response=%@, error=%@", request, [NSString jsonFromObject:responseObject], error);
        
//        INFO(@"url=%@, error=%@", request.URL, error);
        
        if (error) {
            if (failure) {
                failure(weakSelf, error);
            }
            return ;
        }
        if (success) {
            success(weakSelf, responseObject);
            
            // 因为方便
            BOOL hasFinishedMission = [[responseObject objectForKey:@"task_finished"] boolValue];
            if (hasFinishedMission) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kMissionCompletedNotification object:nil];
            }
        }
    } failure:^(NSURLRequest *request, NSError *error) {
        
        
        INFO(@"request=%@, error=%@", request, error);
        
        
        weakSelf.endTime = [NSDate date];
        NSNumber *logoutNumber = [weakSelf configLogoutErrorNumber];
        if (logoutNumber && error.code == [logoutNumber integerValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHandledServerResponsedLogoutNotification object:error];
        }
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duratnion:%f, error description:%@", weakSelf.requestDurationTime, [error localizedDescription]);
        }
    }];
    [self.requestTask resume];
}

- (void)startHttpRequestWithRestParameter:(NSDictionary *)rParam originalParameter:(NSDictionary *)oParam success:(void (^)(_HttpRequestHandler *, NSDictionary *))success failure:(void (^)(_HttpRequestHandler *, NSError *))failure {
    self.restfulParam = [rParam copy];
    self.originalParam = [oParam copy];
    [self startHttpRequestWithSuccess:success failure:failure];
}

- (void)startHttpRequestWithParameter:(NSDictionary *)param success:(void (^)(_HttpRequestHandler *, NSDictionary *))success failure:(void (^)(_HttpRequestHandler *, NSError *))failure {
    
    // fallenink
    [[_HttpRequestManager sharedInstance] syncSetupRequestConfiguration];
    
    self.originalParam = [param copy];
    [self startHttpRequestWithSuccess:success failure:failure];
}

- (void)uploadFileWithConstructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))bodyData progress:(void (^)(NSProgress *))progressBlock success:(void (^)(_HttpRequestHandler *, NSDictionary *))success failure:(void (^)(_HttpRequestHandler *, NSError *))failure {
    __weak typeof(self) weakSelf = self;
    if (!bodyData) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"Http request client. No body data." code:-100 userInfo:nil];
            failure(weakSelf, error);
        }
        return;
    }
    
    NSDictionary *signedParameter = [self configRequestBeforeResponse:self.originalParam];
    
    NetworkErrorBlcok errorBlock = [weakSelf configErrorBlock];
    
    if (![[AEDKReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    
    //请求时间置零
    _requestDurationTime = 0;
    NSURLRequest *request = [self builtHttpRequest];
    NSStringEncoding stringEncoding = [self configStringEncoding];
    [self logBeforeRequest];
    self.startTime = [NSDate date];
    
    self.requestTask = [_HttpRequestWrapper uploadFileWithUrlRequest:request stringEncoding:stringEncoding parameter:signedParameter constructingBodyWithBlock:bodyData progress:progressBlock success:^(NSURLRequest *request, id responseObject) {
        
        weakSelf.endTime = [NSDate date];
        
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duration:%f, response:%@", weakSelf.requestDurationTime, [NSString jsonFromObject:responseObject]);
        }
        NSError *error  = [weakSelf configValidResponse:responseObject];
        if (error) {
            if (failure) {
                failure(weakSelf, error);
            }
            return ;
        }
        
        success(weakSelf, responseObject);
    } failure:^(NSURLRequest *request, NSError *error) {
        weakSelf.endTime = [NSDate date];
        NSNumber *logoutNumber = [weakSelf configLogoutErrorNumber];
        if (logoutNumber && error.code == [logoutNumber integerValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHandledServerResponsedLogoutNotification object:error];
        }
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duratnion:%f, error description:%@", weakSelf.requestDurationTime, [error localizedDescription]);
        }
    }];
    [self.requestTask resume];
}

- (void)downloadFileToDestination:(NSURL *(^)(NSURL *, NSURLResponse *))destination progress:(void (^)(NSProgress *))progress success:(void (^)(_HttpRequestHandler *, NSURL *))success failure:(void (^)(_HttpRequestHandler *, NSError *))failure {
    NSDictionary *signedParameter = [self configRequestBeforeResponse:self.originalParam];
    
    __weak typeof(self) weakSelf = self;
    NetworkErrorBlcok errorBlock = [weakSelf configErrorBlock];
    
    if (![[AEDKReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    
    //请求时间置零
    _requestDurationTime = 0;
    NSURLRequest *request = [self builtHttpRequest];
    NSStringEncoding stringEncoding = [self configStringEncoding];
    [self logBeforeRequest];
    self.startTime = [NSDate date];
    
    self.requestTask = [_HttpRequestWrapper downloadFileWithUrlRequest:request stringEncoding:stringEncoding parameter:signedParameter progress:progress destination:destination success:^(NSURLRequest *request, NSURL *filePath) {
        
        weakSelf.endTime = [NSDate date];
        if (!filePath) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:@"Http request client. download failed" code:-3 userInfo:nil];
                failure(weakSelf, error);
            }
            return ;
        }
        
        success(weakSelf, filePath);
    } failure:^(NSURLRequest *request, NSError *error) {
        weakSelf.endTime = [NSDate date];
        NSNumber *logoutNumber = [weakSelf configLogoutErrorNumber];
        if (logoutNumber && error.code == [logoutNumber integerValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHandledServerResponsedLogoutNotification object:error];
        }
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duratnion:%f, error description:%@", weakSelf.requestDurationTime, [error localizedDescription]);
        }
    }];
    [self.requestTask resume];
}

- (void)cancelRequest {
    if (!self.requestTask) {
        return;
    }
    [self.requestTask cancel];
}


#pragma mark Private methods

- (NSStringEncoding)configStringEncoding {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NSStringEncoding encoding = [config stringEncoding];
    if (config.stringEncoding <= 0) {
        //默认UTF-8
        encoding = NSUTF8StringEncoding;
    }
    self.endTime = [NSDate date];
    
    return encoding;
}

- (NSTimeInterval)configTimeoutSeconds {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NSTimeInterval seconds = [config timeoutSeconds];
    if (seconds <= 0) {
        //默认10秒超时
        seconds = 10;
    }
    return seconds;
}

- (NSString *)configHttpMethod {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NSString *method = [config httpMethod];
    if (!method || ![method isKindOfClass:[NSString class]] || [method length] == 0) {
        return @"GET";
    }
    return method;
}

- (NetworkErrorBlcok)configErrorBlock {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NetworkErrorBlcok block = [config errorBlock];
    return block;
}


- (NSDictionary *)configRequestBeforeResponse:(NSDictionary *)respData {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    if (config.requestBeforeBlock) {
        NSDictionary *parameter = config.requestBeforeBlock(respData);
        return parameter;
    }
    return respData;
}


- (NSError *)configValidResponse:(NSDictionary *)respData {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    if (config.validationBlock) {
        NSError *error = config.validationBlock(respData);
        return error;
    }
    return nil;
}

- (NSNumber *)configLogoutErrorNumber {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NSNumber *number = [config logoutErrorNumber];
    return number;
}

- (_HttpRequestUserInfo *)configRequestUserInfo {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    _HttpRequestUserInfo *info = [config requestUserInfo];
    return info;
}

- (BOOL)configDisplayDebugInfo {
    _HttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    BOOL display = [config displayDebugInfo];
    return display;
}

- (NSURLRequest *)builtHttpRequest {
    self.queryString = self.urlString;
    //resetful
    if ([self.restfulParam count] > 0) {
        NSMutableString *restfulParamString = [[NSMutableString alloc] init];
        [self.restfulParam enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [restfulParamString appendString:[NSString stringWithFormat:@"/%@/%@", key, obj]];
        }];
        NSUInteger insertLocation = [self.queryString rangeOfString:@"?"].location;
        if (insertLocation != NSNotFound) {
            NSMutableString *tempUrlString = [self.queryString mutableCopy];
            [tempUrlString insertString:restfulParamString atIndex:insertLocation];
            self.queryString = [tempUrlString copy];
        }
    }
    
    //append query string
    _HttpRequestUserInfo *userInfo = [self configRequestUserInfo];
    if (userInfo) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [userInfo.infoAppendingAfterQueryString enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *appendParam = [NSString stringWithFormat:@"%@=%@", key, obj];
            [tempArray addObject:appendParam];
        }];
        NSMutableString *tempString = [NSMutableString stringWithString:self.queryString];
        [tempString appendString:[tempArray componentsJoinedByString:@"&"]];
        self.queryString = [NSString stringWithString:tempString];
    }
    //init request
    NSURL *url = [NSURL URLWithString:self.queryString];
    if (!url) {
        return nil;
    } 
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (!request) {
        return nil;
    }
    //timeout
    NSTimeInterval timeOut = [self configTimeoutSeconds];
    if (timeOut <= 0) {
        timeOut = 10;
    }
    request.timeoutInterval = timeOut;
    //method
    NSString *method = [[_ApiManager sharedInstance] getURLSendDataMethodWithAliasName:self.urlAliasName];
    if (method) {
        //以interface.plist为准
        request.HTTPMethod = method;
    } else {
        //如果没有配置interface，则按照config
        request.HTTPMethod = [self configHttpMethod];
    }
    //header
    request.allHTTPHeaderFields = userInfo.infoInHttpHeader;
    
    return [request copy];
}

- (void)logBeforeRequest {
    if ([self configDisplayDebugInfo]) {
        //输出请求内容
        INFO(@"cookie:%@", [[_HttpCookieManager sharedInstance] getCookiesWithNames:@[@"version", @"device_code", @"uuid"]]);
        INFO(@"url:%@", self.queryString);
        INFO(@"rest param:%@", self.restfulParam);
        INFO(@"original param:%@", self.originalParam);
        INFO(@"query userInfo:%@", [self configRequestUserInfo].infoAppendingAfterQueryString);
        INFO(@"header userInfo:%@", [self configRequestUserInfo].infoInHttpHeader);
        INFO(@"timeout:%f", [self configTimeoutSeconds]);
    }
}

@end
