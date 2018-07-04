#import "_Semaphore.h"

@interface _Semaphore ()

@property (strong, readwrite, nonatomic) dispatch_semaphore_t dispatchSemaphore;

@end

@implementation _Semaphore

- (instancetype)init {
    return [self initWithValue:0];
}

- (instancetype)initWithValue:(long)value {
    return [self initWithDispatchSemaphore:dispatch_semaphore_create(value)];
}

- (instancetype)initWithDispatchSemaphore:(dispatch_semaphore_t)dispatchSemaphore {
    if (self = [super init]) {
        self.dispatchSemaphore = dispatchSemaphore;
    }
    
    return self;
}

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
