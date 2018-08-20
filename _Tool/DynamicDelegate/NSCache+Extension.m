#import "NSCache+Extension.h"
#import "_DynamicDelegate.h"
#import "NSObject+DynamicDelegate.h"
#import "NSObject+BlockDelegate.h"

#pragma mark Custom delegate

@interface _DynamicNSCacheDelegate : _DynamicDelegate <NSCacheDelegate>

@end

@implementation _DynamicNSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(cache:willEvictObject:)])
		[realDelegate cache:cache willEvictObject:obj];

	void (^orig)(NSCache *, id) = [self blockImplementationForMethod:_cmd];
	if (orig) orig(cache, obj);
}

@end

#pragma mark Category

@implementation NSCache (Extension)

@dynamic willEvictBlock;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegate];
		[self linkDelegateMethods:@{ @"willEvictBlock": @"cache:willEvictObject:" }];
	}
}

#pragma mark Methods

- (id)objectForKey:(id)key withGetter:(id (^)(void))block {
	id object = [self objectForKey:key];
	if (object) return object;

	if (block) {
		object = block();
		[self setObject:object forKey:key];
	}

	return object;
}

@end
