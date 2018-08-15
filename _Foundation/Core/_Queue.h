
#import "_Precompile.h"
#import "_Property.h"
#import "_Singleton.h"
#import "_Macros.h"

#ifndef main_queue
#define main_queue [_Queue  main]
#endif

#ifndef global_queue
#define global_queue [_Queue global]
#endif

@class _Group;

@interface _Queue : NSObject

@singleton( _Queue )

@prop_readonly( dispatch_queue_t,    serial );
@prop_readonly( dispatch_queue_t,    concurrent );

+ (_Queue *)main;
+ (_Queue *)global;
+ (_Queue *)highPriorityGlobal;
+ (_Queue *)lowPriorityGlobal;
+ (_Queue *)backgroundPriorityGlobal;

#pragma mark - 便利的构造方法
+ (void)executeInMain:(dispatch_block_t)block;
+ (void)executeInGlobal:(dispatch_block_t)block;
+ (void)executeInHighPriorityGlobal:(dispatch_block_t)block;
+ (void)executeInLowPriorityGlobal:(dispatch_block_t)block;
+ (void)executeInBackgroundPriorityGlobal:(dispatch_block_t)block;
+ (void)executeInMain:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;
+ (void)executeInGlobal:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;
+ (void)executeInHighPriorityGlobal:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;
+ (void)executeInLowPriorityGlobal:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;
+ (void)executeInBackgroundPriorityGlobal:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;

#pragma mark - 用法
- (void)execute:(dispatch_block_t)block;
- (void)execute:(dispatch_block_t)block completion:(dispatch_block_t)completionHandler;
- (void)execute:(dispatch_block_t)block afterDelay:(int64_t)delta;
- (void)execute:(dispatch_block_t)block afterDelaySecs:(float)delta;
- (void)waitExecute:(dispatch_block_t)block;
- (void)waitExecute:(void (^)(size_t))block iterationCount:(size_t)count;
- (void)barrierExecute:(dispatch_block_t)block;
- (void)waitBarrierExecute:(dispatch_block_t)block;
- (void)suspend;
- (void)resume;

#pragma mark - 与_Group相关

- (void)execute:(dispatch_block_t)block inGroup:(_Group *)group;
- (void)notify:(dispatch_block_t)block inGroup:(_Group *)group;

@end
