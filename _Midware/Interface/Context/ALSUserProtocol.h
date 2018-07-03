//
//  ALSUserProtocol.h
//  wesg
//
//  Created by 7 on 22/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ALSUserProtocol <NSObject>

@property (nonatomic, readonly) NSString *uuid;
@property (nonatomic, readonly) NSString *token;

@end
