#import "NSObject+BlockDelegate.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "_DynamicDelegate.h"
#import "NSObject+DynamicDelegate.h"

#pragma mark - Declarations and macros

extern Protocol *__dataSourceProtocol(Class cls);
extern Protocol *__delegateProtocol(Class cls);

#pragma mark - Functions

static BOOL __object_isKindOfClass(id obj, Class testClass)
{
	BOOL isKindOfClass = NO;
	Class cls = object_getClass(obj);
	while (cls && !isKindOfClass) {
		isKindOfClass = (cls == testClass);
		cls = class_getSuperclass(cls);
	}

	return isKindOfClass;
}

static Protocol *__protocolForDelegatingObject(id obj, Protocol *protocol)
{
	NSString *protocolName = NSStringFromProtocol(protocol);
	if ([protocolName hasSuffix:@"Delegate"]) {
		Protocol *p = __delegateProtocol([obj class]);
		if (p) return p;
	} else if ([protocolName hasSuffix:@"DataSource"]) {
		Protocol *p = __dataSourceProtocol([obj class]);
		if (p) return p;
	}

	return protocol;
}

static inline BOOL isValidIMP(IMP impl) {
#if defined(__arm64__)
    if (impl == NULL || impl == _objc_msgForward) return NO;
#else
    if (impl == NULL || impl == _objc_msgForward || impl == (IMP)_objc_msgForward_stret) return NO;
#endif
    return YES;
}

static BOOL addMethodWithIMP(Class cls, SEL oldSel, SEL newSel, IMP newIMP, const char *types, BOOL aggressive) {
	if (!class_addMethod(cls, oldSel, newIMP, types)) {
		return NO;
	}

	// We just ended up implementing a method that doesn't exist
	// (-[NSURLConnection setDelegate:]) or overrode a superclass
	// version (-[UIImagePickerController setDelegate:]).
	IMP parentIMP = NULL;
	Class superclass = class_getSuperclass(cls);
	while (superclass && !isValidIMP(parentIMP)) {
		parentIMP = class_getMethodImplementation(superclass, oldSel);
		if (isValidIMP(parentIMP)) {
			break;
		} else {
			parentIMP = NULL;
		}

		superclass = class_getSuperclass(superclass);
	}

	if (parentIMP) {
		if (aggressive) {
			return class_addMethod(cls, newSel, parentIMP, types);
		}

		class_replaceMethod(cls, newSel, newIMP, types);
		class_replaceMethod(cls, oldSel, parentIMP, types);
	}

	return YES;
}

static BOOL swizzleWithIMP(Class cls, SEL oldSel, SEL newSel, IMP newIMP, const char *types, BOOL aggressive) {
    Method origMethod = class_getInstanceMethod(cls, oldSel);

	if (addMethodWithIMP(cls, oldSel, newSel, newIMP, types, aggressive)) {
		return YES;
	}

	// common case, actual swap
	BOOL ret = class_addMethod(cls, newSel, newIMP, types);
	Method newMethod = class_getInstanceMethod(cls, newSel);
	method_exchangeImplementations(origMethod, newMethod);
	return ret;
}

static SEL selectorWithPattern(const char *prefix, const char *key, const char *suffix) {
	size_t prefixLength = prefix ? strlen(prefix) : 0;
	size_t suffixLength = suffix ? strlen(suffix) : 0;

	char initial = key[0];
	if (prefixLength) initial = (char)toupper(initial);
	size_t initialLength = 1;

	const char *rest = key + initialLength;
	size_t restLength = strlen(rest);

	char selector[prefixLength + initialLength + restLength + suffixLength + 1];
	memcpy(selector, prefix, prefixLength);
	selector[prefixLength] = initial;
	memcpy(selector + prefixLength + initialLength, rest, restLength);
	memcpy(selector + prefixLength + initialLength + restLength, suffix, suffixLength);
	selector[prefixLength + initialLength + restLength + suffixLength] = '\0';

	return sel_registerName(selector);
}

static SEL getterForProperty(objc_property_t property, const char *name)
{
	if (property) {
		char *getterName = property_copyAttributeValue(property, "G");
		if (getterName) {
			SEL getter = sel_getUid(getterName);
			free(getterName);
			if (getter) return getter;
		}
	}

	const char *propertyName = property ? property_getName(property) : name;
	return sel_registerName(propertyName);
}

