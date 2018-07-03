//
//  _app_rule.m
//  student
//
//  Created by fallen.ink on 01/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_app_rule.h"

@implementation _AppRule

//判断手机号码 (以13 14 17 15 18开头)
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber {
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|14[57]|17[678]|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phoneNumber];
}

//判断注册账号6-20位英数组合
+ (BOOL)checkUserName:(NSString *)userName {
    NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:userName];
    return B;
}

//判断注册密码6-20位英数组合
+ (BOOL)checkPassWord:(NSString *)passWord {
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

//判断邮箱
+ (BOOL)checkEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//判断身份证号
+ (BOOL)checkIdCard:(NSString *)idCard {
    BOOL flag;
    if (idCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:idCard];
}

//判断联系人为汉字，2-4个汉字
+ (BOOL)checkPopleName:(NSString *)popleName {
    NSString *popleRegex = @"[\u4e00-\u9fa5]{2,4}+$";
    NSPredicate *popleTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",popleRegex];
    return [popleTest evaluateWithObject:popleName];
}

/** 判断正整数 */
+ (BOOL)cheakPosInt:(NSString *)posInt {
    NSString *posRegex = @"[1-9]\\d{0,4}";
    NSPredicate *posTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",posRegex];
    return [posTest evaluateWithObject:posInt];
}


@end
