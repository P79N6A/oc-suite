//
//  UnionPayOrder.h
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
extern BOOL g_ToggleUnionEnvOnFormal;
#endif

@interface UnionPayOrder : NSObject

@property (nonatomic, strong) NSString *tn; // transaction 交易
@property (nonatomic, strong, readonly) NSString *tnMode;
@property (nonatomic, weak) UIViewController *context; // 控件支付，依赖的上下文

@end
