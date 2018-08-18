//
//  _net_cache_request_configuration.h
//  consumer
//
//  Created by fallen.ink on 9/21/16.
//
//

#import <Foundation/Foundation.h>

@interface _NetCacheRequestConfiguration : NSObject

@property (nonatomic, assign) int options;
@property (nonatomic, strong) id userData;
@property (nonatomic, strong) NSURLRequest *request;

@end
