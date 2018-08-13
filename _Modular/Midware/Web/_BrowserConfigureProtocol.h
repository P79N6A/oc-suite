//
//  ALSBrowserConfigureProtocol.h
//  wesg
//
//  Created by 7 on 20/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ALSBrowserConfigureProtocol <NSObject>

// 视图层

@property(nonatomic, assign) BOOL hidesBottomBarWhenPushed;

// 功能性

/**
 * FIXME: 当前不使用更通用的右上角按钮配置方式，保留‘分享’
 */
@property (nonatomic, assign) BOOL shareHidden;
@property (nonatomic, strong) NSInvocation *shareHandler;

@end
