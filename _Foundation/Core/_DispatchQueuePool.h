
#import <Foundation/Foundation.h>

/**
 用法
 
 // Get a serial queue from global queue pool
 dispatch_queue_t queue = _DispatchQueueGetForQOS(NSQualityOfServiceUtility);
 
 // Create a serial queue pool
 _DispatchQueuePool *pool = [[_DispatchQueuePool alloc] initWithName:@"file.read" queueCount:5 qos:NSQualityOfServiceBackground];
 dispatch_queue_t queue = [pool queue];
 */

NS_ASSUME_NONNULL_BEGIN

/**
 A dispatch queue pool holds multiple serial queues.
 Use this class to control queue's thread count (instead of concurrent queue).
 */
@interface _DispatchQueuePool : NSObject
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 Creates and returns a dispatch queue pool.
 @param name       The name of the pool.
 @param queueCount Maxmium queue count, should in range (1, 32).
 @param qos        Queue quality of service (QOS).
 @return A new pool, or nil if an error occurs.
 */
- (instancetype)initWithName:(nullable NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;

/// Pool's name.
@property (nullable, nonatomic, readonly) NSString *name;

/// Get a serial queue from pool.
- (dispatch_queue_t)queue;

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;

@end

/// Get a serial queue from global queue pool with a specified qos.
extern dispatch_queue_t _DispatchQueueGetForQOS(NSQualityOfService qos);

NS_ASSUME_NONNULL_END
