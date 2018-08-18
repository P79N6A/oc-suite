//
//  _client.m
//  component
//
//  Created by fallen.ink on 4/22/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_client.h"
#import "_network.h"
#import "_net_request.h"
#import "_model.h"
#import "_network_private.h"

#import "AFNetworking.h"
#import "AFHTTPSessionOperation.h"
#import "AFURLSessionOperation.h"

// inspired by [YKNetwork](https://github.com/yuantiku/YTKNetwork/blob/master/BasicGuide.md)

#pragma mark -

@interface _Client ()

@property (nonatomic, weak) _NetConfig *config;

@end

@implementation _Client {
    AFHTTPSessionManager *_manager;
    NSMutableDictionary *_requestsCache;
    
    id<_ClientPostFilter> _postFilter;
    id<_ClientPreFilter> _preFilter;
}

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        [self initDefault];
    }
    
    return self;
}
         
- (void)initDefault {
    _config = [_Network sharedInstance].config;
    
    _manager = [AFHTTPSessionManager manager];
    _manager.operationQueue.maxConcurrentOperationCount = 4;
    _manager.securityPolicy = _config.securityPolicy;
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer.stringEncoding = _config.dataEncoding;
    
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.requestSerializer.stringEncoding = _config.dataEncoding;
    
    _manager.requestSerializer.timeoutInterval = _config.timeoutInterval;
    
    _requestsCache = [NSMutableDictionary dictionary];
}

#pragma mark - Request operation

