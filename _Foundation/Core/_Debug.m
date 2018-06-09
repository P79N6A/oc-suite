
#import <execinfo.h>
#import "_Precompile.h"
#import "_Debug.h"
#import "_Macros.h"

#pragma mark -

#undef	MAX_CALLSTACK_DEPTH
#define MAX_CALLSTACK_DEPTH	(64)

#pragma mark -

@interface _CallFrame()

+ (NSUInteger)hexValueFromString:(NSString *)text;
+ (id)parseFormat1:(NSString *)line;
+ (id)parseFormat2:(NSString *)line;

@end

#pragma mark -

@implementation _CallFrame

@def_prop_assign( CallFrameType,	type );
@def_prop_strong( NSString *,		process );
@def_prop_assign( NSUInteger,		entry );
@def_prop_assign( NSUInteger,		offset );
@def_prop_strong( NSString *,		clazz );
@def_prop_strong( NSString *,		method );

- (id)init {
    if (self = [super init]) {
        _type = CallFrameType_Unknown;
    }
    return self;
}

- (void)dealloc {
    self.process = nil;
    self.clazz = nil;
    self.method = nil;
}

- (NSString *)description {
    if ( CallFrameType_ObjectC == _type ) {
        return [NSString stringWithFormat:@"[O] %@(0x%08x + %llu) -> [%@ %@]", _process, (unsigned int)_entry, (unsigned long long)_offset, _clazz, _method];
    } else if ( CallFrameType_NativeC == _type ) {
        return [NSString stringWithFormat:@"[C] %@(0x%08x + %llu) -> %@", _process, (unsigned int)_entry, (unsigned long long)_offset, _method];
    } else {
        return [NSString stringWithFormat:@"[X] <unknown>(0x%08x + %llu)", (unsigned int)_entry, (unsigned long long)_offset];
    }
}

+ (NSUInteger)hexValueFromString:(NSString *)text {
    unsigned int number = 0;
    [[NSScanner scannerWithString:text] scanHexInt:&number];
    return (NSUInteger)number;
}

