//
//  _net_url_cache.h
//  consumer
//
//  Created by fallen.ink on 9/15/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  继承NSURLCache实现Cache的好处：
 *  1. 沿用 NSURLRequestCachePolicy 的缓存策略
 
 *  坏处：
 *  1. 依赖系统api
 */

@interface _NetUrlCache : NSURLCache

@end
