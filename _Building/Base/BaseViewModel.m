//
//  BaseViewModel.m
// fallen.ink
//
//  Created by 李杰 on 6/6/15.
//
//

#import "BaseViewModel.h"

@implementation BaseViewModel

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        [self recover];
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self recover];
    }
    
    return self;
}

+ (instancetype)instance {
    BaseViewModel *vm = [[self alloc] init];
    
    [vm recover];
    
    return vm;
}

- (void)recover {
    
}

- (void)prepare:(id)data {
    
}

+ (void)asynchronously:(ObjectBlock)createCompletion {
    BaseViewModel *vm = [[self alloc] init];
    
    [global_queue execute:^{
        [vm recover];
    } completion:^{
        if (createCompletion) {
            createCompletion(vm);
        }
    }];
}

//+ (void)asynchronouslyWithTuple:(RACTuple *)tuples creation:(ObjectBlock)creationHandler {
//    // do nothing
//}
//
//+ (void)asynchronouslyWithTuple:(RACTuple *)tuples
//                       complete:(ObjectBlock)completeHandler
//                          error:(ErrorBlock)errorHandler {
//    // do nothing
//}

+ (void)asynchronouslyComplete:(ObjectBlock)completeHandler error:(ErrorBlock)errorHandler {
    // Do nothing...
}
//
//+ (RACSignal *)asynchronouslyWithTuple:(RACTuple *)tuples {
//    return nil;
//}
//
//+ (RACSignal *)asynchronoursly {
//    return nil;
//}


@end
