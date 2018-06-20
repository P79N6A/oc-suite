//
//  NSDate+JKZeroDate.h
//  Jakey
//
//  Created by Jakey on 15/5/9.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate ( ZeroDate )
+ (NSDate *)zeroTodayDate;
+ (NSDate *)zero24TodayDate;

- (NSDate *)zeroDate;
- (NSDate *)zero24Date;
@end
