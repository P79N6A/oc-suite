//
//  PERFORMANCE.m
//  log_test_with_framework
//
//  Created by 7 on 11/09/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "_Macro.h"
#import "_PerfTimer.h"
#import "PERFTEST.h"

// -------------------------------------------
// Class source
// -------------------------------------------

@implementation PERFTEST {
    NSMutableDictionary * _tags;
}

@DEF_SINGLETON( PERFTEST );

- (id)init {
    self = [super init];
    if ( self ) {
        _tags = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)enter:(NSString *)tag {
    _PerfTimer *timer = [_PerfTimer new];
    
    [timer start];

    NSString * name = [NSString stringWithFormat:@"%@", tag];
    
    [_tags setObject:timer forKey:name];
}

- (void)leave:(NSString *)tag {
    @autoreleasepool {
        _PerfTimer *timer = [_tags objectForKey:tag];
        
        [timer capture];
        
        TLOG(@"time measured: %@", [timer stringWithElapsedTime]);
        
        [_tags removeObjectForKey:tag];
    }
}

@end
