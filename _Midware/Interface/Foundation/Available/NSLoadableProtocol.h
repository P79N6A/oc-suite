//
//  NSLoadableProtocol.h
//  wesg
//
//  Created by 7 on 06/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSLoadableProtocol <NSObject>

/**
 *  可自动收到 app加载时机 / 取代类加载时机
 *
 *  @desc 在AppDelegate加载之前调用
 */
+ (void)onLoad;

@end
