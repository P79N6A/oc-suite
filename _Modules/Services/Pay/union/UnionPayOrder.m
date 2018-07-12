//
//  UnionPayOrder.m
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "UnionPayOrder.h"

@implementation UnionPayOrder

#ifdef DEBUG
BOOL g_ToggleUnionEnvOnFormal = YES;
#endif

- (NSString *)tnMode {
#ifdef DEBUG
    if (g_ToggleUnionEnvOnFormal) {
        return @"00";
    } else {
        return @"01"; // mode 竟然是个死的字符串 真是醉了 "00" 表示线上环境"01"表示测试环境
    }
#else
    return @"00";
#endif
}

@end
