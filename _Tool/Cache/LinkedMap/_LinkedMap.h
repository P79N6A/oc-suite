#import <Foundation/Foundation.h>
#import "_LinkedMapProtocol.h"

@class _LinkedMapNode;

/**
 * 非线程安全、无参数检查、字典、双向链表
 * LRU 是用双向链表配合 NSDictionary 实现的，增、删、改、查、清空的时间复杂度都是 O(1)
 */
@interface _LinkedMap : NSObject <_LinkedMapProtocol> {
    @package
    CFMutableDictionaryRef _dic; // do not set object directly
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    _LinkedMapNode *_head; // MRU, do not change it directly
    _LinkedMapNode *_tail; // LRU, do not change it directly
}

@property (atomic, strong) void (^ enumerationHandler)(id key, id obj);

// MARK: - _LinkedMapProtocol

- (nullable id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost;

- (id)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;
- (id)removeObject;

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj))block;

- (BOOL)isObjectCountsOverflow:(NSUInteger)limit;
- (BOOL)isObjectCostsOverflow:(NSUInteger)limit;

@end

@interface _LinkedMapNode : NSObject {
    @package
    __unsafe_unretained _LinkedMapNode *_prev; // retained by dic
    __unsafe_unretained _LinkedMapNode *_next; // retained by dic
    id _key;
    id _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}

+ (instancetype)instance;

@end
