
#import "NSArray+Extension.h"
#import "NSObject+Extension.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSArray (Extension)

- (NSArray *)head:(NSUInteger)count {
	if ( 0 == self.count || 0 == count ) {
		return nil;
	}
	
	if ( self.count < count ) {
		return self;
	}

	NSRange range;
	range.location = 0;
	range.length = count;

	return [self subarrayWithRange:range];
}

- (NSArray *)tail:(NSUInteger)count {
	if ( 0 == self.count || 0 == count ) {
		return nil;
	}
	
	if ( self.count < count ) {
		return self;
	}

	NSRange range;
	range.location = self.count - count;
	range.length = count;

	return [self subarrayWithRange:range];
}

- (NSString *)join {
	return [self join:nil];
}

- (NSString *)join:(NSString *)delimiter {
	if ( 0 == self.count ) {
		return @"";
	} else if ( 1 == self.count ) {
		return [[self objectAtIndex:0] description];
	} else {
		NSMutableString * result = [NSMutableString string];
		
		for ( NSUInteger i = 0; i < self.count; ++i ) {
			[result appendString:[[self objectAtIndex:i] description]];
			
			if ( delimiter ) {
				if ( i + 1 < self.count ) {
					[result appendString:delimiter];
				}
			}
		}
		
		return result;
	}
}

#pragma mark - 

- (BOOL)containsString:(NSString *)aString {
    __block BOOL contained = NO;
    
    [self enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            // 如果有非String对象，返回
            *stop = YES;
        }
        
        if ([obj isEqualToString:aString]) {
            contained = YES;
            *stop = YES;
        }
    }];
    
    return contained;
}

- (NSArray *)filteredArrayWhereProperty:(NSString *)property equals:(id)value {
    NSParameterAssert(property); NSParameterAssert(value);
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", property, value];
    return [self filteredArrayUsingPredicate:filter];
}

@end

#pragma mark - Computation

@implementation NSArray ( Computation )

- (void)each:(void (^)(id _Nonnull))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (NSArray *)map:(id  _Nonnull (^)(id _Nonnull))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: [self count]];
    for(id obj in self)
        [array addObject: block(obj)];
    return array;
}

- (NSArray *)select:(BOOL (^)(id _Nonnull))block {
    NSMutableArray *array = [NSMutableArray array];
    for(id obj in self)
        if(block(obj))
            [array addObject: obj];
    return array;
}

- (id)match: (BOOL (^)(id obj))block {
    for(id obj in self)
        if(block(obj))
            return obj;
    return nil;
}

- (id)reduce:(id)initial withBlock:(id (^)(id sum, id obj))block {
    NSParameterAssert(block != nil);
    
    __block id result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}

@end

@implementation NSArray(Primitive)

- (NSNumber *)_numberAtIndex:(NSUInteger)index {
    if(index >= self.count) {
        NSLog(@"index '%lu' out of bounds, array size %lu.", (unsigned long)index, (unsigned long)self.count);
    }
    NSNumber* n = self[index];
    return n;
}

- (NSValue*)_valueAtIndex:(NSUInteger)index {
    if(index >= self.count) {
        NSLog(@"index '%lu' out of bounds, array size %lu.", (unsigned long)index, (unsigned long)self.count);
    }
    NSValue* n = self[index];
    return n;
}

- (BOOL)boolAtIndex:(NSUInteger)index {
    NSNumber* n = [self _numberAtIndex:index];
    BOOL b = [n boolValue];
    return b;
}

- (char)charAtIndex:(NSUInteger)index {
    NSNumber* n = [self _numberAtIndex:index];
    char c = [n charValue];
    return c;
}

- (int)intAtIndex:(NSUInteger)index {
    NSNumber* n = [self _numberAtIndex:index];
    int i = [n intValue];
    return i;
}

- (NSInteger)integerAtIndex:(NSUInteger)index {
    NSNumber* n = [self _numberAtIndex:index];
    NSInteger i = [n integerValue];
    return i;
}

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index {
    NSNumber* n = [self _numberAtIndex:index];
    NSUInteger i = [n unsignedIntegerValue];
    return i;
}

- (CGFloat)cgFloatAtIndex:(NSUInteger)index {
    NSNumber* n = [self _numberAtIndex:index];
    int i = [n doubleValue];
    return i;
}

- (float)floatAtIndex:(NSUInteger)index {
    NSNumber* n = [self _numberAtIndex:index];
    float i = [n floatValue];
    return i;
}

- (NSValue*)valueAtIndex:(NSUInteger)index {
    return [self _valueAtIndex:index];
}

- (CGPoint)pointAtIndex:(NSUInteger)index {
    return [[self _valueAtIndex:index] CGPointValue];
}

- (CGSize)sizeAtIndex:(NSUInteger)index {
    return [[self _valueAtIndex:index] CGSizeValue];
}

