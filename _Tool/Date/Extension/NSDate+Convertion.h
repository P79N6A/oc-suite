//
//  NSDate+Convertion.h
//  AEAssistant
//
//  Created by Qian Ye on 16/4/21.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (Convertion)
/**
 *  将HTTP时间字符串转换成NSDate
 *
 *  @param httpDate HTTP时间字符串
 *
 *  @return 返回值
 */
+ (NSDate *)dateFromHttpDateString:(NSString *)httpDate;

@end
