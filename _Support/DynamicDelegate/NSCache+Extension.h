
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** NSCache with block adding of objects
 */

@interface NSCache (Extension)

/** Returns the value associated with a given key. If there is no
 object for that key, it uses the result of the block, saves
 that to the cache, and returns it.

 This mimics the cache behavior of Ruby on Rails.  The following code:

	 @products = Rails.cache.fetch('products') do
	   Product.all
	 end

 becomes:

	 NSMutableArray *products = [cache objectForKey:@"products" withGetter:^id{
	   return [Product all];
	 }];

 @return The value associated with *key*, or the object returned
 by the block if no value is associated with *key*.
 @param key An object identifying the value.
 @param getterBlock A block used to get an object if there is no
 value in the cache.
 */
- (id)objectForKey:(id)key withGetter:(id (^)(void))getterBlock;

/** Called when an object is about to be evicted from the cache.
 */
@property (nonatomic, copy, setter = setWillEvictBlock:, nullable) void (^willEvictBlock)(NSCache *cache, id obj);

@end

NS_ASSUME_NONNULL_END
