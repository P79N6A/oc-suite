
#import <Foundation/Foundation.h>
#import "_Singleton.h"
#import "_Property.h"

/**
 * waitForExpectationsWithTimeout是等待时间，超过了就不再等待往下执行。
 */

#pragma mark - XCTest help

#undef  XCT_WAITFOR
#define XCT_WAITFOR( _case_name_ ) do {\
            [self expectationForNotification:@"suite.unitest.synchronized" object:nil handler:nil];\
            [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {\
                LOG(@"[%@] case test expired on: %@", _case_name_, error);\
            }];\
        } while (0);

#undef  XCT_NOTIFY
#define XCT_NOTIFY \
        [[NSNotificationCenter defaultCenter] postNotificationName:@"suite.unitest.synchronized" object:nil];

#pragma mark -

#undef  XCT_GOON
#define XCT_GOON \
        CFRunLoopStop(CFRunLoopGetCurrent());

#undef  XCT_BLOCK
#define XCT_BLOCK \
        CFRunLoopRun();


#pragma mark - SAMURAI test

#undef  TEST_CASE
#define TEST_CASE( __module, __name ) \
        @interface __TestCase__##__module##_##__name : _TestCase \
        @end \
        @implementation __TestCase__##__module##_##__name

#undef  TEST_CASE_END
#define TEST_CASE_END \
        @end

#undef  DESCRIBE
#define DESCRIBE( ... ) \
        - (void) macro_concat( runTest_, __LINE__ )

#undef  REPEAT
#define REPEAT( __n ) \
        for ( int __i_##__LINE__ = 0; __i_##__LINE__ < __n; ++__i_##__LINE__ )

#undef  EXPECTED
#define EXPECTED( ... ) \
        if ( !(__VA_ARGS__) ) \
        { \
            @throw [_TestFailure expr:#__VA_ARGS__ file:__FILE__ line:__LINE__]; \
        }

#undef  TIMES
#define TIMES( __n ) \
        /* [[SamuraiUnitTest sharedInstance] writeLog:@"Loop %d times @ %@(#%d)", __n, [@(__FILE__) lastPathComponent], __LINE__]; */ \
        for ( int __i_##__LINE__ = 0; __i_##__LINE__ < __n; ++__i_##__LINE__ )

#undef  TEST
#define TEST( __name, __block ) \
        [[_UnitTest sharedInstance] writeLog:@"> %@", @(__name)]; \
        __block

#pragma mark -

@interface _TestFailure : NSException

@prop_strong( NSString *,	expr );
@prop_strong( NSString *,	file );
@prop_assign( NSInteger,	line );

+ (_TestFailure *)expr:(const char *)expr file:(const char *)file line:(int)line;

@end

#pragma mark -

@interface _TestCase : NSObject
@end

#pragma mark -

@interface _UnitTest : NSObject

@singleton( _UnitTest )

@prop_assign( NSUInteger,	failedCount );
@prop_assign( NSUInteger,	succeedCount );

- (void)run;

- (void)writeLog:(NSString *)format, ...;
- (void)flushLog;

@end

