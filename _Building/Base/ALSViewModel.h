//
//  ALSViewModel.h
//  wesg
//
//  Created by 7 on 24/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ALSDataSource.h"

#pragma mark -

@interface ALSViewModel : NSObject

/**
 *  构建视图模型
 */
+ (instancetype)with:(id)data;


/**
 *  刷新视图模型
 */
- (void)setdown:(id)data;

/**
 *  数据初始化
 */
- (void)setup;

@end

#pragma mark -

@interface UIViewController ( ViewModel )

- (void)bind;

@end
