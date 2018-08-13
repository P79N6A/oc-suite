//
//  _net_http_url_protocol.m
//  consumer
//
//  Created by fallen.ink on 9/25/16.
//
//

#import "_net_http_url_protocol.h"

@implementation _net_http_url_protocol

@synthesize request = m_request;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [[[request URL] scheme] isEqualToString:@"http"] &&
    [request valueForHTTPHeaderField:AFCachingURLHeader] == nil &&
    [request valueForHTTPHeaderField:AFCacheInternalRequestHeader] == nil;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (id)initWithRequest:(NSURLRequest *)aRequest
       cachedResponse:(NSCachedURLResponse *)cachedResponse
               client:(id <NSURLProtocolClient>)client {
    // Modify request so we don't loop
    NSMutableURLRequest *myRequest = [aRequest mutableCopy];
    [myRequest setValue:@"" forHTTPHeaderField:AFCachingURLHeader];
    
    self = [super initWithRequest:myRequest
                   cachedResponse:cachedResponse
                           client:client];
    
    if (self) {
        [self setRequest:myRequest];
    }
    return self;
}

- (void)startLoading {
    [[_NetCache sharedInstance] cachedRequestForURL:self.request.URL
                                      urlCredential:nil
                                    completionBlock:^(_NetCacheRequest *request)
     {
         NSAssert(request.info.response != nil, @"Response must not be nil - this is a software bug");
         if (request.info.redirectRequest && request.info.redirectResponse) {
             // for some reason this does not work when in flight mode...
             NSURLRequest *redirectRequest = request.servedFromCache && !request.URLInternallyRewritten ? self.request : request.info.redirectRequest;
             NSURLResponse *redirectResponse = request.info.redirectResponse;
             [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:redirectResponse];
         } else {
             [[self client] URLProtocol:self didReceiveResponse:request.info.response cacheStoragePolicy:NSURLCacheStorageAllowed];
             [[self client] URLProtocol:self didLoadData:request.data];
             [[self client] URLProtocolDidFinishLoading:self];
         }
    } failBlock:^(_NetCacheRequest *request) {
        [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
    }];
}

- (void)stopLoading {
    [[_NetCache sharedInstance] cancelAsynchronousOperationsForURL:[[self request] URL] itemDelegate:self];
}

- (NSCachedURLResponse *)cachedResponse {
    return [super cachedResponse];
}

@end