static SEL setterForProperty(objc_property_t property, const char *name)
{
	if (property) {
		char *setterName = property_copyAttributeValue(property, "S");
		if (setterName) {
			SEL setter = sel_getUid(setterName);
			free(setterName);
			if (setter) return setter;
		}
	}

	const char *propertyName = property ? property_getName(property) : name;
	return selectorWithPattern("set", propertyName, ":");
}

static inline SEL prefixedSelector(SEL original) {
	return selectorWithPattern("__", sel_getName(original), NULL);
}

#pragma mark -

typedef struct {
	SEL setter;
	SEL __setter;
	SEL getter;
} _BlockDelegateInfo;

static NSUInteger _BlockDelegateInfoSize(const void *__unused item) {
	return sizeof(_BlockDelegateInfo);
}

static NSString *_BlockDelegateInfoDescribe(const void *__unused item) {
	if (!item) { return nil; }
	const _BlockDelegateInfo *info = item;
	return [NSString stringWithFormat:@"(setter: %s, getter: %s)", sel_getName(info->setter), sel_getName(info->getter)];
}

static inline _DynamicDelegate *getDynamicDelegate(NSObject *delegatingObject, Protocol *protocol, const _BlockDelegateInfo *info, BOOL ensuring) {
	_DynamicDelegate *dynamicDelegate = [delegatingObject bk_dynamicDelegateForProtocol:__protocolForDelegatingObject(delegatingObject, protocol)];

	if (!info || !info->setter || !info->getter) {
		return dynamicDelegate;
	}

	if (!info->__setter && !info->setter) { return dynamicDelegate; }

	id (*getterDispatch)(id, SEL) = (id (*)(id, SEL)) objc_msgSend;
	id originalDelegate = getterDispatch(delegatingObject, info->getter);

	if (__object_isKindOfClass(originalDelegate, _DynamicDelegate.class)) { return dynamicDelegate; }

	void (*setterDispatch)(id, SEL, id) = (void (*)(id, SEL, id)) objc_msgSend;
	setterDispatch(delegatingObject, info->__setter ?: info->setter, dynamicDelegate);

	return dynamicDelegate;
}

typedef _DynamicDelegate *(^A2GetDynamicDelegateBlock)(NSObject *, BOOL);

@interface _DynamicDelegate ()

@property (nonatomic, weak, readwrite) id realDelegate;

@end

#pragma mark -

@implementation NSObject (BlockDelegate)

#pragma mark Helpers

+ (NSMapTable *)delegateInfoByProtocol:(BOOL)createIfNeeded {
	NSMapTable *delegateInfo = objc_getAssociatedObject(self, _cmd);
	if (delegateInfo || !createIfNeeded) { return delegateInfo; }

	NSPointerFunctions *protocols = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsOpaqueMemory|NSPointerFunctionsObjectPointerPersonality];
	NSPointerFunctions *infoStruct = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsMallocMemory|NSPointerFunctionsStructPersonality|NSPointerFunctionsCopyIn];
	infoStruct.sizeFunction = _BlockDelegateInfoSize;
	infoStruct.descriptionFunction = _BlockDelegateInfoDescribe;

	delegateInfo = [[NSMapTable alloc] initWithKeyPointerFunctions:protocols valuePointerFunctions:infoStruct capacity:0];
	objc_setAssociatedObject(self, _cmd, delegateInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	return delegateInfo;
}

+ (const _BlockDelegateInfo *)delegateInfoForProtocol:(Protocol *)protocol {
	_BlockDelegateInfo *infoAsPtr = NULL;
	Class cls = self;
	while ((infoAsPtr == NULL || infoAsPtr->getter == NULL) && cls != nil && cls != NSObject.class) {
		NSMapTable *map = [cls delegateInfoByProtocol:NO];
		infoAsPtr = (__bridge void *)[map objectForKey:protocol];
		cls = [cls superclass];
	}
	NSCAssert(infoAsPtr != NULL, @"Class %@ not assigned dynamic delegate for protocol %@", NSStringFromClass(self), NSStringFromProtocol(protocol));
	return infoAsPtr;
}

#pragma mark Linking block properties

+ (void)linkDataSourceMethods:(NSDictionary *)dictionary
{
	[self linkProtocol:__dataSourceProtocol(self) methods:dictionary];
}

+ (void)linkDelegateMethods:(NSDictionary *)dictionary
{
	[self linkProtocol:__delegateProtocol(self) methods:dictionary];
}

