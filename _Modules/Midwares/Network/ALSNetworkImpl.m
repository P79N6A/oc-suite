//
//  AERequestMediator.m
//  beyondsports
//
//  Created by HG on 14/11/2017.
//  Copyright © 2017 HG. All rights reserved.
//

#import "ALSNetworkImpl.h"
#import "_MidwarePrecompile.h"
#import "ALSErrorImpl.h"

@implementation ALSNetworkImpl
@synthesize activeServer;
@synthesize dataField;
@synthesize errorCodeField;
@synthesize errorMessageField;
@synthesize extraField;
@synthesize onBeforeHandler;
@synthesize onAfterHandler;
@synthesize onParameterFilter;
@synthesize serialization;

// -------------------------------
// MARK: - 接口预注册
// -------------------------------

- (void)apiWith:(NSString *)identifier prot:(NSString *)prot method:(NSString *)method domain:(NSString *)domain path:(NSString *)path {
    NSAssert(identifier, @"'method' shouldn't be nil.'");
    NSAssert(prot, @"'prot' shouldn't be nil.'");
    NSAssert(domain, @"'domain' shouldn't be nil.'");
    NSAssert(path, @"'path' shouldn't be nil.'");
    
#if __has_AEDataKit
    AEDKHttpServiceConfiguration *cfg = [AEDKHttpServiceConfiguration defaultConfiguration];
    cfg.mimeType = AEDKHttpServiceMimeTypeText;
    cfg.retryCount = 1;
    cfg.method = method;
    
    AEDKService *s = [[AEDKService alloc] initWithName:identifier protocol:prot domain:domain path:path serviceConfiguration:cfg];
    [[AEDKServer server] registerService:s];
#endif
}

- (void)apiUploadWith:(NSString *)identifier prot:(NSString *)prot method:(NSString *)method domain:(NSString *)domain path:(NSString *)path filepath:(NSString *)filepath {
    NSAssert(identifier, @"'method' shouldn't be nil.'");
    NSAssert(prot, @"'prot' shouldn't be nil.'");
    NSAssert(domain, @"'domain' shouldn't be nil.'");
    NSAssert(filepath, @"'filepath' shouldn't be nil.'");
    NSAssert(path, @"'path' shouldn't be nil.'");
    
#if __has_AEDataKit
    AEDKHttpServiceConfiguration *cfg = [AEDKHttpServiceConfiguration defaultConfiguration];
    cfg.mimeType = AEDKHttpServiceMimeTypeText;
    cfg.retryCount = 1;
    cfg.method = method;
    
    AEDKHttpUploadDownloadConfiguration *uploadCfg = [[AEDKHttpUploadDownloadConfiguration alloc] initWithType:AEDKHttpFileUpload accociatedFilePath:filepath];
    cfg.uploadDownloadConfig = uploadCfg;
    
    AEDKService *s = [[AEDKService alloc] initWithName:identifier protocol:prot domain:domain path:path serviceConfiguration:cfg];
    [[AEDKServer server] registerService:s];
#endif
}

- (void)apiDownloadWith:(NSString *)identifier prot:(NSString *)prot method:(NSString *)method domain:(NSString *)domain path:(NSString *)path filepath:(NSString *)filepath {
    NSAssert(identifier, @"'method' shouldn't be nil.'");
    NSAssert(prot, @"'prot' shouldn't be nil.'");
    NSAssert(domain, @"'domain' shouldn't be nil.'");
    NSAssert(filepath, @"'filepath' shouldn't be nil.'");
    
#if __has_AEDataKit
    AEDKHttpServiceConfiguration *cfg = [AEDKHttpServiceConfiguration defaultConfiguration];
    cfg.mimeType = AEDKHttpServiceMimeTypeText;
    cfg.retryCount = 1;
    cfg.method = method;
    
    AEDKHttpUploadDownloadConfiguration *downloadCfg = [[AEDKHttpUploadDownloadConfiguration alloc]initWithType:AEDKHttpFileDownload accociatedFilePath:filepath];
    cfg.uploadDownloadConfig = downloadCfg;
    
    AEDKService *s = [[AEDKService alloc] initWithName:identifier protocol:prot domain:domain path:path serviceConfiguration:cfg];
    [[AEDKServer server] registerService:s];
#endif
}

// -------------------------------
// MARK: - 普通接口 1
// -------------------------------

- (void)requestWith:(NSString *)identifier
         parameters:(NSDictionary *)param
           finished:(_RequestFinishedBlock)finishedHandler {
    [self requestWith:identifier
           parameters:param
               before:nil
                after:nil
             finished:finishedHandler];
}

