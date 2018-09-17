
#import <pthread.h>
#import "_LinkedMap.h"
#import "_LinkedMap+Private.h"

@implementation _LinkedMapNode

+ (instancetype)instance {
    _LinkedMapNode *node = [_LinkedMapNode new];
    node->_cost = 0;
    node->_value = nil;
    node->_key = nil;
    node->_time = 0;
    return node;
}

@end

@implementation _LinkedMap

// MARK: - Life cycle

- (instancetype)init {
    self = [super init];
    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return self;
}

- (void)dealloc {
    CFRelease(_dic);
}

// MARK: - Private

- (_LinkedMapNode *)_nodeForKey:(NSString *)key {
    _LinkedMapNode *node = CFDictionaryGetValue(_dic, (__bridge const void *)(key));
    
    if (node) {
        node->_time = CACurrentMediaTime();
        [self _bringNodeToHead:node withCost:node->_cost];
    }
    
    return node;
}

- (id)_breakNode:(id)n {
    _LinkedMapNode *node = n;
    
    if (node == _tail) {
        _tail = node->_prev;
        _tail->_next = nil;
        
        return node;
    }
    
    if (node == _head) {
        _head = node->_next;
        _head->_prev = nil;
        
        return node;
    }
    
    _LinkedMapNode *prev = node->_prev;
    _LinkedMapNode *next = node->_next;
    
    
    next->_prev = prev;
    prev->_next = next;
    
    return node;
}

- (void)_insertNodeAtHead:(id)node {
    [self _insertNode:node before:_head];
}

- (void)_insertNode:(id)n before:(id)h {
    _LinkedMapNode *node = n;
    _LinkedMapNode *head = h;
    
    CFDictionarySetValue(_dic, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    
    _totalCost += node->_cost;
    _totalCount++;
    
    
    // 如果它是空，则认为链表为空
    if (!head) {
        _head = _tail = node;
        
        return;
    }
    
    node->_prev = head->_prev;
    node->_next = head;
    
    head->_prev = node;
    head->_next = _head->_next;
    
    // 如果它是最前
    if (head == _head) {
        _head = node;
    }
}

- (void)_insertNode:(id)n after:(id)t {
    _LinkedMapNode *node = n;
    _LinkedMapNode *tail = t;
    
    CFDictionarySetValue(_dic, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    
    _totalCost += node->_cost;
    _totalCount++;
    
    
    // 如果它是空，则认为链表为空
    if (!tail) {
        _head = _tail = node;
        
        return;
    }
    
    node->_prev = tail;
    node->_next = tail->_next;
    
    if (tail->_next) {
        _LinkedMapNode *next = tail->_next;
        
        next->_prev = node;
    }
    tail->_next = node;
    
    // 如果它是最后
    if (tail == _tail) {
        _tail = node;
    }
}

- (void)_bringNodeToHead:(_LinkedMapNode *)node withCost:(NSUInteger)cost {
    _totalCost -= node->_cost;
    _totalCost += cost;
    
    if (_head == node) return;
    
    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

- (void)_removeNode:(_LinkedMapNode *)node {
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(node->_key));
    _totalCost -= node->_cost;
    _totalCount--;
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (_LinkedMapNode *)_removeTailNode {
    if (!_tail) return nil;
    _LinkedMapNode *tail = _tail;
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(_tail->_key));
    _totalCost -= _tail->_cost;
    _totalCount--;
    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return tail;
}

- (void)_removeAll {
    _totalCost = 0;
    _totalCount = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_dic) > 0) {
        CFMutableDictionaryRef holder = _dic;
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        CFRelease(holder);
    }
}

// MARK: - _LinkedMapProtocol

static void dictionaryApplyFunction (const void *key, const void *value, void *context) {
    _LinkedMap *me = (__bridge _LinkedMap *)context;
    
    NSString *keyString = (__bridge NSString *)key;
    _LinkedMapNode *node = (__bridge _LinkedMapNode *)value;
    
    if (me.enumerationHandler) me.enumerationHandler(keyString, node->_value);
    
    return;
}

- (id)objectForKey:(NSString *)key {
    _LinkedMapNode *node = [self _nodeForKey:key];
    
    return node->_value;
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost {
    NSTimeInterval now = CACurrentMediaTime();
    
    _LinkedMapNode *node = [self _nodeForKey:key];
    
    if (node) {
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        [self _bringNodeToHead:node withCost:cost];
    } else {
        node = [_LinkedMapNode instance];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [self _insertNodeAtHead:node];
    }
}

- (id)removeObjectForKey:(NSString *)key {
    _LinkedMapNode *node = [self _nodeForKey:key];
    
    [self _removeNode:node];
    
    return node->_value;
}

- (void)removeAllObjects {
    [self _removeAll];
}

- (id)removeObject {
    _LinkedMapNode *node = [self _removeTailNode];
    
    return node->_value;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj))block {
    self.enumerationHandler = block;
    
    CFDictionaryApplyFunction(
                              _dic,
                              dictionaryApplyFunction
                              , (__bridge void *)self);
    
    self.enumerationHandler = nil;
}

- (BOOL)isObjectCountsOverflow:(NSUInteger)limit {
    return self->_totalCount > limit;
}

- (BOOL)isObjectCostsOverflow:(NSUInteger)limit {
    return self->_totalCost > limit;
}

@end
