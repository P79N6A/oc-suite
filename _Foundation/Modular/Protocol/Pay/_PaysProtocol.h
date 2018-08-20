#import "_Protocol.h"
#import "_PayProtocol.h"
#import "_PayParamProtocol.h"
#import "_PayInAppPurchaseProtocol.h"

@protocol _PaysProtocol <_Protocol>

@property (nonatomic, assign) BOOL debugMode;

@property (nonatomic, strong) id<_PayInAppPurchaseProtocol> iap;
@property (nonatomic, strong) id<_PayProtocol> alipay;
@property (nonatomic, strong) id<_PayProtocol> wechat;

- (void)launch;

//// 最老的版本，最好也写上
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url { return [midware.pay handleOpenURL:url]; }
//// iOS 9.0 之前 会调用
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation { return [midware.pay handleOpenURL:url]; }
//// iOS 9.0 以上（包括iOS9.0）
//- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options { return [midware.pay handleOpenURL:url]; }

- (BOOL)handleOpenURL:(NSURL *)url; // 有可能会挪到 ALSPayProtocol 中

@optional

- (NSDictionary *)signedDictBy:(NSDictionary *)param key:(NSString *)key keyvalue:(NSString *)keyvalue;

@end
