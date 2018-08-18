//
//  _net_http_url_protocol.h
//  consumer
//
//  Created by fallen.ink on 9/25/16.
//
//

#import "_net_cache.h"

@interface _net_http_url_protocol : NSURLProtocol <_NetCacheRequestDelegate> {
    NSURLRequest *m_request;
}

@property (nonatomic, copy) NSURLRequest *request; // same as NSURLProtocol


@end