+ (id)parseFormat1:(NSString *)line {
    //	example: peeper  0x00001eca -[PPAppDelegate application:didFinishLaunchingWithOptions:] + 106
    
    static __strong NSRegularExpression * __regex = nil;
    
    if ( nil == __regex ) {
        NSError * error = NULL;
        NSString * expr = @"^[0-9]*\\s*([a-z0-9_]+)\\s+(0x[0-9a-f]+)\\s+-\\[([a-z0-9_]+)\\s+([a-z0-9_:]+)]\\s+\\+\\s+([0-9]+)$";
        
        __regex = [NSRegularExpression regularExpressionWithPattern:expr options:NSRegularExpressionCaseInsensitive error:&error];
    }
    
    NSTextCheckingResult * result = [__regex firstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
    
    if ( result && (__regex.numberOfCaptureGroups + 1) == result.numberOfRanges ) {
        _CallFrame * frame = [[_CallFrame alloc] init];
        if ( frame ) {
            frame.type = CallFrameType_ObjectC;
            frame.process = [line substringWithRange:[result rangeAtIndex:1]];
            frame.entry = [self hexValueFromString:[line substringWithRange:[result rangeAtIndex:2]]];
            frame.clazz = [line substringWithRange:[result rangeAtIndex:3]];
            frame.method = [line substringWithRange:[result rangeAtIndex:4]];
            frame.offset = (NSUInteger)[[line substringWithRange:[result rangeAtIndex:5]] intValue];
            
            return frame;
        }
    }
    
    return nil;
}

+ (id)parseFormat2:(NSString *)line
{
    //	example: UIKit 0x0105f42e UIApplicationMain + 1160
    
    static __strong NSRegularExpression * __regex = nil;
    
    if ( nil == __regex )
    {
        NSError * error = NULL;
        NSString * expr = @"^[0-9]*\\s*([a-z0-9_]+)\\s+(0x[0-9a-f]+)\\s+([a-z0-9_]+)\\s+\\+\\s+([0-9]+)$";
        
        __regex = [NSRegularExpression regularExpressionWithPattern:expr options:NSRegularExpressionCaseInsensitive error:&error];
    }
    
    NSTextCheckingResult * result = [__regex firstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
    
    if ( result && (__regex.numberOfCaptureGroups + 1) == result.numberOfRanges )
    {
        _CallFrame * frame = [[_CallFrame alloc] init];
        if ( frame )
        {
            frame.type = CallFrameType_NativeC;
            frame.process = [line substringWithRange:[result rangeAtIndex:1]];
            frame.entry = [self hexValueFromString:[line substringWithRange:[result rangeAtIndex:2]]];
            frame.clazz = nil;
            frame.method = [line substringWithRange:[result rangeAtIndex:3]];
            frame.offset = (NSUInteger)[[line substringWithRange:[result rangeAtIndex:4]] intValue];
            
            return frame;
        }
    }
    
    return nil;
}

+ (id)unknown
{
    return [[_CallFrame alloc] init];
}

+ (id)parse:(NSString *)line
{
    if ( 0 == [line length] )
        return nil;
    
    id frame1 = [_CallFrame parseFormat1:line];
    if ( frame1 )
        return frame1;
    
    id frame2 = [_CallFrame parseFormat2:line];
    if ( frame2 )
        return frame2;
    
    return nil;
}

@end

#pragma mark -

@implementation _Debugger

@def_singleton( _Debugger )

@def_prop_readonly( NSArray *,	callstack );

#if __DEBUG__
static void __uncaughtExceptionHandler( NSException * exception )
{
    fprintf( stderr, "\nUncaught exception: %s\n%s",
            [[exception description] UTF8String],
            [[[exception callStackSymbols] description] UTF8String] );
    
    TRAP();
}
#endif	// #if __DEBUG__

#if __DEBUG__
static void __uncaughtSignalHandler( int signal )
{
    fprintf( stderr, "\nUncaught signal: %d", signal );
    
    TRAP();
}
#endif	// #if __DEBUG__

+ (void)classAutoLoad
{
#if __DEBUG__
    NSSetUncaughtExceptionHandler( &__uncaughtExceptionHandler );
    
    signal( SIGABRT,	&__uncaughtSignalHandler );
    signal( SIGILL,		&__uncaughtSignalHandler );
    signal( SIGSEGV,	&__uncaughtSignalHandler );
    signal( SIGFPE,		&__uncaughtSignalHandler );
    signal( SIGBUS,		&__uncaughtSignalHandler );
    signal( SIGPIPE,	&__uncaughtSignalHandler );
#endif
    
    [_Debugger sharedInstance];
}

- (NSArray *)callstack
{
    return [[_Debugger sharedInstance] callstack:MAX_CALLSTACK_DEPTH];
}

- (NSArray *)callstack:(NSInteger)depth;
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    void * stacks[MAX_CALLSTACK_DEPTH] = { 0 };
    
    int frameCount = backtrace( stacks, MIN((int)depth, MAX_CALLSTACK_DEPTH) );
    if ( frameCount )
    {
        char ** symbols = backtrace_symbols( stacks, (int)frameCount );
        if ( symbols )
        {
            for ( int i = 0; i < frameCount; ++i )
            {
                NSString * line = [NSString stringWithUTF8String:(const char *)symbols[i]];
                if ( 0 == [line length] )
                    continue;
                
                _CallFrame * frame = [_CallFrame parse:line];
                if ( frame )
                {
                    [array addObject:frame];
                }
            }
            
            free( symbols );
        }
    }
    
    return array;
}

- (void)trap
{
#if __DEBUG__
#if defined(__ppc__)
    asm("trap");
#elif defined(__i386__) ||  defined(__amd64__)
    asm("int3");
#endif
#endif
}

- (void)trace {
    [self trace:MAX_CALLSTACK_DEPTH];
}

- (void)trace:(NSInteger)depth {
    NSArray * callstack = [self callstack:depth];
    
    if ( callstack && callstack.count ) {
        LOG(@"%@", [callstack description]);
    }
}

@end

#pragma mark -

@implementation NSObject(Debug)

- (id)debugQuickLookObject
{
#if __DEBUG__
TODO("补全")
//    _Logger * logger = [_Logger sharedInstance];
//    
//    [logger outputCapture];
//    
//    [self dump];
//    
//    [logger outputRelease];
//    
//    return logger.output;
//
    return nil;
#else	// #if __DEBUG__
    
    return nil;
    
#endif	// #if __DEBUG__
}

- (void)dump
{
}

@end
