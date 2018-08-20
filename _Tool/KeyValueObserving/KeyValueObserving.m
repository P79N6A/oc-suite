
#import "KeyValueObserving.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString * const KVOClassPrefix = @"KVOClassPrefix_";
NSString * const KVOAssociatedObservers = @"KVOAssociatedObservers";

#pragma mark - KeyValueObservationInfo

@interface KeyValueObservationInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) ObservingBlock block;

@end

@implementation KeyValueObservationInfo

- (instancetype)initWithObserver:(NSObject *)observer key:(NSString *)key block:(ObservingBlock)block {
    self = [super init];
    if (self) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}

@end

#pragma mark -

static NSString *__getterForSetter(NSString *setter) {
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    // remove 'set' at the begining and ':' at the end
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    // lower case the first letter
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    
    return key;
}

static NSString *__setterForGetter(NSString *getter) {
    if (getter.length <= 0) {
        return nil;
    }
    
    // upper case the first letter
    NSString *firstLetter = [[getter substringToIndex:1] uppercaseString];
    NSString *remainingLetters = [getter substringFromIndex:1];
    
    // add 'set' at the begining and ':' at the end
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingLetters];
    
    return setter;
}

#pragma mark - Overridden Methods

static void __kvoSetter(id self, SEL _cmd, id newValue) {
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = __getterForSetter(setterName);
    
    if (!getterName) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        return;
    }
    
    id oldValue = [self valueForKey:getterName];
    
    struct objc_super superclazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    // cast our pointer so the compiler won't complain
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    // call super's setter, which is original class's setter method
    objc_msgSendSuperCasted(&superclazz, _cmd, newValue);
    
    // look up observers and call the blocks
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(KVOAssociatedObservers));
    for (KeyValueObservationInfo *each in observers) {
        if ([each.key isEqualToString:getterName]) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                each.block(self, getterName, oldValue, newValue);
//            });
        }
    }
}

static Class kvo_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

#pragma mark -

@implementation NSObject ( KVOImpl )

- (Class)observableClassWithOriginalClassName:(NSString *)originalClazzName {
    NSString *observableClazzName = [KVOClassPrefix stringByAppendingString:originalClazzName];
    Class clazz = NSClassFromString(observableClazzName);
    
    if (clazz) {
        return clazz;
    }
    
    // class doesn't exist yet, make it
    Class originalClazz = object_getClass(self);
    Class kvoClazz = objc_allocateClassPair(originalClazz, observableClazzName.UTF8String, 0);
    
    // grab class method's signature so we can borrow it
    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(kvoClazz, @selector(class), (IMP)kvo_class, types);
    
    objc_registerClassPair(kvoClazz);
    
    return kvoClazz;
}

- (BOOL)hasSelector:(SEL)selector {
    Class clazz = object_getClass(self);
    unsigned int methodCount = 0;
    Method* methodList = class_copyMethodList(clazz, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL thisSelector = method_getName(methodList[i]);
        if (thisSelector == selector) {
            free(methodList);
            return YES;
        }
    }
    
    free(methodList);
    return NO;
}

#pragma mark -

- (void)observe:(NSObject *)observable
            for:(NSString *)key
           with:(ObservingBlock)block {
    SEL setterSelector = NSSelectorFromString(__setterForGetter(key));
    Method setterMethod = class_getInstanceMethod([observable class], setterSelector);
    if (!setterMethod) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have a setter for key %@", observable, key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        
        return;
    }
    
    Class observableClazz = object_getClass(observable);
    NSString *observableClazzName = NSStringFromClass(observableClazz);
    
    // if not an KVO class yet
    if (![observableClazzName hasPrefix:KVOClassPrefix]) {
        observableClazz = [observable observableClassWithOriginalClassName:observableClazzName];
        
        // The key operation 1!
        object_setClass(observable, observableClazz);
    }
    
    // add our kvo setter if this class (not superclasses) doesn't implement the setter?
    if (![observable hasSelector:setterSelector]) {
        const char *types = method_getTypeEncoding(setterMethod);
        
        // The key operation 2!
        class_addMethod(observableClazz, setterSelector, (IMP)__kvoSetter, types);
    }
    
    KeyValueObservationInfo *info = [[KeyValueObservationInfo alloc] initWithObserver:self key:key block:block];
    NSMutableArray *observers = objc_getAssociatedObject(observable, (__bridge const void *)(KVOAssociatedObservers));
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(observable, (__bridge const void *)(KVOAssociatedObservers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
}


- (void)unobserve:(NSObject *)observable
              for:(NSString *)key {
    NSMutableArray* observers = objc_getAssociatedObject(observable, (__bridge const void *)(KVOAssociatedObservers));
    
    KeyValueObservationInfo *infoToRemove;
    for (KeyValueObservationInfo* info in observers) {
        if (info.observer == self && [info.key isEqual:key]) {
            infoToRemove = info;
            break;
        }
    }
    
    [observers removeObject:infoToRemove];
}

@end




