
#import "_Thread.h"

// ----------------------------------
// MARK: Source code
// ----------------------------------

#pragma mark -

@interface GCDGroup ()
@property (strong, readwrite, nonatomic) dispatch_group_t dispatchGroup;
@end

@implementation GCDGroup

- (instancetype)init {
    return [self initWithDispatchGroup:dispatch_group_create()];
}

- (instancetype)initWithDispatchGroup:(dispatch_group_t)dispatchGroup {
    if ((self = [super init]) != nil) {
        self.dispatchGroup = dispatchGroup;
    }
    
    return self;
}

#pragma mark - Public methods.

- (void)enter {
    dispatch_group_enter(self.dispatchGroup);
}

- (void)leave {
    dispatch_group_leave(self.dispatchGroup);
}

- (void)wait {
    dispatch_group_wait(self.dispatchGroup, DISPATCH_TIME_FOREVER);
}

- (BOOL)wait:(double)seconds {
    return dispatch_group_wait(self.dispatchGroup, dispatch_time(DISPATCH_TIME_NOW, (seconds * NSEC_PER_SEC))) == 0;
}

@end

#pragma mark -

@interface GCDSemaphore ()
@property (strong, readwrite, nonatomic) dispatch_semaphore_t dispatchSemaphore;
@end

@implementation GCDSemaphore

#pragma mark Lifecycle.

- (instancetype)init {
    return [self initWithValue:0];
}

- (instancetype)initWithValue:(long)value {
    return [self initWithDispatchSemaphore:dispatch_semaphore_create(value)];
}

- (instancetype)initWithDispatchSemaphore:(dispatch_semaphore_t)dispatchSemaphore {
    if ((self = [super init]) != nil) {
        self.dispatchSemaphore = dispatchSemaphore;
    }
    
    return self;
}

#pragma mark Public methods.

- (BOOL)signal {
    return dispatch_semaphore_signal(self.dispatchSemaphore) != 0;
}

- (void)wait {
    dispatch_semaphore_wait(self.dispatchSemaphore, DISPATCH_TIME_FOREVER);
}

- (BOOL)wait:(double)seconds {
    return dispatch_semaphore_wait(self.dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, (seconds * NSEC_PER_SEC))) == 0;
}

@end


#pragma mark -

static GCDQueue *mainQueue;
static GCDQueue *globalQueue;
static GCDQueue *highPriorityGlobalQueue;
static GCDQueue *lowPriorityGlobalQueue;
static GCDQueue *backgroundPriorityGlobalQueue;

@interface GCDQueue ()

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@end

@implementation GCDQueue

@def_singleton( GCDQueue )

@def_prop_strong( dispatch_queue_t,	serial );
@def_prop_strong( dispatch_queue_t,	concurrent );

