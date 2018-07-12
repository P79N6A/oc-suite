//
//  WalletPayService.h
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "PayService.h"
#import "WalletPayOrder.h"

@interface WalletPayService : PayService

@singleton( WalletPayService )

@prop_instance( WalletPayOrder, order )


@end
