////
////  HTTPDNSServer.m
//// fallen.ink
////
////  Created by 陶澄 on 15/10/22.
////
////
//
///*
// * 该结构对应一个域名，用来管理当前域名对应的ip数组，已经失败重试的次数，定时重试主ip等等
// */
//@interface DNSModel:NSObject
//
////域名
//@property (nonatomic, strong) NSString *domainString;
////IP数组
//@property (nonatomic, strong) NSArray  *ipArray;
////单个ip已经重试的次数
//@property (nonatomic, assign) int      retryTimeNumber;
////当前域名正在使用的IP
//@property (nonatomic, strong) NSString *currentUseIPString;
//
//@end
//
//@implementation DNSModel
//
//@end
//
//#import "HTTPDNSServer.h"
//#import <SystemConfiguration/SCNetworkReachability.h>
//#include <arpa/inet.h>
//
//@interface HTTPDNSServer ()
//
////http请求失败重试次数
//@property (nonatomic, assign) int httpRequestFailedRetryTime;
////备用ip切换比例
//@property (nonatomic, assign) int backupIPSwitchRate;
////dns缓存过期时间，需要定时重新拉取
//@property (nonatomic, assign) int cacheOverdueTime;
////备用ip定期检测主ip是否可以连通的时间
//@property (nonatomic, assign) int backupIPSwitchToMainIPTime;
////域名对应ip的数组，存储的对象是:DNSModel
//@property (nonatomic, strong) NSMutableArray *dnsArray;
////当前请求httpdns列表的url
//@property (nonatomic, strong) NSString *dnsListRequestUrlString;
////当前请求httpdns列表的url
//@property (nonatomic, assign) BOOL v1AndV2UrlAllRequest;
//
//@end
//
//@implementation HTTPDNSServer
//
//#pragma mark - Initialization
//
//@def_singleton( HTTPDNSServer )
//
//- (id)init {
//    if (self = [super init]) {
//        self.backupIPSwitchRate = 0;
//        self.dnsListRequestUrlString = @"kClient_HttpDns_GetDomainIPListV1String";
//        self.v1AndV2UrlAllRequest = NO;
//    }
//    return self;
//}
//
//- (void)changeHttpDnsListUrl {
//    if ([self.dnsListRequestUrlString isEqualToString:@"kClient_HttpDns_GetDomainIPListV1String"]) {
//        self.dnsListRequestUrlString = @"kClient_HttpDns_GetDomainIPListV2String";
//    } else {
//        self.dnsListRequestUrlString = @"kClient_HttpDns_GetDomainIPListV1String";
//    }
//}
//#pragma mark - Internal
//
//- (void)start {
//    self.v1AndV2UrlAllRequest = NO;
//    [self sendHttpDnsListRequestWithSubscribe:nil];
//}
//
//- (RACSignal *)sig_GetHttpDnsList {
//    @weakify(self);
//    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        @strongify(self);
//        [self sendHttpDnsListRequestWithSubscribe:subscriber];
//        return nil;
//    }];
//}
//
//- (void)sendHttpDnsListRequestWithSubscribe:(id<RACSubscriber>)subscriber {
////    @weakify(self);
////    RACSignal *requestSignal = [SignalFromRequest signalFromJsonRequestWithApiPath:self.dnsListRequestUrlString withHttpMethod:@"GET" withPostBody:nil];
////    __block RACDisposable *disposable = [[requestSignal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
////        @strongify(self);
////        NSError *error = nil;
////        id resultDict = [NSJSONSerialization JSONObjectWithData:x options:NSJSONReadingAllowFragments error:&error];
////        //列表拉取状态:1成功 0失败
////        int status = [[resultDict objectForKey:@"status"] intValue];
////        if (status) {
////            self.v1AndV2UrlAllRequest = NO;
////            //备用 IP切换比例
////            self.backupIPSwitchRate = [[resultDict objectForKey:@"rate"] intValue];
////            self.backupIPSwitchRate = 0;
////            //                _backupIPSwitchRate = 100;
////            //网络请求超时重试次数
////            self.httpRequestFailedRetryTime = [[resultDict objectForKey:@"tries"] intValue];
////            //备用ip定期检测主ip是否可以连通的时间
////            self.backupIPSwitchToMainIPTime = [[resultDict objectForKey:@"rtime"] intValue];
////            //缓存过期时间
////            self.cacheOverdueTime = [[resultDict objectForKey:@"ttl"] intValue];
////            //初始化dns数组
////            [self initDNSArrayWithDictionaryArray:[resultDict objectForKey:@"data"]];
////            
////            //dns列表信息过期，定期重新拉取
////            [NSObject cancelPreviousPerformRequestsWithTarget:self];
////            [self performSelector:@selector(start) withObject:nil afterDelay:_cacheOverdueTime];
////            
////            [subscriber sendNext:nil];
////            [subscriber sendCompleted];
////        } else {
////            if (!self.v1AndV2UrlAllRequest) {
////                self.v1AndV2UrlAllRequest = YES;
////                [self changeHttpDnsListUrl];
////                [self sendHttpDnsListRequestWithSubscribe:subscriber];
////                [disposable dispose];
////            } else {
////                NSError *errorToReturn;// = ERROR_MAKE2(kErrorDomain_HttpDnsList, error.code);
////                [subscriber sendError:errorToReturn];
////                [subscriber sendCompleted];
////            }
////        }
////    } error:^(NSError *error) {
////        if([error.domain isEqualToString:@"time out"] && !self.v1AndV2UrlAllRequest) {
////            self.v1AndV2UrlAllRequest = YES;
////            [self changeHttpDnsListUrl];
////            [self sendHttpDnsListRequestWithSubscribe:subscriber];
////            [disposable dispose];
////        } else {
////            self.v1AndV2UrlAllRequest = YES;
////            //本次更新失败之后，再过定期时间，重新拉取，暂时本地使用上次数据
////            [NSObject cancelPreviousPerformRequestsWithTarget:self];
////            if (_cacheOverdueTime > 0) {
////                [self performSelector:@selector(start) withObject:nil afterDelay:_cacheOverdueTime];
////            }
////            
////            NSError *errorToReturn;// = ERROR_MAKE2(@"kErrorDomain_HttpDnsList", error.code);
////            [subscriber sendError:errorToReturn];
////        }
////    }];
//}
//
//- (DNSModel *)getDNSModelWithRequest:(NSURLRequest *)request {
//    @synchronized(self) {
//        
//        for (DNSModel *dnsModel in _dnsArray) {
//            //做一层过滤，防止出现域名存在包含的case，em:"ps.api.idc.changingedu.com","api.idc.changingedu.com"
//            NSString *domainHoleString = [NSString stringWithFormat:@"/%@/",dnsModel.domainString];
//            
//            if ([request.URL.absoluteString contains:domainHoleString]) {
//                return dnsModel;
//            }
//            
//            for (int index = 0; index < dnsModel.ipArray.count; index ++) {
//                NSString *ipString = [dnsModel.ipArray objectAtIndexIfIndexInBounds:index];
//                //做一层过滤，防止出现域名存在包含的case，em:"172.168.1.11","172.168.1.1"
//                NSString *ipHoleString = [NSString stringWithFormat:@"/%@/",ipString];
//                
//                if ([request.URL.absoluteString contains:ipHoleString]) {
//                    return dnsModel;
//                }
//            }
//        }
//        return nil;
//    }
//}
//
//- (void)initDNSArrayWithDictionaryArray:(NSArray *)dnsDictionaryArray {
//    @synchronized(self) {
//        NSMutableArray *dnsTempArray = [NSMutableArray new];
//        for (NSDictionary *dnsDictionary in dnsDictionaryArray) {
//            DNSModel *dnsModel = [DNSModel new];
//            dnsModel.domainString = [dnsDictionary objectForKey:@"dn"];
//            dnsModel.ipArray = [dnsDictionary objectForKey:@"ip"];
//            dnsModel.retryTimeNumber = 0;
//            dnsModel.currentUseIPString = nil;
//            [dnsTempArray addObject:dnsModel];
//        }
//        _dnsArray = dnsTempArray;
//    }
//}
//
//- (BOOL)dnsFunctionIsOpen {
//    
//    if (_backupIPSwitchRate == 0) {
//        return NO;
//    } else if (_backupIPSwitchRate == 100) {
//        return YES;
//    } else {
//        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//        int rate = [idfv hash]%100;
//        if (rate <= _backupIPSwitchRate) {
//            return YES;
//        } else {
//            return NO;
//        }
//    }
//}
//
//- (void)setHttpRequestFailedWithRequest:(QQUrlRequest *)request {
//    @synchronized(self) {
//        DNSModel *dnsModel = [self getDNSModelWithRequest:request.request];
//        dnsModel.retryTimeNumber = dnsModel.retryTimeNumber + 1;
//        [self recordRequestData:request withSuccess:NO];
//    }
//}
//
//- (void)setHttpRequestSuccessedWithRequest:(QQUrlRequest *)request {
//    @synchronized(self) {
//        DNSModel *dnsModel = [self getDNSModelWithRequest:request.request];
//        dnsModel.retryTimeNumber = 0;
//        [self recordRequestData:request withSuccess:YES];
//    }
//}
//
//- (void)recordRequestData:(QQUrlRequest *)request withSuccess:(BOOL)isSuccess{
//    NSArray *urlArray = [request.request.URL.absoluteString componentsSeparatedByString:@"/"];
//    NSString *ipString = [urlArray objectAtIndexIfIndexInBounds:2];
//    
//    NSString *hostString = [request.request valueForHTTPHeaderField:@"kClient_HTTPHostKey"];
//    if (!hostString) {
//        hostString = ipString;
//    }
//    
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    if (hostString.length > 0) {
//        [dic setObject:hostString forKey:@"host"];
//    }
//    if (ipString.length > 0) {
//        [dic setObject:ipString forKey:@"hostip"];
//    }
//    [dic setObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:isSuccess]] forKey:@"status"];
//    [dic setObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:[self dnsFunctionIsOpen]]] forKey:@"dnsstatus"];
//    [dic setObject:[NSString stringWithFormat:@"%@",request.costTime] forKey:@"cost"];
//}
//
////- (NSString *)stringWith
//- (void)checkIPConnection:(DNSModel *)dnsModel {
//    @synchronized(self) {
//        //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
//        NSString *ipStr = dnsModel.ipArray.firstObject;
//        const char *ip = [ipStr UTF8String];
//        struct sockaddr_in zeroAddress;
//        bzero(&zeroAddress, sizeof(zeroAddress));
//        zeroAddress.sin_len = sizeof(zeroAddress);
//        zeroAddress.sin_family = AF_INET;
//        zeroAddress.sin_addr.s_addr = inet_addr(ip);
//        
//        // Recover reachability flags
//        SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
//        SCNetworkReachabilityFlags flags;
//        //获得连接的标志
//        SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
//        CFRelease(defaultRouteReachability);
//        
//        //根据获得的连接标志进行判断
//        BOOL isReachable = flags & kSCNetworkFlagsReachable;
//        
//        if (isReachable) {
//            dnsModel.currentUseIPString = dnsModel.ipArray.firstObject;
//            dnsModel.retryTimeNumber = 0;
//        } else {
//            [self performSelector:@selector(checkIPConnection:) withObject:dnsModel afterDelay:_backupIPSwitchToMainIPTime];
//        }
//    }
//}
//
//- (NSMutableURLRequest *)getDNSPackingRequestWithRequest:(NSMutableURLRequest *)request {
//    @synchronized(self) {
//        
//        // https的请求暂时过滤，因为用ip解决不了证书验证的问题
//        if ([request.URL.absoluteString hasPrefix:@"https://"]) {
//            return request;
//        }
//        
//        if ([self dnsFunctionIsOpen]) {//本机是否打开
//            //获取request对应的DNSModel
//            DNSModel *dnsModel = [self getDNSModelWithRequest:request];
//            
//            //处理没有对应上域名的model case
//            if (!dnsModel) {
//                return request;
//            }
//            
//            //设置当前应该使用的ip
//            if (dnsModel.retryTimeNumber == _httpRequestFailedRetryTime) { //达到了切换条件
//                for (int index = 0; index < dnsModel.ipArray.count; index ++) {
//                    NSString *ipString = [dnsModel.ipArray objectAtIndexIfIndexInBounds:index];
//                    if ([dnsModel.currentUseIPString isEqualToString:ipString]) { //找到当前正在使用的ip
//                        if (dnsModel.ipArray.count != index + 1) { //还有可以替换的ip，使用下一个ip
//                            
//                            //备用ip定期检测主ip是否可以连通,在首次切换备用ip的时候，发起定时请求,
//                            if ([dnsModel.currentUseIPString isEqualToString:dnsModel.ipArray.firstObject]) {
//                                [self performSelector:@selector(checkIPConnection:) withObject:dnsModel afterDelay:_backupIPSwitchToMainIPTime];
//                            }
//                            dnsModel.currentUseIPString = [dnsModel.ipArray objectAtIndexIfIndexInBounds:index + 1];
//                        } else { //没有可以替换的ip了，使用域名
//                            dnsModel.currentUseIPString = dnsModel.domainString;
//                        }
//                    }
//                }
//            } else {
//                if (dnsModel.ipArray.firstObject && !dnsModel.currentUseIPString) { //当前使用的ip是空，则相当于第一次替换ip，设置为主ip
//                    dnsModel.currentUseIPString = dnsModel.ipArray.firstObject;
//                }
//            }
//            
//            //找到当前request正在使用的ip
//            NSString *requestIPString = nil;
//            //做一层过滤，防止出现域名存在包含的case，em:"ps.api.idc.changingedu.com","api.idc.changingedu.com"
//            NSString *domainHoleString = [NSString stringWithFormat:@"/%@/",dnsModel.domainString];
//            if ([request.URL.absoluteString contains:domainHoleString]) {
//                requestIPString = dnsModel.domainString;
//            } else {
//                for (int index = 0; index < dnsModel.ipArray.count; index ++) {
//                    NSString *ipString = [dnsModel.ipArray objectAtIndexIfIndexInBounds:index];
//                    //做一层过滤，防止出现域名存在包含的case，em:"172.168.1.11","172.168.1.1"
//                    NSString *ipHoleString = [NSString stringWithFormat:@"/%@/",ipString];
//                    if ([request.URL.absoluteString contains:ipHoleString]) { //找到当前正在使用的ip
//                        requestIPString = ipString;
//                    }
//                }
//            }
//            
//            //替换ip
//            if (requestIPString) {
//                //设置httpheader，key＝host，value＝域名
//                [request setValue:dnsModel.domainString forHTTPHeaderField:@"kClient_HTTPHostKey"];
//                NSString *urlString = request.URL.absoluteString;
//                //替换老ip
//                NSString *newIPString = [urlString stringByReplacingOccurrencesOfString:requestIPString withString:dnsModel.currentUseIPString];
//                
//                request.URL = [NSURL URLWithString:newIPString];
//            }
//            return request;
//        } else {
//            return request;
//        }
//    }
//}
//
//@end
