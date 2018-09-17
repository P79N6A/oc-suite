//
//  _LinkedMap+Private.h
//  _Tool
//
//  Created by 7 on 2018/9/17.
//

#ifndef _LinkedMap_Private_h
#define _LinkedMap_Private_h

@interface _LinkedMap ()

// 请保证 _LinkedMap 统计状态更改，保留在以下方法内
- (id)_nodeForKey:(NSString *)key;
- (id)_breakNode:(id)n;
- (void)_insertNodeAtHead:(id)n;
- (void)_insertNode:(id)n before:(id)h;
- (void)_insertNode:(id)n after:(id)t;
- (void)_bringNodeToHead:(id)n withCost:(NSUInteger)cost;
- (void)_removeNode:(id)n;
- (id)_removeTailNode;
- (void)_removeAll;

@end

#endif /* _LinkedMap_Private_h */
