//
//  AliPayOrder.h
//  consumer
//
//  Created by fallen.ink on 9/20/16.
//
//

#import "_greats.h"

@interface AliPayOrder : NSObject

@error( err_invalidOrderNumber )
@error( err_invalidProductName )
@error( err_failedGenerateOrder )

- (NSString *)generate:(NSError **)ppError;

- (void)clear;

@end
