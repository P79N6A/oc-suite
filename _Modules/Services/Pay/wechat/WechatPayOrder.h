//
//  WechatPayOrder.h
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import <Foundation/Foundation.h>

@interface WechatPayOrder : NSObject

@property (nonatomic, copy) NSString *  prepayId;
@property (nonatomic, copy) NSString *  nonceStr;
@property (nonatomic, assign) uint32_t  timeStamp;
@property (nonatomic, copy) NSString *  package;
@property (nonatomic, copy) NSString *  sign;

@end
