#import "_Foundation.h"

@interface _CacheManager : NSObject

@singleton( _CacheManager )

@property (nonatomic, strong, readonly) NSString *rootPath;

// ----------------------------------
// mem cache
// ----------------------------------

@property (nullable, copy) NSString *name;
@property (readonly) NSUInteger totalCount;
@property (readonly) NSUInteger totalCost;


@property NSUInteger countLimit;
/**
 The maximum total cost that the cache can hold before it starts evicting objects.
 
 @discussion The default value is NSUIntegerMax, which means no limit.
 This is not a strict limit—if the cache goes over the limit, some objects in the
 cache could be evicted later in backgound thread.
 */
@property NSUInteger costLimit;

/**
 The maximum expiry time of objects in cache.
 
 @discussion The default value is DBL_MAX, which means no limit.
 This is not a strict limit—if an object goes over the limit, the object could
 be evicted later in backgound thread.
 */
@property NSTimeInterval ageLimit;
/**
 The auto trim check time interval in seconds. Default is 5.0.
 
 @discussion The cache holds an internal timer to check whether the cache reaches
 its limits, and if the limit is reached, it begins to evict objects.
 */
@property NSTimeInterval autoTrimInterval;
@property BOOL shouldRemoveAllObjectsOnMemoryWarning;
@property BOOL shouldRemoveAllObjectsWhenEnteringBackground;

// ----------------------------------
// disk cache
// ----------------------------------

@property (nonatomic, assign, readonly) NSUInteger diskByteCount;

@end
