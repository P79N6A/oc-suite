#import "_Foundation.h"
#import "_ApiManager.h"
#import "_HttpRequestHandler.h"

#define AppSDKVersion     @"0"
#define kAppSDKVersionKey  @"kAppSDKVersionKey"
#define kInterfaceBundleVersion @"kInterfaceBundleVersion"

@interface _ApiManager ()

@property (nonatomic, strong) _HttpRequestHandler *downloadClient;

- (void)cleanInterfaceInfo;

- (NSString *)getConfigVersion;

- (void)downloadInterfaceListSusseed:(NSDictionary *)respData;

- (void)downloadInterfaceListFailed:(NSError *)error;

- (void)refresh:(NSDictionary *)data;

@end

@implementation _ApiManager

- (instancetype)init {
    self = [super init];
    if (self) {
        if (!is_first_launched) {
            //未启动过
            [self cleanInterfaceInfo];
        }
        [self refresh:nil];
    }
    return self;
}

@def_singleton(_ApiManager)

#pragma mark Private methods

- (NSString *)getConfigVersion {
    NSString *versionLocal = [[NSUserDefaults standardUserDefaults] objectForKey:kAppSDKVersionKey];
    if (versionLocal == nil) {
        versionLocal = AppSDKVersion;
    }
    return versionLocal;
}

- (void)downloadInterfaceListSusseed:(NSDictionary *)respData {
    _interfaceData = respData;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        
        BOOL res = [self.interfaceData writeToFile:FILE_CACHE_PATH(@"interface_list.plist") atomically:NO];
        if (!res) {
            _interfaceData = [self loadBundle];
        } else {
            NSString *newVersion = [self.interfaceData objectForKey:@"version"];
            [[NSUserDefaults standardUserDefaults] setObject:newVersion forKey:kAppSDKVersionKey];
            [[NSUserDefaults standardUserDefaults] setObject:app_version forKey:kInterfaceBundleVersion];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            [self refresh:self.interfaceData];
        });
    });
}

- (void)downloadInterfaceListFailed:(NSError *)error {
    [self refresh:nil];
}

- (NSDictionary*)loadBundle {
    NSDictionary*dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"interface_list" ofType:@"plist"]];
    return dic;
}

- (void)cleanInterfaceInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAppSDKVersionKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInterfaceBundleVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)refresh:(NSDictionary *)data {
    @synchronized (self) {
        if(data) {
            _interfaceData = data;
            _URLMapWithAlias = [NSDictionary dictionaryWithDictionary:[data objectForKey:@"data"]];
        } else {
            NSDictionary *URLMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"interface_list" ofType:@"plist"]];
            _URLMapWithAlias = [NSDictionary dictionaryWithDictionary:[URLMap objectForKey:@"data"]];
        }
    }
}


#pragma mark Public methods

- (void)updateInterface {
    if ([self.interfaceListAddress length] == 0) {
        return;
    }
    if (!self.downloadClient) {
        if (!self.downloadClient) {
            self.downloadClient = [_HttpRequestHandler clientWithUrlString:self.interfaceListAddress];
        }
    }
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[self getConfigVersion], @"cfgver", @"1", @"app", app_version, @"appVersion", nil];
    
    weakly(self)
    [self.downloadClient startHttpRequestWithParameter:param success:^(_HttpRequestHandler *handler, NSDictionary *responseData) {
        [_ downloadInterfaceListSusseed:responseData];
    } failure:^(_HttpRequestHandler *handler, NSError *error) {
        [_ downloadInterfaceListFailed:error];
    }];
}

- (NSString *)getURLStringWithAliasName:(NSString *)aliasName {
    NSString *urlString = [[self.URLMapWithAlias objectForKey:aliasName] objectForKey:@"url"];
    if (![urlString isKindOfClass:[NSString class]] || [urlString length] == 0) {
        return nil;
    }
    if (self.configuration) {
        //有配置项的情况
        NSMutableString *apiString = [NSMutableString stringWithFormat:@"%@://%@", self.configuration.prot, self.configuration.host];
        if (self.configuration.port) {
            [apiString appendFormat:@":%@", self.configuration.port];
        }
        [apiString appendString:urlString];
        urlString = [apiString copy];
    }
    //补充问号
    if ([urlString rangeOfString:@"?"].location == NSNotFound) {
        urlString = [NSString stringWithFormat:@"%@?", urlString];
    }
    return urlString;
}

- (NSString *)getURLSendDataMethodWithAliasName:(NSString *)aliasName {
    NSString * httpMethod = [[self.URLMapWithAlias objectForKey:aliasName] objectForKey:@"method"];
    if (!httpMethod || ![httpMethod isKindOfClass:[NSString class]] || [httpMethod length] == 0) {
        return nil;
    }
    return [httpMethod uppercaseString];
}

@end

