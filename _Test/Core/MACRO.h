#import "CONFIG.h"

/**
 * @param whileTrue Can be anything
 * @param seconds NSTimeInterval
 */
#define stall_while(whileTrue, limitInSeconds)\
({\
NSDate *giveUpDate = [NSDate dateWithTimeIntervalSinceNow:limitInSeconds];\
while ((whileTrue) && [giveUpDate timeIntervalSinceNow] > 0)\
{\
NSDate *loopIntervalDate = [NSDate dateWithTimeIntervalSinceNow:0.01];\
[[NSRunLoop currentRunLoop] runUntilDate:loopIntervalDate];\
}\
})

/**
 * @param whileTrue Can be anything
 * @param seconds NSTimeInterval
 * @param ... Description format string (optional)
 */
#define wait_while(whileTrue, seconds, ...)\
({\
NSTimeInterval castedLimit = seconds;\
NSString *conditionString = [NSString stringWithFormat:@"(%s) should NOT be true after async operation completed", #whileTrue];\
stall_while(whileTrue, castedLimit);\
if(whileTrue)\
{\
NSString *description = [NSString stringWithFormat:@"" __VA_ARGS__]; \
NSString *failString = makeFailString(conditionString, castedLimit, description, ##__VA_ARGS__);\
_AGWW_FAIL(@"%@", failString);\
}\
})

// TODO: should be replaced with
// https://github.com/JensAyton/JAValueToString

#define primitive_as_string(value) \
({\
const char *valueType = @encode(__typeof__(value));\
NSString *format = [NSString stringWithFormat:@"%s", printFormatTypeForObjCType(valueType)];\
NSString *valueAsString = [NSString stringWithFormat:format, value];\
valueAsString;\
})

__unused static NSString *makeFailString(NSString *conditionString, NSTimeInterval seconds, NSString *description, ...) {
    va_list args;
    va_start(args, description);
    
    NSString *outputFormat = [NSString stringWithFormat:@"Async test didn't complete within %.2f seconds. %@. %@", (NSTimeInterval) seconds, conditionString, description];
    NSString *outputString = [[NSString alloc] initWithFormat:outputFormat arguments:args];
    va_end(args);
    
    return outputString;
}

__unused static const char *printFormatTypeForObjCType(const char *type)
{
    if(strcmp(type, @encode(BOOL)) == 0)
        return "%i";
    else if(strcmp(type, @encode(int)) == 0)
        return "%i";
    else if(strcmp(type, @encode(unsigned int)) == 0)
        return "%u";
    else if(strcmp(type, @encode(long)) == 0)
        return "%li";
    else if(strcmp(type, @encode(unsigned long)) == 0)
        return "%lu";
    else if(strcmp(type, @encode(long long)) == 0)
        return "%lli";
    else if(strcmp(type, @encode(unsigned long long)) == 0)
        return "%llu";
    else if(strcmp(type, @encode(float)) == 0)
        return "%f";
    else if(strcmp(type, @encode(double)) == 0)
        return "%d";
    else
        return "%i";
}

/**
 *  @brief If u don't wanna write comments, use 'caseof' then.
 *
 *  @Must name it at least!!!!
 *
 *  @todo shoule be case method, module name, case name
 *
 *  @example caseof(@"赛程预约", GameScheduleSubscribe) {}
 */
#define caseof( _name_, _method_ ) - (void)test##_method_

/**
 *  @brief Mute 'caseof' with one single char 'f'
 */
#define caseoff( _name_, _method_ ) - (void)mute_test##_method_

/**
 @brief Test case concurrency
 */
#if __CONC__
#   define concof( _name_, _method_ ) - (void)testConcurrency##_method_
#else
#   define concof( _name_, _method_ ) - (void)Concurrency##_method_
#endif

/**
 @brief Test case performance measured 10 times
 */
#if __PERF__
#   define perfof( _name_, _method_ ) - (void)testPerformance##_method_
#else
#   define perfof( _name_, _method_ ) - (void)Performance##_method_
#endif

/**
 *  Asynchronized handle
 *
 *  1. proc_xxxx, can implement asynchronize operation, but without timeout.
 *  2. Otherwise please use XCTestExpectation
 *
 *  3. waitfor
 *  4. notifyit
 */
#define proc_paused          { CFRunLoopRun(); }
#define proc_resumed         { CFRunLoopStop(CFRunLoopGetCurrent()); }

#undef  waitfor
#define waitfor( _case_name_ ) do {\
        [self expectationForNotification:@"unitest.synchronized" object:nil handler:nil];\
        [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {\
            NSLog(@"[%@] case test expired on: %@", _case_name_, error);\
        }];\
    } while (0);

#undef  notifythat
#define notifythat \
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unitest.synchronized" object:nil];

/**
 *  @brief Use this when u need to mock singleton class
 *
 *  @usage
 *  1. If u wanna define singleton class for unit test, insert partial code to class implementation, use 'singleton_mock', 'def_singleton_mock'
 *  2. If u just wanna mock a singleton class in unit test, use 'singleton_mockable'
 *  3. Use 'mockSingleton' as mock method like ''mockClass, 'mockProtocol'
 *
 */
#define singleton_mock( _class_ )                   \
property (nonatomic, readonly) _class_ * sharedInstance; \
+ (instancetype)sharedInstance;             \
+ (instancetype)classMock;                  \
+ (instancetype)partialMock:(_class_ *)obj; \
+ (void)releaseMock;

#define def_singleton_mock( _class_ )                               \
dynamic sharedInstance;                                     \
- (_class_ *)sharedInstance {                               \
return [_class_ sharedInstance];                        \
}                                                           \
static _class_ *mock_singleton_##_class_ = nil;             \
+ (instancetype)sharedInstance {                            \
if (mock_singleton_##_class_)  return mock_singleton_##_class_; \
return invokeSupersequentNoParameters();                \
}                                                           \
+ (instancetype)classMock {                                 \
mock_singleton_##_class_ = OCMClassMock([self class]);  \
return mock_singleton_##_class_;                        \
}                                                           \
+ (instancetype)partialMock:(_class_ *)obj {                \
mock_singleton_##_class_ = OCMPartialMock(obj);         \
return mock_singleton_##_class_;                        \
}                                                           \
+ (void)releaseMock {                                       \
mock_singleton_##_class_ = nil;                         \
}


#define singleton_mockable( _class_ )               \
@interface _class_ (UnitTestSingleton)      \
@singleton_mock(_class_)                    \
@end                                        \
@implementation _class_ (UnitTestSingleton) \
@def_singleton_mock(_class_)                \
@end                                        \

#define mockSingleton( _class_ ) [_class_ sharedInstance]
#define mockSingletonKill( _class_ ) [_class_ releaseMock]
