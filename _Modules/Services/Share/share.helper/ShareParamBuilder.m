//
//  ShareParamBuilder.m
//  component
//
//  Created by fallen.ink on 12/21/15.
//  Copyright © 2015 OpenTeam. All rights reserved.
//

#import "ShareParamBuilder.h"
#import "ShareHelper.h"
#import "_date.h"

@interface ShareParamBuilder ()

@end

@implementation ShareParamBuilder

- (instancetype)init {
    if (self = [super init]) {
        self.objectId = [[NSDate date] toString:@"yyyy-MM-dd-HH-mm-ss"];
        
//        [AppConfig adapterAppHairDresser:^{
//            self.channelId  = nil;
//        } appCustomer:^{
//            self.channelId = nil;
//        } appMaster:^{
//            self.channelId = nil;
//        }];
    }
    
    return self;
}

#pragma mark - Builder

- (NSDictionary *)getWechatFriendParam {
    return nil;
}

- (NSDictionary *)getWechatFriendCircleParam {
    return nil;
}

- (NSDictionary *)getWeiboParam {
    return nil;
}

- (NSDictionary *)getQQParam {
    return nil;
}

- (NSDictionary *)getQQSpaceParam {
    return nil;
}

- (NSDictionary *)getSmsParam {
    return nil;
}

- (NSDictionary *)getEmailParam {
    return nil;
}

#pragma mark - Property

- (NSString *)url {
    return [ShareHelper convertUrl:_url withChannelId:self.channelId enabled:NO];
}

- (NSString *)smsBody {
   return [NSString stringWithFormat:@"%@%@【易孜美业】",
            self.title,
            self.url];
}

- (NSString *)emailBody {
    return [NSString stringWithFormat:@"%@\n%@", self.detail, self.url];
}

@end
