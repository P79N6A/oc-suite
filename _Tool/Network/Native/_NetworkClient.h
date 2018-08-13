//
//  _client.h
//  component
//
//  Created by fallen.ink on 4/22/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_net_request.h"

#pragma mark -

@protocol _ClientPostFilter;
@protocol _ClientPreFilter;

@interface _Client : NSObject

// Request manager

- (void)addRequest:(_NetRequest *)request;

- (void)cancelRequest:(_NetRequest *)request;

- (void)cancelAllRequests;

// Filter mechanism

/**
 *  @fallenink
 *
 *  为了不让client耦合具体的设计问题，如token，session等，则由用户去做吧。
 */
- (void)setPostFilter:(id<_ClientPostFilter>)filter; // 暂时统一做，fallenink，先不考虑其他的。

- (void)setPreFilter:(id<_ClientPreFilter>)filter;

@end

#pragma mark - Network post filter

@protocol _ClientPostFilter <NSObject>

/**
 *  应答的后处理
 *
 *  @param responseData 应答body
 *  @param request      请求对象
 *  @param perror       错误指针
 *
 *  @return 处理之后的应答body
 
 *  @desc 如果，有错误，则，该请求被认为是出错，failureHandler呗调用
 */
- (id)postProcess:(id)responseData request:(_NetRequest *)request perror:(NSError **)perror;
   
@end

#pragma mark - Network prefix filter

@protocol _ClientPreFilter <NSObject>

/**
 *  预处理 保证：在请求前，第一次操作request
 *
 *  @param params ...
 *  @param request ...
 *
 *  @return if NO, invalidate current request
 */
- (id)preProcess:(id)params request:(_NetRequest *)request;

@end

