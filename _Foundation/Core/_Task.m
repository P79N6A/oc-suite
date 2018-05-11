
#import "_Task.h"

@implementation _TaskManager

+ (void)sequenceOperations:(NSMutableArray*)arrOperation completion:(void(^)(void))completion {
    if (arrOperation.count) {
        _Task *task = (_Task *)[arrOperation firstObject];
        if ([task isKindOfClass:[_Task class]]) {
            
            task.blockTask(nil,^(id BlockTaskCompletion){
                //this block get called when task completed
                [arrOperation removeObjectAtIndex:0];
                [self sequenceOperations:arrOperation completion:completion];
            });
        }
    } else {
        if (completion) {
            completion();
        }
    }
}

+ (void)parallerOperations:(NSMutableArray *)arrOperation completion:(void(^)(void))completion {
    NSMutableArray *arrTaskRunning = [arrOperation mutableCopy];
    if (arrOperation.count) {
        for (int i = 0; i < arrOperation.count; i++) {
            _Task *task = (_Task *)[arrOperation objectAtIndex:i];
            if ([task isKindOfClass:[_Task class]]) {
                task.blockTask(nil, ^(id BlockTaskCompletion) {
                    if ([arrTaskRunning containsObject:task]) {
                        [arrTaskRunning removeObject:task];
                    }
                    
                    if (arrTaskRunning.count == 0) {
                        if (completion) {
                            completion();
                        }
                    }
                    
                });
            }
        }
    } else {
        if (completion) {
            completion();
        }
    }
}

@end

#pragma mark - 

@implementation _Task

//---create task with its execution block and set completion block
+ (_Task *)taskWithBlock:(BlockTask)blockTask {
    _Task *task= [[_Task alloc] init];
    task.blockTask = blockTask;
    
    return task;
}

@end

