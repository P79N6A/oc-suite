
#import "_Chronograph.h"

@interface _Chronograph ()

@property (nonatomic, strong) NSString *elapsedTime;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
    
@end

@implementation _Chronograph {
    NSDate *_startDate;
    NSDate *_pausedDate;

    BOOL _running;

    dispatch_source_t _timer;
    _ChronographTimeBlock _timeBlock;
}

- (id)init {
    if(self = [super init]){
        [self setup];
    }
    return self; 
}

- (void)reset {
    [self setup];
}

- (void)setup {
    _elapsedTime = @"00.00.00.000";
    _pausedDate = nil;
    _running = NO;
    _timeBlock = nil;

    if (_timer != nil) {
        dispatch_source_cancel(_timer);
    }
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    }
    return _dateFormatter;
}

- (void)setElapsedTime:(NSString *)elapsedTime {
    _elapsedTime = elapsedTime;
    if (_timeBlock) _timeBlock(_elapsedTime);
}

- (void)start:(_ChronographTimeBlock)timeBlock {
    if (_timeBlock == nil) {
        _timeBlock = timeBlock;
    }
    _startDate = [NSDate date];
    if(!_running){
        _running = YES;
        if (_timer == nil) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

            dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),0.001 * NSEC_PER_SEC, 0);

            __weak typeof (self)Wself = self;

            dispatch_source_set_event_handler(_timer, ^{
                [Wself updateTimer];                
            });
        }
        dispatch_resume(_timer);
    } else {
        //秒表已经在运行，此时实际是暂停秒表
        _running = NO;
        _pausedDate = [self.dateFormatter dateFromString:_elapsedTime];

        dispatch_suspend(_timer);
    }
}

- (void)updateTimer {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDate *finalTimerDate = _pausedDate == nil ? timerDate :[NSDate dateWithTimeInterval:[_pausedDate timeIntervalSince1970] sinceDate:timerDate];
    NSString *timeString=[self.dateFormatter stringFromDate:finalTimerDate];

    self.elapsedTime  = timeString;

    NSLog(@"秒表计时%@",_elapsedTime);
}

- (void)dealloc{
    NSLog(@"对象释放了");
}

@end
