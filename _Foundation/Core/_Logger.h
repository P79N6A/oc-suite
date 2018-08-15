
#import "_Precompile.h"
#import "_Preconfigs.h"
#import "_Singleton.h"
#import "_Property.h"

#pragma mark -

typedef enum {
    LogLevel_Error = 0,
    LogLevel_Warn,
    LogLevel_Info,
    LogLevel_Perf,
    LogLevel_All
} LogLevel;

#pragma mark -


#if __DEBUG__

#define INFO( ... )			[[_Logger sharedInstance] file:@(__FILE__) line:__LINE__ func:@(__PRETTY_FUNCTION__) level:LogLevel_Info format:__VA_ARGS__];
#define PERF( ... )			[[_Logger sharedInstance] file:@(__FILE__) line:__LINE__ func:@(__PRETTY_FUNCTION__) level:LogLevel_Perf format:__VA_ARGS__];
#define WARN( ... )			[[_Logger sharedInstance] file:@(__FILE__) line:__LINE__ func:@(__PRETTY_FUNCTION__) level:LogLevel_Warn format:__VA_ARGS__];
#define ERROR( ... )		[[_Logger sharedInstance] file:@(__FILE__) line:__LINE__ func:@(__PRETTY_FUNCTION__) level:LogLevel_Error format:__VA_ARGS__];
#define PRINT( ... )		[[_Logger sharedInstance] file:@(__FILE__) line:__LINE__ func:@(__PRETTY_FUNCTION__) level:LogLevel_All format:__VA_ARGS__];

#define VERBOSE(format, ...) fprintf(stderr, "class：%s \nline： %d \nmethod：%s \nmessage：%s \n%s \n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__LINE__, __func__,[[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String], [@"----------------------------------------------" UTF8String]);

#else

#define INFO( ... )
#define PERF( ... )
#define WARN( ... )
#define ERROR( ... )
#define PRINT( ... )
#define VERBOSE(format, ...)

#endif

#undef	VAR_DUMP
#define VAR_DUMP( __obj )	PRINT( [__obj description] );

#undef	OBJ_DUMP
#define OBJ_DUMP( __obj )	PRINT( [__obj objectToDictionary] );

#pragma mark -

@interface _Logger : NSObject

@singleton( _Logger )

@prop_assign( BOOL,					enabled );

@prop_strong( NSMutableString *,	output );
@prop_strong( NSMutableArray *,		buffer );
@prop_assign( LogLevel,				filter );

@prop_copy( id,                     outputHandler );

- (void)toggle;
- (void)enable;
- (void)disable;

- (void)indent;
- (void)indent:(NSUInteger)tabs;
- (void)unindent;
- (void)unindent:(NSUInteger)tabs;

- (void)outputCapture;
- (void)outputRelease;

- (void)file:(NSString *)file line:(NSUInteger)line func:(NSString *)func level:(LogLevel)level format:(NSString *)format, ...;
- (void)file:(NSString *)file line:(NSUInteger)line func:(NSString *)func level:(LogLevel)level format:(NSString *)format args:(va_list)args;

- (void)flush;
@end
