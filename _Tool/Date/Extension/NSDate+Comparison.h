//
//  NSDate+Comparison.h
//  _Foundation
//
//  Created by 7 on 2018/6/20.
//

#import <Foundation/Foundation.h>

@interface NSDate (Comparison)

- (BOOL)isLeapYear;
+ (BOOL)isLeapYear:(NSInteger)year;

- (BOOL)isDayEqualToDate:(NSDate *)anotherDate;
- (BOOL)isYearMonthDayEqualToDate:(NSDate *)anotherDate;
- (BOOL)isYearMonthEqualToDate:(NSDate *)anotherDate;
- (BOOL)isComponentDayEqualToDate:(NSDate *)anotherDate;
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate; // isSameDay
- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;
- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;
- (BOOL)isSameYearAsDate:(NSDate *)aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;
- (BOOL)isEarlierThanDate:(NSDate *)aDate; // is before
- (BOOL)isLaterThanDate:(NSDate *)aDate; // is after

#pragma mark - 判断日期
- (BOOL)isSameMonthAsDate:(NSDate *) aDate;
- (BOOL)isThisMonth;
- (BOOL)isInFuture;
- (BOOL)isInPast;

#pragma mark - 周末和工作日
- (BOOL)isTypicallyWorkday;
- (BOOL)isTypicallyWeekend;

/*
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */
+ (NSString *)compareCurrentTime:(NSDate *) compareDate;

/**
 * 返回x分钟前/x小时前/昨天/x天前/x个月前/x年前
 */
- (NSString *)timeInfo;
+ (NSString *)timeInfoWithDate:(NSDate *)date;
+ (NSString *)timeInfoWithDateString:(NSString *)dateString;

@end
