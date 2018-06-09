#import "_Macros.h"
#import "_Precompile.h"
#import "_Performance.h"

#pragma mark - 

@implementation NSObject ( Performance )

- (void)runBlockWithPerformance:(void (^)(void)) block withTag:(NSString *) tag {
    
    double a = CFAbsoluteTimeGetCurrent();
    block();
    double b = CFAbsoluteTimeGetCurrent();
    
    unsigned int m = ((b-a) * 1000.0f); // convert from seconds to milliseconds
    
    LOG(@"%@: %d ms", tag ? @"" : @"Time taken", m);
}

@end

#pragma mark -

@implementation _Performance {
    NSMutableDictionary * _tags;
}

@def_singleton( _Performance );

- (id)init {
    self = [super init];
    if ( self ) {
        _tags = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)enter:(NSString *)tag {
    NSNumber * time = [NSNumber numberWithDouble:CACurrentMediaTime()];
    NSString * name = [NSString stringWithFormat:@"%@ enter", tag];
    
    [_tags setObject:time forKey:name];
}

- (void)leave:(NSString *)tag {
    @autoreleasepool {
        NSString * name1 = [NSString stringWithFormat:@"%@ enter", tag];
        NSString * name2 = [NSString stringWithFormat:@"%@ leave", tag];
        
#if __LOGGING__
        
        CFTimeInterval time1 = [[_tags objectForKey:name1] doubleValue];
        CFTimeInterval time2 = CACurrentMediaTime(); // this method returns, units to seconds
        
        logi( @"Time '%@' = %.0f(ms)", tag, fabs((time2 - time1)*1000) );
        
#endif	// #if __LOGGING__
        
        [_tags removeObjectForKey:name1];
        [_tags removeObjectForKey:name2];
    }
}

@end
