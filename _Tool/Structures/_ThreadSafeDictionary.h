#import <Foundation/Foundation.h>

// MARK: - _SerialQueuedDictionary

@interface _SerialQueuedDictionary : NSObject

// For supscript
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

- (NSDictionary *)toNSDictionary;

- (void)removeObjectForkey:(NSString *)key;

- (void)removeAllObjects;

@end

// MARK: - _MutexDictionary

@interface _MutexDictionary : NSObject

#pragma mark - Init
+ (instancetype)dictionary;
+ (instancetype)dictionaryWithCapacity:(NSUInteger)num;
+ (instancetype)dictionaryWithDictionary:(NSDictionary *)otherDictionary;
+ (instancetype)dictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey;

#pragma mark - Add
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey;
- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary;

#pragma mark - Remove
- (void)removeObjectForKey:(id)aKey;
- (void)removeAllObjects;

#pragma mark - Query
- (NSUInteger)count;
- (nullable id)objectForKeyedSubscript:(id)key;
- (nullable id)objectForKey:(id)aKey;

#pragma mark - Enumerate
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;

@end
