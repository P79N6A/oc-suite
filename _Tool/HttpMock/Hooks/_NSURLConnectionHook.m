#import "_NSURLConnectionHook.h"
#import "_MockURLProtocol.h"

@implementation _NSURLConnectionHook

- (void)load {
    [NSURLProtocol registerClass:[_MockURLProtocol class]];
}

- (void)unload {
    [NSURLProtocol unregisterClass:[_MockURLProtocol class]];
}

@end
