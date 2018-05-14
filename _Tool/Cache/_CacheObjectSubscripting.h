//
//  _cache_object_subscripting.h
//  consumer
//
//  Created by fallen.ink on 6/21/16.
//
//  inspried by PINCache:https://github.com/pinterest/PINCache

#import <Foundation/Foundation.h>

@protocol CacheObjectSubscripting <NSObject>

@required

/**
 This method enables using literals on the receiving object, such as `id object = cache[@"key"];`.
 
 @param key The key associated with the object.
 @result The object for the specified key.
 */
- (id)objectForKeyedSubscript:(NSString *)key;

/**
 This method enables using literals on the receiving object, such as `cache[@"key"] = object;`.
 
 @param obj An object to be assigned for the key.
 @param key A key to associate with the object. This string will be copied.
 */
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;

@end
