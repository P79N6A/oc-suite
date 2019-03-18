#import "_Pair.h"

@implementation _Pair

@end

@interface _PairManager () {
    int64_t _pointerCache[1024];
    int _pointerCursor;
}

@prop_instance( NSMutableDictionary , objectCache )

@end

@implementation _PairManager

@def_prop_instance( NSMutableDictionary , objectCache )

@def_singleton_autoload( _PairManager )

- (instancetype)init {
    if (self = [super init]) {
        [self initDefaults];
        
        [self initRunloopMonitor];
    }
    
    return self;
}

- (void)initDefaults {
    _pointerCursor = 0;
}

- (void)initRunloopMonitor {
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(),kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        [self checkObjectsLifeCycle];
        
        [self checkPointersLifeCycle];
    });
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
}

// ----------------------------------
// MARK: Pair create
// ----------------------------------

- (Pair)pairWith:(id)a :(id)b :(id)c {
    _Pair *p = [_Pair new];
    
    p.a = a;
    p.b = b;
    p.c = c;
    
    return p;
}

// ----------------------------------
// MARK: Runloop observer
// ----------------------------------

- (void)checkObjectsLifeCycle {
    
}

- (void)checkPointersLifeCycle {
    
}

@end
