
#import "_Swizzler.h"

#if TARGET_OS_IPHONE
	#import <objc/runtime.h>
	#import <objc/message.h>
#else
	#import <objc/objc-class.h>
#endif

#define SetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)	\
	if (ERROR_VAR) {	\
		NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
		*ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
										 code:-1	\
									 userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
	}
#define SetNSError(ERROR_VAR, FORMAT,...) SetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

// ----------------------------------
// Source code
// ----------------------------------

@implementation NSObject ( Swizzle )

#pragma mark - Swizzle method

+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)newSelector error:(NSError *__autoreleasing *)error {
	Method origMethod = class_getInstanceMethod(self, originalSelector);
	if (!origMethod) {
		SetNSError(error, @"original method %@ not found for class %@", NSStringFromSelector(originalSelector), [self class]);
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(self, newSelector);
	if (!altMethod) {
		SetNSError(error, @"alternate method %@ not found for class %@", NSStringFromSelector(newSelector), [self class]);
		return NO;
	}
	
	class_addMethod(self,
					originalSelector,
					class_getMethodImplementation(self, originalSelector),
					method_getTypeEncoding(origMethod));
	class_addMethod(self,
					newSelector,
					class_getMethodImplementation(self, newSelector),
					method_getTypeEncoding(altMethod));
	
	method_exchangeImplementations(class_getInstanceMethod(self, originalSelector), class_getInstanceMethod(self, newSelector));
	return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)originalSelector withClassMethod:(SEL)newSelector error:(NSError *__autoreleasing *)error {
	return [self swizzleMethod:originalSelector withMethod:newSelector error:error];
}

#pragma mark - Copy method

+ (BOOL)copyMethod:(SEL)newSelector toMethod:(SEL)dstSelector error:(NSError *__autoreleasing *)error {
    Method origMethod = class_getInstanceMethod(self, newSelector);
    if (!origMethod) {
        SetNSError(error, @"original method %@ not found for class %@", NSStringFromSelector(newSelector), [self class]);
        return NO;
    }
    
    Method dstMethod = class_getInstanceMethod(self, dstSelector);
    if (!dstMethod) {
        SetNSError(error, @"destination method %@ not found for class %@", NSStringFromSelector(dstSelector), [self class]);
        return NO;
    }

    class_addMethod(self,
                    dstSelector,
                    class_getMethodImplementation(self, dstSelector),
                    method_getTypeEncoding(dstMethod));
    
    method_setImplementation(class_getInstanceMethod(self, dstSelector), class_getMethodImplementation(self, newSelector));
    
    return YES;
}

+ (BOOL)copyClassMethod:(SEL)newSelector toClassMethod:(SEL)dstSelector error:(NSError *__autoreleasing *)error {
    return [self copyMethod:newSelector toMethod:dstSelector error:error];
}

#pragma mark - 待处理 @王涛

static BOOL __method_swizzle(Class klass, SEL origSel, SEL altSel) {
    if (!klass)
        return NO;
    
    Method __block origMethod, __block altMethod;
    
    void (^find_methods)(void) = ^ {
        unsigned methodCount = 0;
        Method *methodList = class_copyMethodList(klass, &methodCount);
        
        origMethod = altMethod = NULL;
        
        if (methodList)
            for (unsigned i = 0; i < methodCount; ++i) {
                if (method_getName(methodList[i]) == origSel)
                    origMethod = methodList[i];
                
                if (method_getName(methodList[i]) == altSel)
                    altMethod = methodList[i];
            }
        
        free(methodList);
    };
    
    find_methods();
    
    if (!origMethod) {
        origMethod = class_getInstanceMethod(klass, origSel);
        
        if (!origMethod)
            return NO;
        
        if (!class_addMethod(klass, method_getName(origMethod), method_getImplementation(origMethod), method_getTypeEncoding(origMethod)))
            return NO;
    }
    
    if (!altMethod) {
        altMethod = class_getInstanceMethod(klass, altSel);
        
        if (!altMethod)
            return NO;
        
        if (!class_addMethod(klass, method_getName(altMethod), method_getImplementation(altMethod), method_getTypeEncoding(altMethod)))
            return NO;
    }
    
    find_methods();
    
    if (!origMethod || !altMethod)
        return NO;
    
    method_exchangeImplementations(origMethod, altMethod);
    
    return YES;
}

static void __method_append(Class toClass, Class fromClass, SEL selector) {
    if (!toClass || !fromClass || !selector)
        return;
    
    Method method = class_getInstanceMethod(fromClass, selector);
    
    if (!method)
        return;
    
    class_addMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
}

static void __method_replace(Class toClass, Class fromClass, SEL selector) {
    if (!toClass || !fromClass || ! selector)
        return;
    
    Method method = class_getInstanceMethod(fromClass, selector);
    
    if (!method)
        return;
    
    class_replaceMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
}

// Implimentation

+ (void)swizzleMethod:(SEL)originalSelector withMethod:(SEL)newSelector {
    __method_swizzle(self.class, originalSelector, newSelector);
}

+ (void)appendMethod:(SEL)newSelector fromClass:(Class)klass {
    __method_append(self.class, klass, newSelector);
}

+ (void)replaceMethod:(SEL)selector fromClass:(Class)klass {
    __method_replace(self.class, klass, selector);
}

@end
