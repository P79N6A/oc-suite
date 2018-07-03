//
//  ALSModel.h
//  wesg
//
//  Created by 7 on 28/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -

@interface NSObject ( Model )

/**
 *  用 data 初始化 model
 */
+ (instancetype)with:(id)data;

/**
 *  data 对象转化为 model
 */
+ (instancetype)from:(id)data;

@end

#pragma mark -

@interface ALSModel : NSObject

@end
