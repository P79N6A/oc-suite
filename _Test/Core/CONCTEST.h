//
//  CONCURRENCY.h
//  log_test_with_framework
//
//  Created by 7 on 06/09/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import "_Foundation.h"

#import "_Queue.h"
#import "_Semaphore.h"
#import "_Group.h"
#import "_Timer.h"
#import "_DispatchQueuePool.h"

/**
 *  http://geek.csdn.net/news/detail/69122
 *  @Warning 请不要使用new, alloc, init初始化方法
 */
@interface CONCTEST : NSObject

/**
 并发队列测试
 */
+ (instancetype)serialInstance;

/**
 串行队列测试
 */
+ (instancetype)concurrentInstance;

/**
 加入测试包
 
 @brief 为保证并发测试的可用性，请保证handler中的实现为同步过程（非异步）
 */
- (CONCTEST *)enqueue:(void (^)())handler times:(int)count;

/**
 执行并发测试
 */
- (void)start;

@end

@interface CONCTEST ( Extension )

/**
 开启新的线程，执行handler
 */
+ (void)detachNewThreadBlock:(void (^)())handler;

@end
