#import <Foundation/Foundation.h>

@class _MockResponse;
@class _MockResponseDSL;

@protocol _HTTPBody;

typedef _MockResponseDSL *(^ResponseWithBodyMethod)(id);
typedef _MockResponseDSL *(^ResponseWithHeaderMethod)(NSString *, NSString *);
typedef _MockResponseDSL *(^ResponseWithHeadersMethod)(NSDictionary *);
typedef _MockResponseDSL *(^ResponseWithDelayMethod)(NSTimeInterval delayInterval);

@interface _MockResponseDSL : NSObject

- (id)initWithResponse:(_MockResponse *)response;

@property (nonatomic, strong) _MockResponse *response;

@property (nonatomic, strong, readonly) ResponseWithHeaderMethod withHeader;
@property (nonatomic, strong, readonly) ResponseWithHeadersMethod withHeaders;
@property (nonatomic, strong, readonly) ResponseWithBodyMethod withBody;
@property (nonatomic, strong, readonly) ResponseWithDelayMethod withDelay;

@end
