//
//  ShareHelper.m
//  consumer
//
//  Created by fallen on 16/10/24.
//
//

#import "ShareHelper.h"

@interface ShareHelper ()

@property (nonatomic, strong) NSString *originUrl;

@end

@implementation ShareHelper

#pragma mark - Url helper

+ (instancetype)withUrl:(NSString *)url {
    ShareHelper *h = [ShareHelper new];
    h.originUrl = url;
    
    return h;
}

- (NSString *)getUrlWithChannelled {
    __block NSString *channelId = nil;
    
    return [self.class convertUrl:self.originUrl withChannelId:channelId enabled:YES];
}

+ (NSString*)convertUrl:(NSString *)originUrl withChannelId:(NSString *)channelId enabled:(BOOL)enabled {
    if (!enabled) {
        return originUrl;
    }
    
    NSString *url = nil;
    NSRange questionMarkRange = [originUrl rangeOfString:@"?"];
    
    if (questionMarkRange.location != NSNotFound) {
        url = [originUrl stringByAppendingString:[NSString stringWithFormat:@"&channelId=%@", channelId]];
    } else {
        url = [originUrl stringByAppendingString:[NSString stringWithFormat:@"?channelId=%@", channelId]];
    }
    
    return url;
}

@end
