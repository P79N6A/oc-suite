//
//  ALSTransactionDef.h
//  _Modules
//
//  Created by 7 on 2018/8/17.
//

#import "_Foundation.h"
#import "ALSFument.h"
#import "ALSFumentProtocol.h"
#import "ALSInAppPurchase.h"
#import "ALSTransactionKit.h"
#import "NetHelp.h"

@interface ALSTransactionDef : NSObject

@singleton( ALSTransactionDef )

// 配置信息

@property (nonatomic, strong) NSString *payInfoUrlDaily;
@property (nonatomic, strong) NSString *payInfoUrlProduct;

@property (nonatomic, strong) NSString *payNotifyUrlDaily;
@property (nonatomic, strong) NSString *payNotifyUrlProduct;

@end
