//
//  _app_user.h
//  student
//
//  Created by fallen.ink on 19/05/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_building_precompile.h"
#import "_archiver.h" // 自动NSCoding

// ----------------------------------
// Macro
// ----------------------------------

#undef  user_inst
#define user_inst [_AppUser sharedInstance]

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppUser : NSObject

@singleton(_AppUser)

// ---------------- 用户实体定义

@prop_assign( int64_t, id )
@prop_strong( NSString *, token ) // 用户验证
@prop_strong( NSString *, session ) // 用户过期验证

@prop_strong( NSString *, orgUuid) // 用户标识

// ----------------

@prop_strong( NSString *, firstCity) // 第一次选择城市

@prop_strong( NSString *, registrationId ) //极光registerId

// ---------------- 用户数据操作

- (void)clear;

- (void)save;

@end
