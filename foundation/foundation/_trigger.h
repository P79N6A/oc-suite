
#import <Foundation/Foundation.h>

// ----------------------------------
// MARK: Macros
// ----------------------------------

#pragma mark -

typedef void ( *ImpFuncType )( id a, SEL b, void * c );

#pragma mark -

#undef  joint
#define joint( name )						property (nonatomic, readonly) NSString * __name

#undef  def_joint
#define def_joint( name	)					dynamic __name

#define hookBefore( name, ... )				hookBefore_( macro_concat(before_, name), __VA_ARGS__)
#define hookBefore_( name, ... )			- (void) macro_join(name, __VA_ARGS__)

#define hookAfter( name, ... )				hookAfter_( macro_concat(after_, name), __VA_ARGS__)
#define hookAfter_( name, ... )				- (void) macro_join(name, __VA_ARGS__)

#pragma mark -

#define trigger( target, prefix, name )		[target performCallChainWithPrefix:macro_string(macro_concat(prefix, name)) reversed:NO]
#define triggerR( target, prefix, name )	[target performCallChainWithPrefix:macro_string(macro_concat(prefix, name)) reversed:YES]

#define triggerBefore( target, name )		[target performCallChainWithPrefix:macro_string(macro_concat(before_, name)) reversed:NO]
#define triggerBeforeR( target, name )		[target performCallChainWithPrefix:macro_string(macro_concat(before_, name)) reversed:YES]

#define triggerAfter( target, name )		[target performCallChainWithPrefix:macro_string(macro_concat(after_, name)) reversed:NO]
#define triggerAfterR( target, name )		[target performCallChainWithPrefix:macro_string(macro_concat(after_, name)) reversed:YES]

#define	callChain( target, name )			[target performCallChainWithName:@(#name) reversed:NO]
#define	callChainR( target, name )			[target performCallChainWithName:@(#name) reversed:YES]

// ----------------------------------
// MARK: Class code
// ----------------------------------

#pragma mark -

@interface NSObject ( Loader )

- (void)load;
- (void)unload;

- (void)performLoad;
- (void)performUnload;

@end

#pragma mark -

@interface NSObject ( Trigger )

#pragma mark - Selector

+ (void)performSelectorWithPrefix:(NSString *)prefix;
- (void)performSelectorWithPrefix:(NSString *)prefix;

- (id)performCallChainWithSelector:(SEL)sel;
- (id)performCallChainWithSelector:(SEL)sel reversed:(BOOL)flag;

- (id)performCallChainWithPrefix:(NSString *)prefix;
- (id)performCallChainWithPrefix:(NSString *)prefix reversed:(BOOL)flag;

- (id)performCallChainWithName:(NSString *)name;
- (id)performCallChainWithName:(NSString *)name reversed:(BOOL)flag;

- (id)performSelector:(SEL)selector withObjects:(NSArray *)objects;
- (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg1 withObject:(id)arg2 waitUntilDone:(BOOL)wait;
- (void)performSelector:(SEL)aSelector withObjects:(NSArray *)arguments afterDelay:(NSTimeInterval)delay;

#pragma mark - Block

+ (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
+ (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;

- (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;

+ (void)cancelBlock:(id)block;

#pragma mark - Asynchronize block

/**
 *  @brief  异步执行代码块
 *
 *  @param block 代码块
 */
- (void)performAsynchronous:(void(^)(void))block;
/**
 *  @brief  GCD主线程执行代码块
 *
 *  @param block 代码块
 *  @param wait  是否同步请求
 */
- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)wait;

/**
 *  @brief  延迟执行代码块
 *
 *  @param seconds 延迟时间 秒
 *  @param block   代码块
 */
- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block;

@end
