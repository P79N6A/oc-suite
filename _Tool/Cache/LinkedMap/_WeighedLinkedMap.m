//
//  _WeighedLinkedMap.m
//  _Tool
//
//  Created by 7 on 2018/9/13.
//

#import "_WeighedLinkedMap.h"
#import "_LinkedMap+Private.h"

@implementation _WeighedLinkedMap

// MARK: - Private methods

- (void)_insertNodeAtHead:(id)n {
    // 直接插入minor队列
    if (!_hook) {
        [self _insertNode:n after:_tail];
    } else {
        [self _insertNode:n before:_hook];
    }
    
    _hook = n;
}

- (void)_bringNodeToHead:(id)n withCost:(NSUInteger)cost {
    _WeighedLinkedMapNode *node = n;
    
    _totalCost -= node->_cost;
    _totalCost += cost;
    
    if (node->_hits > 2) {
        _WeighedLinkedMapNode *prev = (_WeighedLinkedMapNode *)node->_prev;
        _WeighedLinkedMapNode *next = (_WeighedLinkedMapNode *)node->_next;
        
        node = [self _breakNode:node];
        
        while (prev) {
            if (node->_hits < prev->_hits) {
                break;
            }
            
            prev = (_WeighedLinkedMapNode *)prev->_prev;
        }
        
        if (!prev) {
            [self _insertNode:node before:next];
        } else {
            [self _insertNode:node after:prev];
        }
    } else if (node->_hits > 1) {
        _WeighedLinkedMapNode *prev = (_WeighedLinkedMapNode *)_hook->_prev;
        _WeighedLinkedMapNode *next = (_WeighedLinkedMapNode *)_hook;
        
        node = [self _breakNode:node];
        
        while (prev) {
            if (2 < prev->_hits) {
                break;
            }
            
            prev = (_WeighedLinkedMapNode *)prev->_prev;
        }
        
        // 从 minor 到 major
        if (!prev) {
            [self _insertNode:node before:next];
        } else {
            [self _insertNode:node after:prev];
        }
    } else {
        // 应该都是大于1的，不存在这个分支
    }
}

// MARK: - _LinkedMapProtocol

- (id)objectForKey:(NSString *)key {
    _WeighedLinkedMapNode *node = [self _nodeForKey:key];
    
    node->_hits += 1;
    
    return node->_value;
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost {
    NSTimeInterval now = CACurrentMediaTime();
    
    _WeighedLinkedMapNode *node = [self _nodeForKey:key];
    
    if (node) {
        node->_hits += 1;
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        
        [self _bringNodeToHead:node withCost:cost];
    } else {
        node = [_WeighedLinkedMapNode instance];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        
        [self _insertNodeAtHead:node];
    }
}

@end

@implementation _WeighedLinkedMapNode

+ (instancetype)instance {
    _WeighedLinkedMapNode *node = [super instance];
    node->_hits = 1;
    return node;
}

@end
