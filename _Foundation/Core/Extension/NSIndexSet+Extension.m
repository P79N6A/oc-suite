#import "NSIndexSet+Extension.h"

@implementation NSIndexSet (Extension)

- (void)each:(void (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (void)apply:(void (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	[self enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (NSUInteger)match:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	return [self indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return block(idx);
	}];
}

- (NSIndexSet *)select:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return block(idx);
	}];

	return list;
}

- (NSIndexSet *)reject:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);
	return [self select:^BOOL(NSUInteger idx) {
		return !block(idx);
	}];
}

- (NSIndexSet *)map:(NSUInteger (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSMutableIndexSet *list = [NSMutableIndexSet indexSet];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[list addIndex:block(idx)];
	}];

	return list;
}

- (NSArray *)mapIndex:(id (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		id value = block(idx) ?: [NSNull null];
		[result addObject:value];
	}];

	return result;
}

- (BOOL)any:(BOOL (^)(NSUInteger index))block {
	return [self match:block] != NSNotFound;
}

- (BOOL)none:(BOOL (^)(NSUInteger index))block {
	return [self match:block] == NSNotFound;
}

- (BOOL)all:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	__block BOOL result = YES;

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		if (!block(idx)) {
			result = NO;
			*stop = YES;
		}
	}];

	return result;
}

@end
