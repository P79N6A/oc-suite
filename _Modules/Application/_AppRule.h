//
//  _app_rule.h
//  student
//
//  Created by fallen.ink on 01/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <_Foundation/_Foundation.h>

// ----------------------------------
// FIXME: 即将废弃
// ----------------------------------

@interface _AppRule : NSObject

/** 判断手机号码 */
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber;

/** 判断注册账号6-20位英数组合 */
+ (BOOL)checkUserName:(NSString *)userName;

/** 判断注册密码6-20位英数组合 */
+ (BOOL)checkPassWord:(NSString *)passWord;

/** 判断邮箱 */
+ (BOOL)checkEmail:(NSString *)email;

/** 判断身份证号 */
+ (BOOL)checkIdCard:(NSString *)idCard;

/** 判断联系人为汉字，2-4个汉字 */
+ (BOOL)checkPopleName:(NSString *)popleName;

/** 判断正整数 */
+ (BOOL)cheakPosInt:(NSString *)posInt;

@end
