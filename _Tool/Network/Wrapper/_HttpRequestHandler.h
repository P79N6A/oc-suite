//
//  _HttpRequestHandler.h
//  AEAssistant_Network
//
//  Created by Altair on 7/25/16.
//  Copyright © 2016 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_HttpRequestWrapper.h"
#import "_HttpRequestConfiguration.h"

extern NSString *const kHandledServerResponsedLogoutNotification;

@interface _HttpRequestHandler : NSObject

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *restfulParam;

@property (nonatomic, strong) NSDictionary *originalParam;

@property (nonatomic, copy) NSString *urlAliasName;

@property (nonatomic, readonly) NSTimeInterval requestDurationTime;

@property (nonatomic, strong) _HttpRequestConfiguration *requestConfiguration;

+ (void)setCommonRequestConfiguration:(_HttpRequestConfiguration *)config;

+ (instancetype)clientWithUrlString:(NSString *)url;

- (instancetype)initWithUrlString:(NSString*)url;

+ (instancetype)clientWithUrlAliasName:(NSString *)name;

- (instancetype)initWithUrlAliasName:(NSString *)name;

- (void)startHttpRequestWithSuccess:(void (^)(_HttpRequestHandler *handler, NSDictionary *responseData))success
                            failure:(void (^)(_HttpRequestHandler *handler, NSError *error))failure;

- (void)startHttpRequestWithParameter:(NSDictionary *)param
                              success:(void (^)(_HttpRequestHandler *handler, NSDictionary *responseData))success
                              failure:(void (^)(_HttpRequestHandler *handler, NSError *error))failure;

- (void)startHttpRequestWithRestParameter:(NSDictionary *)rParam
                        originalParameter:(NSDictionary *)oParam
                                  success:(void (^)(_HttpRequestHandler *handler, NSDictionary *responseData))success
                                  failure:(void (^)(_HttpRequestHandler *handler, NSError *error))failure;

- (void)uploadFileWithConstructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))bodyData
                                       progress:(void (^) (NSProgress *progress))progressBlock
                                        success:(void (^)(_HttpRequestHandler *handler, NSDictionary *responseData))success
                                        failure:(void (^)(_HttpRequestHandler *handler, NSError *error))failure;

- (void)downloadFileToDestination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                         progress:(void (^) (NSProgress *progress))progress
                          success:(void (^)(_HttpRequestHandler *handler, NSURL *filePath))success
                          failure:(void (^)(_HttpRequestHandler *handler, NSError *error))failure;

- (void)cancelRequest;

@end
