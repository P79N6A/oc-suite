//
//  ALSNetworkServerProtocol.h
//  wesg
//
//  Created by 7 on 15/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ALSNetworkServerProtocol <NSObject>

@property (nonatomic, copy) NSString *prot; //必填。协议，如http, https
@property (nonatomic, copy) NSString *host; //必填。域名
@property (nonatomic, copy) NSNumber *port; //端口

@end
