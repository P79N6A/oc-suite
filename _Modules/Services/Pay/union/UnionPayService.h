//
//  UnionPayService.h
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "PayService.h"
#import "UnionPayOrder.h"

@interface UnionPayService : PayService

@singleton( UnionPayService )

@prop_instance( UnionPayOrder, order)

#pragma mark -

- (BOOL)pay;

- (void)process:(id)data;

@end

#pragma mark -

@namespace( service , unionpay, UnionPayService )
