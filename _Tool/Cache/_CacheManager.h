//
//  _cache_manager.h
//  consumer
//
//  Created by fallen.ink on 6/20/16.
//
//

#import "_greats.h"

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
