//
//  ALSProtocol.h
//  wesg
//
//  Created by 7 on 20/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol _Protocol <NSObject>

@optional

/**
 *  是否实现了
 */
- (BOOL)implemented;

/**
 *  是否可用
 */
- (BOOL)available;

/**
 *  类型名
 */
- (NSString *)name;

/**
 * 唯一标识符
 */
- (NSString *)identifier;

/**
 *  清理
 */
- (void)cleanup;

@end
