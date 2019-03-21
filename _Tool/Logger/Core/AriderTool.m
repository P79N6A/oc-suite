//
//  AriderTool.m
//  AriderLog
//
//  Created by junzhan on 14-2-24.
//  Copyright (c) 2014年 Taobao. All rights reserved.
//

#import "AriderTool.h"

@implementation AriderTool


+ (BOOL)isSystemVersionGreaterThan7{
    BOOL res = [[[UIDevice currentDevice] systemVersion] doubleValue] > 6.9;
    return res;
}

+ (CGFloat)screenWidth{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight{
    return [UIScreen mainScreen].bounds.size.height;
}
@end
