//
//  GrowthIntercepter.m
//  consumer
//
//  Created by 张衡的mini on 16/12/26.
//
//

#import "_Foundation.h"
#import "GrowthIntercepter.h"
#import "GrowthService.h"

@interface GrowthIntercepter () {
    NSMutableDictionary *GrowthIntercepterDic;
}
@end

@implementation GrowthIntercepter

- (void)initViewIntercepter {
    GrowthIntercepterDic = [@{} mutableCopy];
//    [NSMutableDictionary dictionaryWithDictionary:
//                                        @{@"302" : @"AllCommentVC",
//                                          @"801" : @"VoucherWorksListVC"}
//                                        ];
    [GrowthIntercepterDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        Class VC = NSClassFromString(obj);
        [VC hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
            [[GrowthService sharedInstance] viewAppearAtIdentifier:key];
            
        } error:nil];
    }];
}

@end
