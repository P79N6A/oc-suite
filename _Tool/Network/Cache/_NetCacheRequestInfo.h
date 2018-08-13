//
//  _net_cache_request_info.h
//  consumer
//
//  Created by fallen.ink on 9/21/16.
//
//

#import <Foundation/Foundation.h>

#pragma mark -

typedef enum {
    NetCachePackageArchiveStatusUnknown = 0,
    NetCachePackageArchiveStatusLoaded = 1,
    NetCachePackageArchiveStatusConsumed = 2,
    NetCachePackageArchiveStatusUnarchivingFailed = 3,
    NetCachePackageArchiveStatusLoadingFailed = 4,
} NetCachePackageArchiveStatus;

#pragma mark -

@interface _NetCacheRequestInfo : NSObject <NSCoding>

@property (nonatomic, assign) NSTimeInterval requestTimestamp;
@property (nonatomic, assign) NSTimeInterval responseTimestamp;

@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) NSDate *serverDate;
@property (nonatomic, assign) NSTimeInterval age;
@property (nonatomic, copy) NSNumber *maxAge;
@property (nonatomic, strong) NSDate *expireDate;
@property (nonatomic, copy) NSString *eTag;
@property (nonatomic, assign) NSUInteger statusCode;
@property (nonatomic, assign) uint64_t contentLength;
@property (nonatomic, assign) uint64_t actualLength;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSURL *responseURL; // may differ from url when redirection or URL rewriting has occured. nil if URL has not been modified.

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSURLRequest *redirectRequest;
@property (nonatomic, strong) NSURLResponse *redirectResponse;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *cachePath;
@property (nonatomic, assign) NetCachePackageArchiveStatus packageArchiveStatus;

@end
