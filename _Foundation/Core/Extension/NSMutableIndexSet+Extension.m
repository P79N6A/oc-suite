#import "NSMutableIndexSet+Extension.h"

@implementation NSMutableIndexSet (Extension)

- (void)performSelect:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return !block(idx);
	}];

	if (!list.count) return;
	[self removeIndexes:list];
}

- (void)performReject:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);
	return [self performSelect:^BOOL(NSUInteger idx) {
		return !block(idx);
	}];
}

- (void)performMap:(NSUInteger (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSMutableIndexSet *new = [self mutableCopy];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[new addIndex:block(idx)];
	}];

	[self removeAllIndexes];
	[self addIndexes:new];
}

@end
