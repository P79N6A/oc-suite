//
//  ALSDependencyProtocol.h
//  wesg
//
//  Created by 7 on 11/02/2018.
//  Copyright © 2018 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ALSDependencyProtocol <NSObject>

// QQ: http://wiki.connect.qq.com/%E9%80%9A%E7%9F%A5
@property (nonatomic, readonly) BOOL isQQInstalled;
@property (nonatomic, readonly) BOOL isTIMInstalled;

@end
