
#import "_Queue.h"
#import "_Group.h"

static _Queue *mainQueue;
static _Queue *globalQueue;
static _Queue *highPriorityGlobalQueue;
static _Queue *lowPriorityGlobalQueue;
static _Queue *backgroundPriorityGlobalQueue;

@interface _Queue ()

@property (strong, readwrite, nonatomic) dispatch_queue_t dispatchQueue;

//@property (strong, readonly, nonatomic) dispatch_queue_t dispatchQueue;
@end

@implementation _Queue

@def_singleton( _Queue )

@def_prop_strong( dispatch_queue_t,    serial );
@def_prop_strong( dispatch_queue_t,    concurrent );

+ (_Queue *)main {
    return mainQueue;
}

+ (_Queue *)global {
    return globalQueue;
}

+ (_Queue *)highPriorityGlobal {
    return highPriorityGlobalQueue;
}

+ (_Queue *)lowPriorityGlobal {
    return lowPriorityGlobalQueue;
}

+ (_Queue *)backgroundPriorityGlobal {
    return backgroundPriorityGlobalQueue;
}

+ (void)initialize {
    /**
     Initializes the class before it receives its first message.
     
     1. The runtime sends the initialize message to classes in a
     thread-safe manner.
     
     2. initialize is invoked only once per class. If you want to
     perform independent initialization for the class and for
     categories of the class, you should implement load methods.
     */
    if (self == [_Queue self])  {
        mainQueue = [[_Queue alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        globalQueue = [[_Queue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        highPriorityGlobalQueue = [[_Queue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
        lowPriorityGlobalQueue = [[_Queue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
        backgroundPriorityGlobalQueue = [[_Queue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    }
}

- (instancetype)initWithDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (self = [super init]) {
        self.dispatchQueue = dispatchQueue;
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _serial = dispatch_queue_create( "com.suite.serial", DISPATCH_QUEUE_SERIAL );
        _concurrent = dispatch_queue_create( "com.suite.concurrent", DISPATCH_QUEUE_CONCURRENT );
    }
    
    return self;
}

- (void)dealloc {
    _serial = nil;
    _concurrent = nil;
}

- (void)execute:(dispatch_block_t)block {
    NSParameterAssert(block);
    
    dispatch_async(self.dispatchQueue, block);
}

- (void)execute:(dispatch_block_t)handler completion:(dispatch_block_t)completion {
    NSParameterAssert(handler);
    NSParameterAssert(completion);
    
    dispatch_async(self.dispatchQueue, ^{
        @autoreleasepool {
            handler();
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        }
    });
}

- (void)execute:(dispatch_block_t)block afterDelay:(int64_t)delta {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), self.dispatchQueue, block);
}

- (void)execute:(dispatch_block_t)block afterDelaySecs:(float)delta {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta * NSEC_PER_SEC), self.dispatchQueue, block);
}

- (void)waitExecute:(dispatch_block_t)block {
    /*
     As an optimization, this function invokes the block on
     the current thread when possible.
     
     作为一个建议,这个方法尽量在当前线程池中调用.
     */
    
    NSParameterAssert(block);
    dispatch_sync(self.dispatchQueue, block);
}

- (void)waitExecute:(void (^)(size_t))block iterationCount:(size_t)count {
    dispatch_apply(count, self.dispatchQueue, block);
}

- (void)barrierExecute:(dispatch_block_t)block {
    /*
     The queue you specify should be a concurrent queue that you
     create yourself using the dispatch_queue_create function.
     If the queue you pass to this function is a serial queue or
     one of the global concurrent queues, this function behaves
     like the dispatch_async function.
     
     使用的线程池应该是你自己创建的并发线程池.如果你传进来的参数为串行线程池
     或者是系统的并发线程池中的某一个,这个方法就会被当做一个普通的async操作
     */
    
    NSParameterAssert(block);
    dispatch_barrier_async(self.dispatchQueue, block);
}

- (void)waitBarrierExecute:(dispatch_block_t)block {
    /*
     The queue you specify should be a concurrent queue that you
     create yourself using the dispatch_queue_create function.
     If the queue you pass to this function is a serial queue or
     one of the global concurrent queues, this function behaves
     like the dispatch_sync function.
     
     使用的线程池应该是你自己创建的并发线程池.如果你传进来的参数为串行线程池
     或者是系统的并发线程池中的某一个,这个方法就会被当做一个普通的sync操作
     
     As an optimization, this function invokes the barrier block
     on the current thread when possible.
     
     作为一个建议,这个方法尽量在当前线程池中调用.
     */
    
    NSParameterAssert(block);
    dispatch_barrier_sync(self.dispatchQueue, block);
}

- (void)suspend {
    dispatch_suspend(self.dispatchQueue);
}

- (void)resume {
    dispatch_resume(self.dispatchQueue);
}

- (void)execute:(dispatch_block_t)block inGroup:(_Group *)group {
    NSParameterAssert(block);
    dispatch_group_async(group.dispatchGroup, self.dispatchQueue, block);
}

- (void)notify:(dispatch_block_t)block inGroup:(_Group *)group {
    NSParameterAssert(block);
    dispatch_group_notify(group.dispatchGroup, self.dispatchQueue, block);
}

#pragma mark - 便利的构造方法

+ (void)executeInMain:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), mainQueue.dispatchQueue, block);
}

+ (void)executeInGlobal:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), globalQueue.dispatchQueue, block);
}

+ (void)executeInHighPriorityGlobal:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), highPriorityGlobalQueue.dispatchQueue, block);
}

+ (void)executeInLowPriorityGlobal:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), lowPriorityGlobalQueue.dispatchQueue, block);
}

+ (void)executeInBackgroundPriorityGlobal:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * sec), backgroundPriorityGlobalQueue.dispatchQueue, block);
}

+ (void)executeInMain:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(mainQueue.dispatchQueue, block);
}

+ (void)executeInGlobal:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(globalQueue.dispatchQueue, block);
}

+ (void)executeInHighPriorityGlobal:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(highPriorityGlobalQueue.dispatchQueue, block);
}

+ (void)executeInLowPriorityGlobal:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(lowPriorityGlobalQueue.dispatchQueue, block);
}

+ (void)executeInBackgroundPriorityGlobal:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(backgroundPriorityGlobalQueue.dispatchQueue, block);
}

@end