- (void)requestWith:(NSString *)identifier
         parameters:(NSDictionary *)param
             before:(_RequestBeforeBlock)beforeHandler
              after:(_RequestAfterBlock)afterHandler
           finished:(_RequestFinishedBlock)finishedHandler {

    if (self.onParameterFilter) {
        param = self.onParameterFilter(param);
    }
    
#if __has_AEDataKit
    AEDKProcess *s = [[AEDKServer server] requestServiceWithName:identifier];
    s.configuration.requestParameter = param;
    s.configuration.BeforeProcess = ^(AEDKProcess * _Nonnull process) {
        // 先做局部处理
        if (beforeHandler) beforeHandler();
        
        // 再做全局处理
        if (self.onBeforeHandler) self.onBeforeHandler(process);
    };
    s.configuration.Processing = ^(int64_t totalAmount, int64_t currentAmount, NSURLRequest * _Nonnull currentRequest) {
        
    };
    s.configuration.AfterProcess = ^id _Nonnull(AEDKProcess *currentProcess, NSError *error, id __nullable responseData) {
        
        if (afterHandler) return afterHandler(error, responseData);
        
        else return responseData;
    };
    s.configuration.ProcessCompleted = ^(AEDKProcess * _Nonnull currentProcess, NSError * _Nonnull error, id  _Nullable responseData) {
        
        if (finishedHandler) finishedHandler(error, responseData, nil);
        
    };
    [s start];
#endif
}

// -------------------------------
// MARK: - 普通接口 2
// -------------------------------

- (void)requestWith:(NSString *)identifier
      responseClass:(Class)cls
         parameters:(NSDictionary *)param
           finished:(_RequestFinishedBlock)finishedHandler {
    [self requestWith:identifier
        responseClass:cls
           parameters:param
               before:nil
                after:nil
             finished:finishedHandler];
}

- (void)requestWith:(NSString *)identifier
      responseClass:(Class)cls
         parameters:(NSDictionary *)param
             before:(_RequestBeforeBlock)beforeHandler
              after:(_RequestAfterBlock)afterHandler
           finished:(_RequestFinishedBlock)finishedHandler {
    NSAssert(self.serialization, @"'serialization' shouldn't be nil.'");
    NSAssert(self.dataField, @"'dataField' shouldn't be nil.'");
    NSAssert(self.errorCodeField, @"'errorCodeField' shouldn't be nil.'");
    NSAssert(self.errorMessageField, @"'errorMessageField' shouldn't be nil.'");
    
    if (self.onParameterFilter) {
        param = self.onParameterFilter(param);
    }
    
#if __has_AEDataKit
    AEDKProcess *s = [[AEDKServer server] requestServiceWithName:identifier];
    s.configuration.requestParameter = param;
    s.configuration.BeforeProcess = ^(AEDKProcess * _Nonnull process) {
        // 先做局部处理
        if (beforeHandler) beforeHandler();
        
        // 再做全局处理
        if (self.onBeforeHandler) self.onBeforeHandler(process);
    };
    s.configuration.Processing = ^(int64_t totalAmount, int64_t currentAmount, NSURLRequest * _Nonnull currentRequest) {
        
    };
    s.configuration.AfterProcess = ^id _Nonnull(AEDKProcess *currentProcess, NSError *error, id __nullable responseData) {
        
        if (afterHandler) return afterHandler(error, responseData);
        
        else return responseData;
    };
    s.configuration.ProcessCompleted = ^(AEDKProcess * _Nonnull currentProcess, NSError * _Nonnull error, id  _Nullable responseData) {
        if (!responseData) {
            finishedHandler(error, responseData, nil);
            
            return;
        }
        
        NSDictionary *data = responseData[self.dataField];
        id model = [self.serialization modelWithJSON:data class:cls];
        
        NSInteger code = [responseData[self.errorCodeField] integerValue];
        NSString *message = responseData[self.errorMessageField];
        id extra = nil;
        
        if (self.extraField) {
            extra = responseData[self.extraField];
        }
        
        if (code == 0 && !model) { // 如果没有业务错误的话
            
            NSError *parseError = [NSError withDomain:NSStringFromClass(self.class) code:-1111 message:@"model解析错误"];
            
            finishedHandler(parseError, model, nil);
            
            return;
        } else if (code == 0 && model) {
            if (finishedHandler) finishedHandler(nil, model, extra);
        } else {
            // 潜在业务错误
            message = !message ? @"未知错误" : message;
            
            NSError *businessError = [NSError withDomain:NSStringFromClass(self.class) code:code message:message];
            
            if (finishedHandler) finishedHandler(businessError, nil, nil);
        }
    };
    [s start];
#endif
}

// -------------------------------
// MARK: - 上传、下载接口
// -------------------------------

- (void)downloadWith:(NSString *)identifier
             current:(_RequestCurrentBlock)currentHandler
            finished:(_RequestFinishedBlock)finishedHandler {
    
}


- (void)uploadWith:(NSString *)identifier
           current:(_RequestCurrentBlock)currentHandler
          finished:(_RequestFinishedBlock)finishedHandler {
#if __has_AEDataKit
    AEDKProcess *s = [[AEDKServer server] requestServiceWithName:identifier];
    s.configuration.Processing = ^(int64_t totalAmount, int64_t currentAmount, NSURLRequest * _Nonnull currentRequest) {
        if (currentHandler) currentHandler(totalAmount, currentAmount);
    };
    s.configuration.ProcessCompleted = ^(AEDKProcess * _Nonnull currentProcess, NSError * _Nonnull error, id  _Nullable responseData) {
        
        if (finishedHandler) finishedHandler(error, responseData, nil);
        
    };
    [s start];
#endif
}

@end