- (void)addRequest:(_NetRequest *)request {
    NetRequestMethod method = request.requestMethod;
    RequestSerializerType serializerType = request.requestSerializerType;
    NetConstructingBodyBlock constructingBlock = [request constructingBodyBlock];
    NSDictionary *params = [request requestParams];
    
    // params 的前置操作
    params = [self preProcess:params request:request];
    if (!request.valid) return;
    
    // Check if request is valid
    
    LOG(@"apiname = %@, request params = %@", request.requestUrl, params);
    
    /**
     *  配置 AFHTTPSessionManager 序列化器
     */
    if (serializerType == RequestSerializerType_HTTP) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (serializerType == RequestSerializerType_JSON) {
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    _NetConfig *config = [_Network sharedInstance].config;
    
    // Set timeout
    _manager.requestSerializer.timeoutInterval = config.timeoutInterval;
    
    // if api need server username and password
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [_manager.requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                                   password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [_manager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                LOG(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    NSString *url = [config buildRequestUrlWithNetModelProtocol:request.requestData];
    NSURLRequest *customUrlRequest= request.customUrlRequest;
    if (customUrlRequest) {
        LOG(@"custom request = %@", customUrlRequest);
        
        exceptioning(@"not be implemented and tested")
        
        /**
         *  inspired by https://github.com/robertmryan/AFHTTPSessionOperation
         */
        _manager.responseSerializer = [AFImageResponseSerializer serializer];
        NSOperation *operation = [AFHTTPSessionOperation operationWithManager:_manager
                                                                   HTTPMethod:@"GET"
                                                                    URLString:url
                                                                   parameters:nil
                                                               uploadProgress:nil
                                                             downloadProgress:^(NSProgress *downloadProgress) {
//            NSLog(@"%@: %.1f", filename, downloadProgress.fractionCompleted * 100.0);
        } success:^(NSURLSessionDataTask *task, id responseObject) {
//            NSLog(@"%@: %@", filename, NSStringFromCGSize([responseObject size]));
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            NSLog(@"%@: %@", filename, error.localizedDescription);
        }];
        
//        request.requestOperation = operation;
//        operation.responseSerializer = _manager.responseSerializer;
        
        // 这个operationQueue并不是：The operation queue on which request operations are scheduled and run.
        [_manager.operationQueue addOperation:operation];
        
        // Set request operation priority
        switch (request.requestPriority) {
            case NetRequestPriority_High:
                request.operation.queuePriority = NSOperationQueuePriorityHigh;
                break;
            case NetRequestPriority_Low:
                request.operation.queuePriority = NSOperationQueuePriorityLow;
                break;
            case NetRequestPriority_Default:
            default:
                request.operation.queuePriority = NSOperationQueuePriorityNormal;
                break;
        }
    }
    
    else {
        @weakify(self)
        
        if (method == NetRequestMethod_Get) {
            if (NO) {
                // 断点续传
                
                exceptioning(@"Not be implemented")
                
//                NSString *filteredUrl = [YTKNetworkPrivate urlStringWithOriginUrlString:url appendParameters:param];
                
//                NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//                AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:requestUrl
//                                                                                                 targetPath:request.resumableDownloadPath shouldResume:YES];
//                [operation setProgressiveDownloadProgressBlock:request.resumableDownloadProgressBlock];
//                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                    [self handleRequestResult:operation];
//                }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    [self handleRequestResult:operation];
//                }];
//                request.requestOperation = operation;
//                [_manager.operationQueue addOperation:operation];
            }
            
            else {
                NSURLSessionDataTask * task =
                [_manager GET:url
                   parameters:params
                     progress:^(NSProgress * _Nonnull downloadProgress) {
                         @strongify(self)

                         [self onProgress:downloadProgress withRequest:request];
                     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         @strongify(self)
    
                         [self onSuccess:task.response :responseObject withRequest:request];
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         @strongify(self)
                         
                         [self onFail:error withRequest:request];
                     }];
                
                [request setSessionTask:task];
            }
        }
        
        else if (method == NetRequestMethod_Post) {
            if (constructingBlock) {
                NSURLSessionDataTask *task =
                [_manager POST:url
                    parameters:params
     constructingBodyWithBlock:constructingBlock
                      progress:^(NSProgress * _Nonnull uploadProgress) {
                          @strongify(self)
                          
                          [self onProgress:uploadProgress withRequest:request];
                      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          @strongify(self)
                          
                          [self onSuccess:task.response :responseObject withRequest:request];
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          @strongify(self)
                          
                          [self onFail:error withRequest:request];
                      }];
                
                [request setSessionTask:task];
            }
            
            else {
                NSURLSessionDataTask *task =
                [_manager POST:url
                    parameters:params
                      progress:^(NSProgress * _Nonnull uploadProgress) {
                          @strongify(self)
                          
                          [self onProgress:uploadProgress withRequest:request];
                      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          @strongify(self)
                          
                          [self onSuccess:task.response :responseObject withRequest:request];
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          @strongify(self)
                          
                          [self onFail:error withRequest:request];
                      }];
                
                [request setSessionTask:task];
            }
        }
        
        else if (method == NetRequestMethod_Head) {
            NSURLSessionDataTask *task =
            [_manager HEAD:url
                parameters:params
                   success:^(NSURLSessionDataTask * _Nonnull task) {
                       @strongify(self)
                       
                       [self onSuccess:task.response :nil withRequest:request];
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       @strongify(self)
                       
                       [self onFail:error withRequest:request];
                   }];
            
            [request setSessionTask:task];
        }
        
        else if (method == NetRequestMethod_Delete) {
            NSURLSessionDataTask *task =
            [_manager DELETE:url
                  parameters:params
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         @strongify(self)
                         
                         [self onSuccess:task.response :responseObject withRequest:request];
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         @strongify(self)
                         
                         [self onFail:error withRequest:request];
                     }];
            
            [request setSessionTask:task];
        }
        
        else if (method == NetRequestMethod_Put) {
            NSURLSessionDataTask *task =
            [_manager PUT:url
               parameters:params
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      @strongify(self)
                      
                      [self onSuccess:task.response :responseObject withRequest:request];
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      @strongify(self)
                      
                      [self onFail:error withRequest:request];
                  }];
            
            [request setSessionTask:task];
        }
        
        else if (method == NetRequestMethod_Patch) {
            NSURLSessionDataTask *task =
            [_manager PATCH:url
                 parameters:params
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        @strongify(self)
                        
                        [self onSuccess:task.response :responseObject withRequest:request];
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        @strongify(self)
                        
                        [self onFail:error withRequest:request];
                    }];
            
            [request setSessionTask:task];
        }
    }
    
    // Put in cache
    [self cacheRequest:request];
    
    // Notice request start
    [self onStartRequest:request];
}

- (void)cancelRequest:(_NetRequest *)request {
    [request.sessionTask cancel];
    
    [request clear];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsCache copy];
    for (NSString *key in copyRecord) {
        _NetRequest *request = copyRecord[key];
        [request cancel];
    }
}

