//
//  _net_request.m
//  component
//
//  Created by fallen.ink on 4/22/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_net_request.h"
#import "_network.h"
#import "_model.h"
#import "_network_private.h"
#import "_pragma_push.h"

// inspired by https://github.com/yuantiku/YTKNetwork/blob/master/BasicGuide.md

// YTKRequest类，通过覆盖父类的一些方法来构造指定的网络请求。把每一个网络请求封装成对象其实是使用了设计模式中的 Command 模式。

@implementation _NetRequest

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        [self initDefault];
    }
    
    return self;
}

- (void)initDefault {
    _requestAccessories = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    
    _retryCount = [_Network sharedInstance].config.retryCount;
    _retryIndex = 0;
    
    _valid = YES;
}

#pragma mark - Private

- (void)clear {
    // nil out to break the retain cycle.
    
    // 做保护
    self.constructingBodyBlock = nil;
    self.successHandler = nil;
    self.progressHandler = nil;
    self.failureHandler = nil;
}

#pragma mark - _NetModelProtocol

- (id<_NetModelProtocol>)this {
    return self.requestData;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSMutableDictionary *httpHeaders = [NSMutableDictionary new];
    NSDictionary *headersOfModel = self.requestData.requestHeaderFieldValueDictionary;
    NSDictionary *headersOfUserAppending = self.HTTPHeader;
    
    if (headersOfModel) {
        [httpHeaders addEntriesFromDictionary:headersOfModel];
    }
    
    if (headersOfUserAppending) {
        [httpHeaders addEntriesFromDictionary:headersOfUserAppending];
    }
    
    return httpHeaders;
}

#pragma mark - Response result

- (void)onStart {
    if (self.startHandler) {
        self.startHandler();
    }
}

- (void)onProgress:(NSProgress *)progress {
    if (self.progressHandler) {
        self.progressHandler(progress);
    }
}

- (void)onSuccess:(NSHTTPURLResponse *)response :(id)responseObject {
    self.responseObject = responseObject;
    
    if (self.successHandler) {
        NSError *error;
        
        // check status code
        if (![_NetError statusCodeValidator:response.statusCode]) {
            error = make_error(@"未知错误", response.statusCode);
            
            if (self.failureHandler) {
                self.failureHandler([_NetError visually:error]);
            }
            
            return;
        }
        
        id model = [self modelableFromResponseData:self.responseObject error:&error];
        if (error) {
            if (self.failureHandler) {
                self.failureHandler([NSError jsonDataInvalidError]);
            }
            
            return;
        }
        
        self.successHandler(model);
    }
}

- (void)onFailure:(NSHTTPURLResponse *)response :(NSError *)error {
    LOG(@"Request %@ failed, status code = %ld",
           classnameof_instance(self), (long)response.statusCode);
    
    if (self.failureHandler) {
        self.failureHandler([_NetError visually:error]);
    }
    
    if (self.failureWithReconnectOrNotHandler) {
        BOOL reconnect = NO;
        self.failureWithReconnectOrNotHandler([_NetError visually:error], &reconnect);
        
        if (reconnect) {
            [self start];
        }
    }
}

#pragma mark - Public

- (void)start {
    [[_Network sharedInstance].client addRequest:self];
}

- (BOOL)isExecuting {
    return self.sessionTask.state == NSURLSessionTaskStateRunning;
}

- (void)cancel {
    if (self.isExecuting) {
        [[_Network sharedInstance].client cancelRequest:self];
    }
}

#pragma mark - Property

- (void)setRequestData:(_Model<_NetModelProtocol> *)requestData {
    _requestData = requestData;
}

@end

#import "_pragma_pop.h"
