//
//  _LinkedMapProtocol.h
//  _Tool
//
//  Created by 7 on 2018/9/17.
//

#import <Foundation/Foundation.h>

@protocol _LinkedMapProtocol <NSObject>

- (nullable id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost;

- (id)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;
- (id)removeObject;

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj))block;

- (BOOL)isObjectCountsOverflow:(NSUInteger)limit;
- (BOOL)isObjectCostsOverflow:(NSUInteger)limit;

@end