+ (void)initialize {
    if (self == [GCDQueue class]) {
        mainQueue = [[GCDQueue alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        globalQueue = [[GCDQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        highPriorityGlobalQueue = [[GCDQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
        lowPriorityGlobalQueue = [[GCDQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
        backgroundPriorityGlobalQueue = [[GCDQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    }
}

- (instancetype)initWithDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if ((self = [super init]) != nil) {
        self.dispatchQueue = dispatchQueue;
    }
    
    return self;
}

- (id)init {
    self = [super init];
    if ( self )
    {
        _serial = dispatch_queue_create( "com.suite.serial", DISPATCH_QUEUE_SERIAL );
        _concurrent = dispatch_queue_create( "com.suite.concurrent", DISPATCH_QUEUE_CONCURRENT );
    }
    
    return self;
}

- (void)dealloc {
    _serial = nil;
    _concurrent = nil;
}

#pragma mark -

+ (GCDQueue *)main {
    return mainQueue;
}

+ (GCDQueue *)global {
    return globalQueue;
}

+ (GCDQueue *)highPriorityGlobal {
    return highPriorityGlobalQueue;
}

+ (GCDQueue *)lowPriorityGlobal {
    return lowPriorityGlobalQueue;
}

+ (GCDQueue *)backgroundPriorityGlobal {
    return backgroundPriorityGlobalQueue;
}

#pragma mark -

- (void)queueBlock:(dispatch_block_t)block {
    dispatch_async(self.dispatchQueue, block);
}

- (void)queueBlock:(dispatch_block_t)block afterDelay:(double)seconds {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (seconds * NSEC_PER_SEC)), self.dispatchQueue, block);
}

- (void)queueAndAwaitBlock:(dispatch_block_t)block {
    dispatch_sync(self.dispatchQueue, block);
}

- (void)queueAndAwaitBlock:(void (^)(size_t))block iterationCount:(size_t)count {
    dispatch_apply(count, self.dispatchQueue, block);
}

- (void)queueBlock:(dispatch_block_t)block inGroup:(GCDGroup *)group {
    dispatch_group_async(group.dispatchGroup, self.dispatchQueue, block);
}

- (void)queueNotifyBlock:(dispatch_block_t)block inGroup:(GCDGroup *)group {
    dispatch_group_notify(group.dispatchGroup, self.dispatchQueue, block);
}

- (void)queueBarrierBlock:(dispatch_block_t)block {
    dispatch_barrier_async(self.dispatchQueue, block);
}

- (void)queueAndAwaitBarrierBlock:(dispatch_block_t)block {
    dispatch_barrier_sync(self.dispatchQueue, block);
}

- (void)queueBlock:(Block)block completion:(Block)completion {
    dispatch_async(self.dispatchQueue, ^{
        @autoreleasepool {
            block();
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        }
    });
}

#pragma mark Misc public methods.

- (void)suspend {
    dispatch_suspend(self.dispatchQueue);
}

- (void)resume {
    dispatch_resume(self.dispatchQueue);
}


@end


///////// MARK: -

@implementation _Thread

+ (BOOL)isMainThread {
    return [[NSThread currentThread] isMainThread];
}

@end

@implementation NSThread (MCSMAdditions)

+ (void)performBlockOnMainThread:(void (^)())block {
    [[NSThread mainThread] _performBlock:block];
}

+ (void)performBlockInBackground:(void (^)())block {
    [NSThread performSelectorInBackground:@selector(_runBlock:)
                               withObject:[block copy]];
}

+ (void)_runBlock:(void (^)())block {
    block();
}


- (void)_performBlock:(void (^)())block {
    
    if ([[NSThread currentThread] isEqual:self])
        block();
    else
        [self performBlock:block waitUntilDone:NO];
}
- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait {
    
    [NSThread performSelector:@selector(_runBlock:)
                     onThread:self
                   withObject:[block copy]
                waitUntilDone:wait];
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay {
    
    [self performSelector:@selector(_performBlock:)
               withObject:[block copy]
               afterDelay:delay];
}

+ (void)_invokeBlock:(void (^)())aBlock {
    if (aBlock) {
        aBlock();
    }
}

+ (void)detachNewThreadBlock:(void (^)())aBlock {
    [self detachNewThreadSelector:@selector(_invokeBlock:) toTarget:[NSThread class] withObject:aBlock];
}

@end

@implementation NSThread (LagDetection)

+ (void)killIfMainThreadIsBlockedForDuration:(NSTimeInterval)duration {
    if ([NSThread currentThread] != [NSThread mainThread]) {
        [NSException raise:@"This method should be called from the main thread" format:@""];
    }
    
    __block BOOL canceled = NO;
    
    CFRunLoopRef mainRunLoop = [[NSRunLoop mainRunLoop] getCFRunLoop];
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL,
                                                                       kCFRunLoopAllActivities,
                                                                       false,
                                                                       LONG_MAX, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
                                                                           canceled = YES;
                                                                           CFRelease(observer);
                                                                       });
    CFRunLoopAddObserver(mainRunLoop, observer, kCFRunLoopDefaultMode);
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (!canceled) {
            [[NSThread mainThread] doesNotRecognizeSelector:@selector(crash)];
        }
    });
}

+ (void)killIfMainThreadIsBlocked {
    [self killIfMainThreadIsBlockedForDuration:1];
}

@end
