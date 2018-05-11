
#import <dispatch/dispatch.h>

#import "_Precompile.h"
#import "_Trigger.h"
#import "NSMutableArray+Extension.h"

#import "_pragma_push.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject ( Loader )

- (void)load {
}

- (void)unload {
}

- (void)performLoad {
    [self performCallChainWithPrefix:@"before_load" reversed:NO];
    [self performCallChainWithSelector:@selector(load) reversed:NO];
    [self performCallChainWithPrefix:@"after_load" reversed:NO];
}

- (void)performUnload {
    [self performCallChainWithPrefix:@"before_unload" reversed:YES];
    [self performCallChainWithSelector:@selector(unload) reversed:YES];
    [self performCallChainWithPrefix:@"after_unload" reversed:YES];
}

@end

#pragma mark -

@implementation NSObject(Trigger)

+ (void)performSelectorWithPrefix:(NSString *)prefixName {
    unsigned int	methodCount = 0;
    Method *		methodList = class_copyMethodList( self, &methodCount );
    
    if ( methodList && methodCount ) {
        for ( NSUInteger i = 0; i < methodCount; ++i ) {
            SEL sel = method_getName( methodList[i] );
            
            const char * name = sel_getName( sel );
            const char * prefix = [prefixName UTF8String];
            
            if ( 0 == strcmp(prefix, name) ) {
                continue;
            }
            
            if ( 0 == strncmp( name, prefix, strlen(prefix) ) ) {
                ImpFuncType imp = (ImpFuncType)method_getImplementation( methodList[i] );
                if ( imp ) {
                    imp( self, sel, nil );
                }
            }
        }
    }
    
    free( methodList );
}

- (void)performSelectorWithPrefix:(NSString *)prefixName {
    unsigned int	methodCount = 0;
    Method *		methodList = class_copyMethodList( [self class], &methodCount );
    
    if ( methodList && methodCount ) {
        for ( NSUInteger i = 0; i < methodCount; ++i ) {
            SEL sel = method_getName( methodList[i] );
            
            const char * name = sel_getName( sel );
            const char * prefix = [prefixName UTF8String];
            
            if ( 0 == strcmp( prefix, name ) ) {
                continue;
            }
            
            if ( 0 == strncmp( name, prefix, strlen(prefix) ) ) {
                ImpFuncType imp = (ImpFuncType)method_getImplementation( methodList[i] );
                if ( imp ) {
                    imp( self, sel, nil );
                }
            }
        }
    }
    
    free( methodList );
}

- (id)performCallChainWithSelector:(SEL)sel {
    return [self performCallChainWithSelector:sel reversed:NO];
}

- (id)performCallChainWithSelector:(SEL)sel reversed:(BOOL)flag {
    NSMutableArray * classStack = [NSMutableArray nonRetainingArray];
    
    for ( Class thisClass = [self class]; nil != thisClass; thisClass = class_getSuperclass( thisClass ) ) {
        if ( flag ) {
            [classStack addObject:thisClass];
        } else {
            [classStack insertObject:thisClass atIndex:0];
        }
    }
    
    ImpFuncType prevImp = NULL;
    
    for ( Class thisClass in classStack ) {
        Method method = class_getInstanceMethod( thisClass, sel );
        if ( method ) {
            ImpFuncType imp = (ImpFuncType)method_getImplementation( method );
            if ( imp ) {
                if ( imp == prevImp ) {
                    continue;
                }
                
                imp( self, sel, nil );
                
                prevImp = imp;
            }
        }
    }
    
    return self;
}

- (id)performCallChainWithPrefix:(NSString *)prefix {
    return [self performCallChainWithPrefix:prefix reversed:YES];
}

- (id)performCallChainWithPrefix:(NSString *)prefixName reversed:(BOOL)flag {
    NSMutableArray * classStack = [NSMutableArray nonRetainingArray];
    
    for ( Class thisClass = [self class]; nil != thisClass; thisClass = class_getSuperclass( thisClass ) ) {
        if ( flag ) {
            [classStack addObject:thisClass];
        } else {
            [classStack insertObject:thisClass atIndex:0];
        }
    }
    
    for ( Class thisClass in classStack ) {
        unsigned int	methodCount = 0;
        Method *		methodList = class_copyMethodList( thisClass, &methodCount );
        
        if ( methodList && methodCount ) {
            for ( NSUInteger i = 0; i < methodCount; ++i ) {
                SEL sel = method_getName( methodList[i] );
                
                const char * name = sel_getName( sel );
                const char * prefix = [prefixName UTF8String];
                
                if ( 0 == strcmp( prefix, name ) ) {
                    continue;
                }
                
                if ( 0 == strncmp( name, prefix, strlen(prefix) ) ) {
                    ImpFuncType imp = (ImpFuncType)method_getImplementation( methodList[i] );
                    if ( imp ) {
                        imp( self, sel, nil );
                    }
                }
            }
        }
        
        free( methodList );
    }
    
    return self;
}

