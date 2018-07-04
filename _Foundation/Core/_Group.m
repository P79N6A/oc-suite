#import "_Group.h"

@interface _Group ()

@property (strong, nonatomic, readwrite) dispatch_group_t dispatchGroup;

@end

@implementation _Group

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
