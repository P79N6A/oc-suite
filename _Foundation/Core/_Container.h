
#import <Foundation/Foundation.h>

// ----------------------------------
// Methods like safeXXXX, return nil when XXX isn't the target type.
// ----------------------------------

// ----------------------------------
// MARK: NSObject SafeValueWithJSON
// ----------------------------------

@interface NSObject ( SafeValueWithJSON )

- (id)safeValueFromJSON;
- (id)safeObjectWithClass:(Class)aClass;

- (NSString *)safeString;
- (NSNumber *)safeNumber;
- (NSArray *)safeArray;
- (NSDictionary *)safeDictionary;
- (NSDate *)safeDate;

@end

// ----------------------------------
// MARK: NSArray SafeValue
// ----------------------------------

@interface NSArray ( SafeValue )

- (id)safeObjectAtIndex:(NSUInteger)index;
- (id)safeSubarrayWithRange:(NSRange)range;
- (id)safeSubarrayFromIndex:(NSUInteger)index;
- (id)safeSubarrayWithCount:(NSUInteger)count;

- (NSString *)safeStringAtIndex:(NSUInteger)index;
- (NSNumber *)safeNumberAtIndex:(NSUInteger)index;
- (NSArray *)safeArrayAtIndex:(NSUInteger)index;
- (NSDictionary *)safeDictionaryAtIndex:(NSUInteger)index;

@end

@interface NSArray ( SafeInvoke )

- (id)objectAtIndexIfIndexInBounds:(NSUInteger)index;

@end

// ----------------------------------
// MARK: NSDictionary SafeValue
// ----------------------------------

@interface NSDictionary ( SafeValue )

- (NSString *)safeStringForKey:(id)key;
- (NSNumber *)safeNumberForKey:(id)key;
- (NSArray *)safeArrayForKey:(id)key;
- (NSDictionary *)safeDictionaryForKey:(id)key;

@end

#pragma mark - NSMutableDictionary 

@interface NSMutableDictionary ( SafeValue )

- (void)safeSetObject:(id)object forKey:(id)key;

- (NSMutableDictionary *)safeAppendObject:(id)object forKey:(id)key;

@end