- (id)performCallChainWithName:(NSString *)name {
    return [self performCallChainWithName:name reversed:NO];
}

- (id)performCallChainWithName:(NSString *)name reversed:(BOOL)flag {
    SEL selector = NSSelectorFromString( name );
    if ( selector ) {
        NSString * prefix1 = [NSString stringWithFormat:@"before_%@", name];
        NSString * prefix2 = [NSString stringWithFormat:@"after_%@", name];
        
        [self performCallChainWithPrefix:prefix1 reversed:flag];
        [self performCallChainWithSelector:selector reversed:flag];
        [self performCallChainWithPrefix:prefix2 reversed:flag];
    }
    return self;
}

#pragma mark -

#pragma mark -

- (id)performSelector:(SEL)selector withObjects:(NSArray *)objects {
    // 方法签名(方法的描述)
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        
        //可以抛出异常也可以不操作。
    }
    
    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;
    
    // 设置参数
    NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    paramsCount = MIN(paramsCount, objects.count);
    for (NSInteger i = 0; i < paramsCount; i++) {
        id object = objects[i];
        if ([object isKindOfClass:[NSNull class]]) continue;
        [invocation setArgument:&object atIndex:i + 2];
    }
    
    // 调用方法
    [invocation invoke];
    
    // 获取返回值
    id returnValue = nil;
    if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
        [invocation getReturnValue:&returnValue];
    }
    
    return returnValue;
}

- (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg1 withObject:(id)arg2 waitUntilDone:(BOOL)wait {
    NSMethodSignature *sig = [self methodSignatureForSelector:selector];
    if (!sig)
        return;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    [invocation setTarget:self];
    [invocation setSelector:selector];
    [invocation setArgument:&arg1 atIndex:2];
    [invocation setArgument:&arg2 atIndex:3];
    [invocation retainArguments];
    
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
}

- (void)performSelector:(SEL)aSelector withObjects:(NSArray *)arguments afterDelay:(NSTimeInterval)delay {
    NSMethodSignature *sig = [self methodSignatureForSelector:aSelector];
    if (!sig)
        return;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    
    for (int i = 0; i < arguments.count; i++) {
        id argument = [arguments objectAtIndex:i];
        [invocation setArgument:&argument atIndex:2+i];
    }
    
    [invocation retainArguments];
    
    [invocation performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

#pragma mark - Block

static inline dispatch_time_t __dTimeDelay(NSTimeInterval time) {
    int64_t delta = (int64_t)(NSEC_PER_SEC * time);
    return dispatch_time(DISPATCH_TIME_NOW, delta);
}

+ (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled)block();
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(__dTimeDelay(delay), dispatch_get_main_queue(), ^{
        wrappingBlock(NO);
    });
    
    return wrappingBlock;
}

+ (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id arg) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(arg);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(__dTimeDelay(delay), dispatch_get_main_queue(), ^{
        wrappingBlock(NO, anObject);
    });
    
    return wrappingBlock;
}

- (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block();
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(__dTimeDelay(delay), dispatch_get_main_queue(), ^{
        wrappingBlock(NO);
    });
    
    return wrappingBlock;
}

- (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id arg) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(arg);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(__dTimeDelay(delay), dispatch_get_main_queue(), ^{
        wrappingBlock(NO, anObject);
    });
    
    return wrappingBlock;
}

+ (void)cancelBlock:(id)block {
    if (!block) return;
    
    void (^aWrappingBlock)(BOOL) = (void(^)(BOOL))block;
    
    aWrappingBlock(YES);
}

+ (void)cancelPreviousPerformBlock:(id)aWrappingBlockHandle {
    [self cancelBlock:aWrappingBlockHandle];
}

#pragma mark - Asynchronize block

/**
 *  @brief  异步执行代码块
 *
 *  @param block 代码块
 */
- (void)performAsynchronous:(void(^)(void))block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}
/**
 *  @brief  GCD主线程执行代码块
 *
 *  @param block 代码块
 *  @param shouldWait  是否同步请求
 */
- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)shouldWait {
    if (shouldWait) {
        // Synchronous
        dispatch_sync(dispatch_get_main_queue(), block);
    } else {
        // Asynchronous
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
/**
 *  @brief  延迟执行代码块
 *
 *  @param seconds 延迟时间 秒
 *  @param block   代码块
 */
- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_current_queue(), block);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
    
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if __SAMURAI_TESTING__

TEST_CASE( Core, Object )
{
}

DESCRIBE( before )
{
}

DESCRIBE( after )
{
}

TEST_CASE_END

#endif	// #if __TESTING__

#import "_pragma_pop.h"

//#endif