#pragma mark - Post filter

- (void)setPostFilter:(id<_ClientPostFilter>)filter {
    _postFilter = filter;
}

- (id)postProcess:(id)responseData request:(_NetRequest *)request perror:(NSError **)error {
    if (_postFilter && is_method_implemented(_postFilter, postProcess:request:perror:)) {
        return [_postFilter postProcess:responseData request:request perror:error];
    }
    
    return responseData;
}

- (void)setPreFilter:(id<_ClientPreFilter>)filter {
    _preFilter = filter;
}

- (id)preProcess:(id)params request:(_NetRequest *)request {
    if (_preFilter && is_method_implemented(_preFilter, preProcess:request:)) {
        return [_preFilter preProcess:params request:request];
    }
    
    return params;
}

#pragma mark - Request cache

- (void)cacheRequest:(_NetRequest *)request {
    if (request != nil) {
        NSString *key = [self hashKey:request.sessionTask];
        @synchronized(self) {
            _requestsCache[key] = request;
        }
    }
}

- (void)uncacheRequest:(_NetRequest *)request {
    NSString *key = [self hashKey:request.sessionTask];
    @synchronized(self) {
        [_requestsCache removeObjectForKey:key];
    }
//    LOG(@"Request queue size = %lu", (unsigned long)[_requestsCache count]);
}

#pragma mark - Handle HTTP progress

- (void)onStartRequest:(_NetRequest *)request {
    NSString *key = [self hashKey:request.sessionTask];
    _NetRequest *cachedRequest = _requestsCache[key];
    
    if (cachedRequest == request) {
        [request onStart];
    } else {
        LOG(@"request not match.");
    }
}

- (void)onProgress:(NSProgress *)progress withRequest:(_NetRequest *)request {
    NSString *key = [self hashKey:request.sessionTask];
    _NetRequest *cachedRequest = _requestsCache[key];
    
    if (cachedRequest == request) {
        /**
         *  YTKNetwork库，用下面这个机制，做请求缓存
         */
//        [request requestCompleteFilter];
        
        [request onProgress:progress];
    } else {
        LOG(@"request not match.");
    }
}

- (void)onSuccess:(NSURLResponse *)response :(id)responseData withRequest:(_NetRequest *)request {
    NSError *error = nil;
    NSString *key = [self hashKey:request.sessionTask];
    _NetRequest *cachedRequest = _requestsCache[key];
    
    LOG(@"client http response = %@", responseData);
    
    if (cachedRequest == request) {
        responseData = [self postProcess:responseData request:request perror:&error];
        
        if (error) {
            // 重定向 错误处理
            [self onFail:(NSError *)error withRequest:(_NetRequest *)request];
            
            return;
        }
        
        [request onSuccess:(NSHTTPURLResponse *)response :responseData];
    } else {
        LOG(@"request not match.");
    }
    
    [self uncacheRequest:request];
    [request clear];
}

- (void)onFail:(NSError *)error withRequest:(_NetRequest *)request {
    NSString *key = [self hashKey:request.sessionTask];
    _NetRequest *cachedRequest = _requestsCache[key];
    
    LOG(@"client http response error = %@", error);
    
    if (cachedRequest == request) {
        [request onFailure:(NSHTTPURLResponse *)request.sessionTask.response :error];
    } else {
        LOG(@"request not match.");
    }
    
    [self uncacheRequest:request];
    [request clear];
}

#pragma mark - Tools

/**
 *  Hash 值
 *
 *  NSURLSessionTask *
 */
- (NSString *)hashKey:(id)obj {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[obj hash]];
    return key;
}

@end
