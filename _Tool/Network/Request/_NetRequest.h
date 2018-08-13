//
//  _net_request.h
//  component
//
//  Created by fallen.ink on 4/22/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_model.h"
#import "_net_request_protocol.h"

#pragma mark - typedef

@protocol AFMultipartFormData;

/**
 *  构建数据
 *
 *  @param formData ...
 */
typedef void (^ NetConstructingBodyBlock)(id<AFMultipartFormData> formData);

typedef void(^ NetRequestStartBlock)();
typedef void(^ NetRequestSuccessBlock)(id obj);
typedef void(^ NetRequestFailedBlock)(NSError *error);
typedef void(^ NetRequestFailureWithReconnectOrNotBlock)(NSError *error, BOOL *reconnect);
typedef void(^ NetRequestProgressBlock)(NSProgress *progress);

#pragma mark - _NetRequest

@interface _NetRequest : NSObject <_NetModelProtocol>

// ----------------------------------
// User section
// ----------------------------------

@property (nonatomic, strong) _Model<_NetModelProtocol> *requestData;
@property (nonatomic, strong) _Model *responseData;

@property (nonatomic, strong) NSDictionary *HTTPHeader; // Appending http headers

/**
 *  Blocks
 */
@property (nonatomic, strong) NetConstructingBodyBlock constructingBodyBlock;

@property (nonatomic, strong) NetRequestStartBlock startHandler;
@property (nonatomic, strong) NetRequestSuccessBlock successHandler;
@property (nonatomic, strong) NetRequestFailedBlock failureHandler;
@property (nonatomic, strong) NetRequestProgressBlock progressHandler;

@property (nonatomic, strong) NetRequestFailureWithReconnectOrNotBlock failureWithReconnectOrNotHandler;

/**
 *  method
 */
- (void)start;

- (void)cancel;

- (BOOL)isExecuting;

// ----------------------------------
// 高级用法，😄
// ----------------------------------

/**
 *  请求 lifecycle
 */
@property (nonatomic, strong, readonly) NSMapTable *requestAccessories;

/**
 *  是否有效，设置的时候，不做任何操作，只用于client判断
 */
@property (nonatomic, assign) BOOL valid;

@end

/**
 *  便于好用，则只提供工厂方法
 */

@interface _NetUploadRequest : _NetRequest // 上传和下载，会占用独立的operation队列

@end

@interface _NetDownloadRequest : _NetRequest

@end

#pragma mark - 组合处理的请求：串联、并联

// YTKBatchRequest
// YTKChainRequest

#pragma mark -

@protocol NetRequestDelegate <NSObject>

@optional

- (void)requestFinished:(_NetRequest *)request;
- (void)requestFailed:(_NetRequest *)request;
- (void)clearRequest;

@end
