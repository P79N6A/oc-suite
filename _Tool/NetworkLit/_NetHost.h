#import <Foundation/Foundation.h>
#import "_NetRequest.h"

@class _NetHost;

@protocol NetHostDelegate <NSObject>

@optional

@end

@interface _NetHost : NSObject

- (id)initWithHostName:(NSString *)hostName;

@property NSString *hostName;
@property NSString *path;
@property NSUInteger port;
@property NSDictionary *defaultHeaders;
@property BOOL secureHost;
@property NetRequestParameterEncoding defaultParameterEncoding;

@property (weak) id <NetHostDelegate> delegate;
@property (copy) void (^backgroundSessionCompletionHandler)(void);

- (NSError *)errorForCompletedRequest:(_NetRequest *)completedRequest;

- (_NetRequest *)requestWithURLString:(NSString *)urlString;
- (_NetRequest *)requestWithPath:(NSString *)path;
- (_NetRequest *)requestWithPath:(NSString *)path
                          params:(NSDictionary*) params;
- (_NetRequest *)requestWithPath:(NSString *)path
                          params:(NSDictionary *)params
                      httpMethod:(NSString *)httpMethod;
/**
 *  @brief Creates a simple GET Operation with a request URL, parameters, HTTP Method and the SSL switch
 *
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The ssl option when true changes the URL to https.
 *  The ssl option when false changes the URL to http.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The params dictionary in this method gets attached to the URL as query parameters if the HTTP Method is GET/DELETE
 *  The params dictionary is attached to the body if the HTTP Method is POST/PUT
 *  The body data is attached to the request body
 *  If the body data is present and the para
 *  This method calls operationsWithPath:body:httpMethod:ssl: eventually to construct the operation
 */
- (_NetRequest *)requestWithPath:(NSString *)path
                          params:(NSDictionary *)params
                      httpMethod:(NSString *)method
                            body:(NSData *)bodyData
                             ssl:(BOOL)useSSL;

- (void)startRequest:(_NetRequest *)request;
- (void)startUploadRequest:(_NetRequest *)request;
- (void)startDownloadRequest:(_NetRequest *)request;

@end
