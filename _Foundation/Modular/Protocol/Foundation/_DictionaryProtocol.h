//
//  _DictionaryProtocol.h
//  _Foundation
//
//  Created by 7 on 2018/9/13.
//

#import <Foundation/Foundation.h>
#import "_DictionarySubscriptProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol _DictionaryProtocol <_DictionarySubscriptProtocol>

- (nullable id)objectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (void)removeObjectForKey:(id)aKey;
- (void)removeObjectsForKeys:(NSArray<id> *)keyArray;
- (void)removeAllObjects;

//- (void)setObject:(nullable id)obj forKeyedSubscript:(id <NSCopying>)key;
//- (nullable ObjectType)objectForKeyedSubscript:(id)key;

//- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block;

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj))block;

@end

NS_ASSUME_NONNULL_END
