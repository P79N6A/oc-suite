
#import "_Thread.h"
#import "_pragma_push.h"

// ----------------------------------
// MARK: Source code
// ----------------------------------

@implementation NSThread ( Extension )

+ (BOOL)isMainThread {
    return [[NSThread currentThread] isMainThread];
}

+ (void)performBlockOnMainThread:(void (^)(void))block {
    [[NSThread mainThread] _performBlock:block];
}

+ (void)performBlockInBackground:(void (^)(void))block {
    [NSThread performSelectorInBackground:@selector(_runBlock:)
                               withObject:[block copy]];
}

+ (void)_runBlock:(void (^)(void))block {
    block();
}

- (void)_performBlock:(void (^)(void))block {
    
    if ([[NSThread currentThread] isEqual:self])
        block();
    else
        [self performBlock:block waitUntilDone:NO];
}
- (void)performBlock:(void (^)(void))block waitUntilDone:(BOOL)wait {
    
    [NSThread performSelector:@selector(_runBlock:)
                     onThread:self
                   withObject:[block copy]
                waitUntilDone:wait];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    
    [self performSelector:@selector(_performBlock:)
               withObject:[block copy]
               afterDelay:delay];
}

+ (void)_invokeBlock:(void (^)(void))aBlock {
    if (aBlock) {
        aBlock();
    }
}

+ (void)detachNewThreadBlock:(void (^)(void))aBlock {
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

#import "_pragma_pop.h"
