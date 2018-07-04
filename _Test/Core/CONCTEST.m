//
//  CONCURRENCY.m
//  log_test_with_framework
//
//  Created by 7 on 06/09/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import "_Macro.h"
#import "_Thread.h"
#import "_Group.h"
#import "_Queue.h"
#import "CONCTEST.h"

// MARK:

typedef enum : NSUInteger {
    CONCTESTTypeSerial = 1,
    CONCTESTTypeConcurrent = 2,
} CONCTESTType;



// MARK:

@interface CONCTEST ()

@property (nonatomic, assign) CONCTESTType type;

@property (nonatomic, strong) _Group *group;
@property (nonatomic, strong) _Queue *queue;

//@property (nonatomic, strong) dispatch_queue_t procQueue; // 上面group，queue为实际测试用队列，这个是过程控制队列
@property (nonatomic, strong) NSMutableArray<void (^)()> *handlers;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *handlerExecuteTimes;

@end

@implementation CONCTEST

// MARK: Private section

- (void)reinit {
    self.group = [_Group new];
    self.handlers = [@[] mutableCopy];
    self.handlerExecuteTimes = [@[] mutableCopy];
//    self.procQueue = _DispatchQueueGetForQOS(NSQualityOfServiceUtility);
}

// MARK: Public section

+ (instancetype)concurrentInstance {
    CONCTEST *test = [[CONCTEST alloc] init];
    
    [test reinit];
    
    test.type = CONCTESTTypeConcurrent;
    test.queue = [[_Queue alloc] initConcurrent];
    return test;
}

+ (instancetype)serialInstance {
    CONCTEST *test = [CONCTEST new];
    
    [test reinit];
    
    test.type = CONCTESTTypeSerial;
    test.queue = [[_Queue alloc] initSerial];
    return test;
}

- (CONCTEST *)enqueue:(void (^)())handler times:(int)count {
    
    if (!handler ||
        count < 1) {
        return self;
    }
    
    [self.handlers addObject:handler];
    [self.handlerExecuteTimes addObject:@(count)];
    
    return self;
}

- (void)start {
    void (^testStartHandler)() = ^{
        TLOG(@"------------ CONCTEST START ------------");
    };
    void (^testEndHandler)() = ^{
        TLOG(@"------------ CONCTEST  END  ------------");
    };
    
    if (self.type == CONCTESTTypeSerial) {
        [self.group enter];
        
        [self.queue execute:testStartHandler];
        
        for (int i = 0; i < self.handlers.count; i ++) {
            void (^ handler)() = self.handlers[i];
            __block int time = [self.handlerExecuteTimes[i] intValue];
            
            [self.queue execute:^{
                for (;time > 0; time --) {
                    handler();
                }
            }];
        }
        
        [self.queue execute:testEndHandler];
        
        [self.queue execute:^{
            [self.group leave];
        }];
        
        [self.group wait];
    }
    
    else if (self.type == CONCTESTTypeConcurrent) {
        testStartHandler();
        
        for (int i = 0; i < self.handlers.count; i ++) {
            
            void (^ handler)() = self.handlers[i];
            __block int time = [self.handlerExecuteTimes[i] intValue];
            
            [self.group enter];
            
            [self.queue execute:^{
                
                for (;time > 0; time --) {
                    handler();
                }
                
                [self.group leave];
                
            }];
            
        }
        
        [self.group wait];

        testEndHandler();
    }
}

@end

@implementation CONCTEST ( Extension )

+ (void)detachNewThreadBlock:(void (^)())handler {
    [NSThread detachNewThreadBlock:^{
        if (handler) handler();
    }];
}

@end
