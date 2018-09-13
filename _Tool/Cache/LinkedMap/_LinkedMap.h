#import <Foundation/Foundation.h>
#import "_DictionaryProtocol.h"

@class _LinkedMapNode;

/**
 A linked map used by YYMemoryCache.
 It's not thread-safe and does not validate the parameters.
 
 Typically, you should not use this class directly.
 */
@interface _LinkedMap : NSObject <_DictionaryProtocol> {
    @package
    CFMutableDictionaryRef _dic; // do not set object directly
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    _LinkedMapNode *_head; // MRU, do not change it directly
    _LinkedMapNode*_tail; // LRU, do not change it directly
}

@property (atomic, strong) void (^ enumerationHandler)(id key, id obj);

- (void)insertNodeAtHead:(_LinkedMapNode *)node;
- (void)bringNodeToHead:(_LinkedMapNode *)node;
- (void)removeNode:(_LinkedMapNode *)node;
- (_LinkedMapNode *)removeTailNode;
- (void)removeAll;

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
@end
