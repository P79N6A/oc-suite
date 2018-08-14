//
//  NSArraySubscriptProtocol.h
//  NewStructure
//
//  Created by 7 on 20/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol _ArraySubscriptProtocol <NSObject>

// 数组样式
- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
