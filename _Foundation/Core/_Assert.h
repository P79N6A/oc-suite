
#import <Foundation/Foundation.h>
#import "_Singleton.h"
#import "_Property.h"

#pragma mark -

#if __DEBUG__

#define ASSERT( _expr_ ) [[_Asserter sharedInstance] file:__FILE__ line:__LINE__ func:__PRETTY_FUNCTION__ flag:((_expr_) ? YES : NO) expr:#_expr_];

#else

#define ASSERT( __expr )

#endif

#pragma mark -

#if __cplusplus
extern "C" {
#endif
    
    /**
     *  觸發斷言 · C語言方式
     *
     *  @param file 文件名稱
     *  @param line 文件行號
     *  @param func 方法名稱
     *  @param flag 斷言結果
     *  @param expr 斷言表達式
     */
    
    void __Assert( const char * file, NSUInteger line, const char * func, BOOL flag, const char * expr );
    
#if __cplusplus
}
#endif

#pragma mark -

/**
 *  「武士」·「斷言」
 */

@interface _Asserter : NSObject

@singleton( _Asserter );

@prop_assign( BOOL,	enabled );

/**
 *  若已開啟則關閉，若已關閉則開啟
 */

- (void)toggle;

/**
 *  開啟，使之有效
 */

- (void)enable;

/**
 *  關閉，使之失效
 */

- (void)disable;

/**
 *  觸發斷言
 *
 *  @param file 文件名稱
 *  @param line 文件行號
 *  @param func 方法名稱
 *  @param flag 斷言結果
 *  @param expr 斷言表達式
 */

- (void)file:(const char *)file line:(NSUInteger)line func:(const char *)func flag:(BOOL)flag expr:(const char *)expr;

@end