- (CGRect)rectAtIndex:(NSUInteger)index {
    return [[self _valueAtIndex:index] CGRectValue];
}

- (NSString *)intArrayToString {
    NSMutableString* s = [NSMutableString stringWithCapacity:self.count];
    for (NSNumber* n in self) {
        int i = [n intValue];
        [s appendFormat:@"%d ", i];
    }
    return s;
}

@end

@implementation NSMutableArray(Primitive)

- (void)addBool:(BOOL)b {
    [self addObject:@(b)];
}

- (void)insertBool:(BOOL)b atIndex:(NSUInteger)index {
    [self insertObject:@(b) atIndex:index];
}

- (void)replaceBoolAtIndex:(NSUInteger)index withBool:(BOOL)b {
    self[index] = @(b);
}

- (void)addChar:(char)c {
    [self addObject:@(c)];
}

- (void)insertChar:(char)c atIndex:(NSUInteger)index {
    [self insertObject:@(c) atIndex:index];
}

- (void)replaceCharAtIndex:(NSUInteger)index withChar:(char)c {
    self[index] = @(c);
}

- (void)addInt:(int)i {
    [self addObject:@(i)];
}

- (void)insertInt:(int)i atIndex:(NSUInteger)index {
    [self insertObject:@(i) atIndex:index];
}

- (void)replaceIntAtIndex:(NSUInteger)index withInt:(int)i {
    self[index] = @(i);
}

- (void)addInteger:(NSInteger)i {
    [self addObject:@(i)];
}

- (void)insertInteger:(NSInteger)i atIndex:(NSUInteger)index {
    [self insertObject:@(i) atIndex:index];
}

- (void)replaceIntegerAtIndex:(NSUInteger)index withInteger:(NSInteger)i {
    self[index] = @(i);
}

- (void)addUnsignedInteger:(NSInteger)i {
    [self addObject:@(i)];
}

- (void)insertUnsignedInteger:(NSInteger)i atIndex:(NSUInteger)index {
    [self insertObject:@(i) atIndex:index];
}

- (void)replaceUnsignedIntegerAtIndex:(NSUInteger)index withUnsignedInteger:(NSInteger)i {
    self[index] = @(i);
}

- (void)addCGFloat:(CGFloat)f {
    [self addObject:@(f)];
}

- (void)insertCGFloat:(CGFloat)f atIndex:(NSUInteger)index {
    [self insertObject:@(f) atIndex:index];
}

- (void)replaceCGFloatAtIndex:(NSUInteger)index withCGFloat:(CGFloat)f {
    self[index] = @(f);
}

- (void)addFloat:(float)f {
    [self addObject:@(f)];
}

- (void)insertFloat:(float)f atIndex:(NSUInteger)index {
    [self insertObject:@(f) atIndex:index];
}

- (void)replaceFloatAtIndex:(NSUInteger)index withFloat:(float)f {
    self[index] = @(f);
}

- (void)addValue:(NSValue*)o {
    [self addObject:o];
}

- (void)insertValue:(NSValue*)o atIndex:(NSUInteger)index {
    [self insertObject:o atIndex:index];
}

- (void)replaceValueAtIndex:(NSUInteger)index withValue:(NSValue*)o {
    self[index] = o;
}

- (void)addPoint:(CGPoint)o {
    [self addObject:[NSValue valueWithCGPoint:o]];
}

- (void)insertPoint:(CGPoint)o atIndex:(NSUInteger)index{
    [self insertObject:[NSValue valueWithCGPoint:o] atIndex:index];
}

- (void)replacePointAtIndex:(NSUInteger)index withPoint:(CGPoint)o {
    self[index] = [NSValue valueWithCGPoint:o];
}

- (void)addSize:(CGSize)o {
    [self addObject:[NSValue valueWithCGSize:o]];
}

- (void)insertSize:(CGSize)o atIndex:(NSUInteger)index{
    [self insertObject:[NSValue valueWithCGSize:o] atIndex:index];
}

- (void)replaceSizeAtIndex:(NSUInteger)index withSize:(CGSize)o {
    self[index] = [NSValue valueWithCGSize:o];
}

- (void)addRect:(CGRect)o {
    [self addObject:[NSValue valueWithCGRect:o]];
}

- (void)insertRect:(CGRect)o atIndex:(NSUInteger)index{
    [self insertObject:[NSValue valueWithCGRect:o] atIndex:index];
}

- (void)replaceRectAtIndex:(NSUInteger)index withRect:(CGRect)o {
    self[index] = [NSValue valueWithCGRect:o];
}

- (void)swapIndex1:(NSUInteger)index1 index2:(NSUInteger)index2 {
    NSNumber* n1 = self[index1];
    NSNumber* n2 = self[index2];
    self[index1] = n2;
    self[index2] = n1;
}

@end
