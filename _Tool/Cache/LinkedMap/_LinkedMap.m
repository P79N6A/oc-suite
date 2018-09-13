
#import <pthread.h>
#import "_LinkedMap.h"

@implementation _LinkedMapNode
@end

@implementation _LinkedMap

- (instancetype)init {
    self = [super init];
    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return self;
}

- (void)dealloc {
    CFRelease(_dic);
}

- (void)insertNodeAtHead:(_LinkedMapNode *)node {
    CFDictionarySetValue(_dic, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    _totalCost += node->_cost;
    _totalCount++;
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)bringNodeToHead:(_LinkedMapNode *)node {
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

- (void)removeNode:(_LinkedMapNode *)node {
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(node->_key));
    _totalCost -= node->_cost;
    _totalCount--;
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (_LinkedMapNode *)removeTailNode {
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

- (void)removeAll {
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

// MARK: - _DictionaryProtocol

static void dictionaryApplyFunction (const void *key, const void *value, void *context) {
    _LinkedMap *me = (__bridge _LinkedMap *)context;
    
    NSString *keyString = (__bridge NSString *)key;
    _LinkedMapNode *node = (__bridge _LinkedMapNode *)value;
    
    if (me.enumerationHandler) me.enumerationHandler(keyString, node->_value);
    
    return;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj))block {
    self.enumerationHandler = block;
    
    CFDictionaryApplyFunction(
                              _dic,
                              dictionaryApplyFunction
                              , (__bridge void *)self);
    
    self.enumerationHandler = nil;
}

// MARK: - _DictionarySubscriptProtocol

- (id)objectForKeyedSubscript:(NSString *)key {
    _LinkedMapNode *node = CFDictionaryGetValue(_dic, (__bridge const void *)(key));
    
    if (node) {
        node->_time = CACurrentMediaTime();
        [self bringNodeToHead:node];
    }
    
    return node;
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    NSTimeInterval now = CACurrentMediaTime();
    
    _LinkedMapNode *node = self[key];
    
    if (node) {
        self->_totalCost -= node->_cost;
        self->_totalCost += 0;
        node->_cost = 0;
        node->_time = now;
        node->_value = obj;
        [self bringNodeToHead:node];
    } else {
        node = [_LinkedMapNode new];
        node->_cost = 0;
        node->_time = now;
        node->_key = key;
        node->_value = obj;
        [self insertNodeAtHead:node];
    }
}

@end
