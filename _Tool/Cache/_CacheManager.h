#import "_Foundation.h"

@interface _CacheManager : NSObject

@singleton( _CacheManager )

@property (nonatomic, strong, readonly) NSString *rootPath;

// ----------------------------------
// mem cache
// ----------------------------------


// ----------------------------------
// disk cache
// ----------------------------------

@property (nonatomic, assign, readonly) NSUInteger diskByteCount;

@end
