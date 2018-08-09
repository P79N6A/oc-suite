#import "NSObject+DynamicDelegate.h"
#import <objc/runtime.h>
#import "_DynamicDelegate.h"

extern Protocol *__dataSourceProtocol(Class cls);
extern Protocol *__delegateProtocol(Class cls);

static Class __dynamicDelegateClass(Class cls, NSString *suffix)
{
	while (cls) {
		NSString *className = [NSString stringWithFormat:@"A2Dynamic%@%@", NSStringFromClass(cls), suffix];
		Class ddClass = NSClassFromString(className);
		if (ddClass) return ddClass;

		cls = class_getSuperclass(cls);
	}

	return [_DynamicDelegate class];
}

static dispatch_queue_t __backgroundQueue(void)
{
	static dispatch_once_t onceToken;
	static dispatch_queue_t backgroundQueue = nil;
	dispatch_once(&onceToken, ^{
		backgroundQueue = dispatch_queue_create("BlocksKit.DynamicDelegate.Queue", DISPATCH_QUEUE_SERIAL);
	});
	return backgroundQueue;
}

@implementation NSObject (DynamicDelegate)

- (id)bk_dynamicDataSource
{
	Protocol *protocol = __dataSourceProtocol([self class]);
	Class class = __dynamicDelegateClass([self class], @"DataSource");
	return [self bk_dynamicDelegateWithClass:class forProtocol:protocol];
}
- (id)bk_dynamicDelegate
{
	Protocol *protocol = __delegateProtocol([self class]);
	Class class = __dynamicDelegateClass([self class], @"Delegate");
	return [self bk_dynamicDelegateWithClass:class forProtocol:protocol];
}
- (id)bk_dynamicDelegateForProtocol:(Protocol *)protocol
{
	Class class = [_DynamicDelegate class];
	NSString *protocolName = NSStringFromProtocol(protocol);
	if ([protocolName hasSuffix:@"Delegate"]) {
		class = __dynamicDelegateClass([self class], @"Delegate");
	} else if ([protocolName hasSuffix:@"DataSource"]) {
		class = __dynamicDelegateClass([self class], @"DataSource");
	}

	return [self bk_dynamicDelegateWithClass:class forProtocol:protocol];
}
- (id)bk_dynamicDelegateWithClass:(Class)cls forProtocol:(Protocol *)protocol
{
	/**
	 * Storing the dynamic delegate as an associated object of the delegating
	 * object not only allows us to later retrieve the delegate, but it also
	 * creates a strong relationship to the delegate. Since delegates are weak
	 * references on the part of the delegating object, a dynamic delegate
	 * would be deallocated immediately after its declaring scope ends.
	 * Therefore, this strong relationship is required to ensure that the
	 * delegate's lifetime is at least as long as that of the delegating object.
	 **/

	__block _DynamicDelegate *dynamicDelegate;

	dispatch_sync(__backgroundQueue(), ^{
		dynamicDelegate = objc_getAssociatedObject(self, (__bridge const void *)protocol);

		if (!dynamicDelegate)
		{
			dynamicDelegate = [[cls alloc] initWithProtocol:protocol];
			objc_setAssociatedObject(self, (__bridge const void *)protocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
	});

	return dynamicDelegate;
}

@end
