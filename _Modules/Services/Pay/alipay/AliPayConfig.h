//
//  AliPayConfig.h
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "_greats.h"

@interface AliPayConfig : NSObject

@singleton( AliPayConfig )

@property (nonatomic, strong) NSString *parnter;
@property (nonatomic, strong) NSString *seller;
@property (nonatomic, strong) NSString *privateKey;
@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) NSString *notifyURL;      // 回调URL

// Downby should be const.
@property (nonatomic, strong) NSString *showURL;
@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSString *paymentType;
@property (nonatomic, strong) NSString *inputCharset;

@end
