#import "_HttpRequestManager.h"
#import "NSURLRequest+H5WhiteList.h"

@implementation NSMutableURLRequest (H5WhiteList)

- (NSMutableURLRequest *)filteredRequest {
    if (![self requestInWhiteList:[_HttpRequestManager sharedInstance].h5WhiteList]) {
        return self;
    }
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    if ([[_HttpRequestManager sharedInstance].uid length] > 0) {
        [tempDic setObject:[_HttpRequestManager sharedInstance].uid forKey:@"uuid"];
    }
    if ([[_HttpRequestManager sharedInstance].skey length] > 0) {
        [tempDic setObject:[_HttpRequestManager sharedInstance].skey forKey:@"token"];
    }
    if ([tempDic count] > 0) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *appendParam = [NSString stringWithFormat:@"%@=%@", key, obj];
            [tempArray addObject:appendParam];
        }];
        NSString *cookieStr = [tempArray componentsJoinedByString:@"&"];
        if ([cookieStr length] > 0) {
            NSMutableDictionary *headerInfo = [[self allHTTPHeaderFields] mutableCopy];
            if (!headerInfo) {
                headerInfo = [[NSMutableDictionary alloc] init];
            }
            [headerInfo setObject:cookieStr forKey:@"X-Alisports-Cookie"];
            self.allHTTPHeaderFields = [headerInfo copy];
        }
    }
    return self;
}

- (BOOL)requestInWhiteList: (NSArray<NSString *> *)whiteList {
    if ([whiteList count] == 0) {
        return NO;
    }
    NSString *requestDomain = [self URL].host;
    for (NSString *domain in whiteList) {
        if ([requestDomain hasSuffix:domain]) {
            return YES;
        }
    }
    return NO;
}

@end
