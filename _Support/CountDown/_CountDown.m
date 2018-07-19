
#import "_CountDown.h"

@interface _CountDown ()

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) void (^ currentBlock)(NSTimeInterval);

@property (nonatomic, strong) void (^ completionBlock)();

@end

@implementation _CountDown
@synthesize leftTime = _leftTime;

// ----------------------------------
// MARK: - Public methods
// ----------------------------------

- (instancetype)initWithInterval:(NSTimeInterval)timeLeft {
    self = [super init];
    if (self) {
        _leftTime = timeLeft;
    }
    return self;
}

- (void)setLeftTime:(NSTimeInterval)leftTime {
    [self stop];
    
    _leftTime = leftTime;
}

- (void)start:(void (^)(NSTimeInterval))currentBlock {
    self.currentBlock = currentBlock;
    [self stop];
    
    [self startCountDownTimer];
}

- (void)start:(void (^)(NSTimeInterval))currentBlock completion:(void (^)())completion {
    self.currentBlock = currentBlock;
    self.completionBlock = completion;
    
    [self stop];
    
    [self startCountDownTimer];
}

- (void)stop {
    if (self.timer) {
        if (!dispatch_source_testcancel(self.timer)) {
            //尚未取消，先关闭定时器
            dispatch_source_cancel(self.timer);
        }
        self.timer = nil;
    }
}

// ----------------------------------
// MARK: - Private methods
// ----------------------------------

- (void)startCountDownTimer {
    __block NSTimeInterval time = self.leftTime;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    __weak _CountDown *weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        time --;
        if (time <= 0) {
            [weakSelf stop];
            
            if (weakSelf.completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.completionBlock();
                    weakSelf.completionBlock = nil;
                });
                weakSelf.currentBlock = nil;
            }
        }
        _leftTime = time;
        if (weakSelf.currentBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.currentBlock(time);
            });
        }
    });
    dispatch_resume(self.timer);
}


@end