+ (void)linkProtocol:(Protocol *)protocol methods:(NSDictionary *)dictionary
{
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *selectorName, BOOL *stop) {
		const char *name = propertyName.UTF8String;
		objc_property_t property = class_getProperty(self, name);
		NSCAssert(property, @"Property \"%@\" does not exist on class %s", propertyName, class_getName(self));

		char *dynamic = property_copyAttributeValue(property, "D");
		NSCAssert2(dynamic, @"Property \"%@\" on class %s must be backed with \"@dynamic\"", propertyName, class_getName(self));
		free(dynamic);

		char *copy = property_copyAttributeValue(property, "C");
		NSCAssert2(copy, @"Property \"%@\" on class %s must be defined with the \"copy\" attribute", propertyName, class_getName(self));
		free(copy);

		SEL selector = NSSelectorFromString(selectorName);
		SEL getter = getterForProperty(property, name);
		SEL setter = setterForProperty(property, name);

		if (class_respondsToSelector(self, setter) || class_respondsToSelector(self, getter)) { return; }

		const _BlockDelegateInfo *info = [self delegateInfoForProtocol:protocol];

		IMP getterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject) {
			_DynamicDelegate *delegate = getDynamicDelegate(delegatingObject, protocol, info, NO);
			return [delegate blockImplementationForMethod:selector];
		});

		if (!class_addMethod(self, getter, getterImplementation, "@@:")) {
			NSCAssert(NO, @"Could not implement getter for \"%@\" property.", propertyName);
		}

		IMP setterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject, id block) {
			_DynamicDelegate *delegate = getDynamicDelegate(delegatingObject, protocol, info, YES);
			[delegate implementMethod:selector withBlock:block];
		});

		if (!class_addMethod(self, setter, setterImplementation, "v@:@")) {
			NSCAssert(NO, @"Could not implement setter for \"%@\" property.", propertyName);
		}
	}];
}

#pragma mark Dynamic Delegate Replacement

+ (void)registerDynamicDataSource
{
	[self registerDynamicDelegateNamed:@"dataSource" forProtocol:__dataSourceProtocol(self)];
}
+ (void)registerDynamicDelegate
{
	[self registerDynamicDelegateNamed:@"delegate" forProtocol:__delegateProtocol(self)];
}

+ (void)registerDynamicDataSourceNamed:(NSString *)dataSourceName
{
	[self registerDynamicDelegateNamed:dataSourceName forProtocol:__dataSourceProtocol(self)];
}
+ (void)registerDynamicDelegateNamed:(NSString *)delegateName
{
	[self registerDynamicDelegateNamed:delegateName forProtocol:__delegateProtocol(self)];
}

+ (void)registerDynamicDelegateNamed:(NSString *)delegateName forProtocol:(Protocol *)protocol
{
	NSMapTable *propertyMap = [self delegateInfoByProtocol:YES];
	_BlockDelegateInfo *infoAsPtr = (__bridge void *)[propertyMap objectForKey:protocol];
	if (infoAsPtr != NULL) { return; }

	const char *name = delegateName.UTF8String;
	objc_property_t property = class_getProperty(self, name);
	SEL setter = setterForProperty(property, name);
	SEL __setter = prefixedSelector(setter);
	SEL getter = getterForProperty(property, name);

	_BlockDelegateInfo info = {
		setter, __setter, getter
	};

	[propertyMap setObject:(__bridge id)&info forKey:protocol];
	infoAsPtr = (__bridge void *)[propertyMap objectForKey:protocol];

	IMP setterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject, id delegate) {
		_DynamicDelegate *dynamicDelegate = getDynamicDelegate(delegatingObject, protocol, infoAsPtr, YES);
		if ([delegate isEqual:dynamicDelegate]) {
			delegate = nil;
		}
		dynamicDelegate.realDelegate = delegate;
	});

	if (!swizzleWithIMP(self, setter, __setter, setterImplementation, "v@:@", YES)) {
		bzero(infoAsPtr, sizeof(_BlockDelegateInfo));
		return;
	}

	if (![self instancesRespondToSelector:getter]) {
		IMP getterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject) {
			return [delegatingObject bk_dynamicDelegateForProtocol:__protocolForDelegatingObject(delegatingObject, protocol)];
		});

		addMethodWithIMP(self, getter, NULL, getterImplementation, "@@:", NO);
	}
}

- (id)ensuredDynamicDelegate
{
	Protocol *protocol = __delegateProtocol(self.class);
	return [self ensuredDynamicDelegateForProtocol:protocol];
}

- (id)ensuredDynamicDelegateForProtocol:(Protocol *)protocol
{
	const _BlockDelegateInfo *info = [self.class delegateInfoForProtocol:protocol];
	return getDynamicDelegate(self, protocol, info, YES);
}

@end
