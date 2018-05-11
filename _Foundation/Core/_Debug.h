
#import <Foundation/Foundation.h>
#import "_Property.h"
#import "_Singleton.h"

#pragma mark -

#if __DEBUG__

#if defined(__ppc__)

#undef	TRAP
#define TRAP()			asm("trap");

#elif defined(__i386__) ||  defined(__amd64__)

#undef	TRAP
#define TRAP()			asm("int3");

#else

#undef	TRAP
#define TRAP()

#endif

#else

#undef	TRAP
#define TRAP()

#endif

#undef	TRAP_
#define TRAP_( expr )	if ( expr ) { TRAP; };

#pragma mark -

#undef	TRACE
#define TRACE()			[[_Debugger sharedInstance] trace];

#pragma mark -

typedef enum {
    CallFrameType_Unknown = 0,	/// 未知調用棧類型
    CallFrameType_ObjectC = 0,	/// Objective-C
    CallFrameType_NativeC = 0,	/// C
} CallFrameType;

#pragma mark -

@interface NSObject(Debug)

- (void)dump;

@end

#pragma mark -

/**
 *  「武士」·「調用棧」
 */

@interface _CallFrame : NSObject

@prop_assign( CallFrameType,	type );
@prop_strong( NSString *,		process );
@prop_assign( NSUInteger,		entry );
@prop_assign( NSUInteger,		offset );
@prop_strong( NSString *,		clazz );
@prop_strong( NSString *,		method );

/**
 *  解析原始調用棧数据
 *
 *  @param line 调用栈原始数据
 *
 *  @return 調用棧對象
 */

+ (id)parse:(NSString *)line;

/**
 *  创建调用栈对象
 *
 *  @return 调用栈对象
 */

+ (id)unknown;

@end

#pragma mark -

/**
 *  「武士」·「調試器」
 */

@interface _Debugger : NSObject

@singleton( _Debugger )

@prop_readonly( NSArray *,	callstack );

/**
 *  獲取調用棧（當前線程）
 *
 *  @return 調用棧對象數組
 */

- (NSArray *)callstack;

/**
 *  @brief 獲取調用棧（當前線程）
 *
 *  @param depth 最大棧深
 *
 *  @return 調用棧對象數組
 */

- (NSArray *)callstack:(NSInteger)depth;

/**
 *  軟件斷點
 */

- (void)trap;

/**
 *  打印調用棧
 */

- (void)trace;

/**
 *  打印調用棧
 *
 *  @param depth 最大棧深
 */

- (void)trace:(NSInteger)depth;

@end

