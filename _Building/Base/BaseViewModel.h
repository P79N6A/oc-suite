//
//  BaseViewModel.h
// fallen.ink
//
//  Created by 李杰 on 6/6/15.
//
//

//#import "_vendor_reactivecocoa.h"
#import "_Foundation.h"

//@class RACTuple;
//@class RACSignal;

/**
 *  fallenink:
 
 *  职责：
 *  1. 网络请求
 *  2. 数据服务（包括dataSource、dataSource的处理、变换）
 *  3. 数据服务，也包括，数据绑定）
 */

@interface BaseViewModel : NSObject

- (instancetype)initWithParams:(NSDictionary *)params;

/**
 *  Initialize self with cache.
 
 *  No limit for cache strategy.
 */
- (void)recover; // Load data from cache

- (void)prepare:(id)data;

/**
 *  alloc\init\recover
 */
+ (instancetype)instance;

#pragma mark - Asynchronously

/**
 *  Create vm, recover it, call block createCompletion.
 
 *  createCompletion: if nil, then error
 */
+ (void)asynchronously:(ObjectBlock)createCompletion;

///**
// *  creationHandler: if nil, then error
// */
//+ (void)asynchronouslyWithTuple:(RACTuple *)tuples
//                       creation:(ObjectBlock)creationHandler;
//
//+ (void)asynchronouslyWithTuple:(RACTuple *)tuples
//                       complete:(ObjectBlock)completeHandler
//                          error:(ErrorBlock)errorHandler;

/**
 *  Useful???
 */
+ (void)asynchronouslyComplete:(ObjectBlock)completeHandler
                         error:(ErrorBlock)errorHandler;

#pragma mark - RACSignal

///**
// *  With RacSignal s
// */
//+ (RACSignal *)asynchronoursly;
//
//+ (RACSignal *)asynchronouslyWithTuple:(RACTuple *)tuples;

@end
