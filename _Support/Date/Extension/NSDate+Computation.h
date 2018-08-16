//
//  NSDate+Computation.h
//  Pods
//
//  Created by 7 on 2018/6/20.
//

#import <Foundation/Foundation.h>
#import "_Foundation.h"

@interface NSDate (Computation)

@prop_readonly( NSInteger,      nthWeekday ); // e.g. 2nd Tuesday of the month == 2
@prop_readonly( NSInteger,      totalDaysInMonth ); // 当前月
@prop_readonly( NSDate *,       beginningOfMonth ); // first day of current month
@prop_readonly( NSDate *,       endOfMonth ); // last day of current month
@prop_readonly( NSDate *,       beginningOfDaytime ); // the zero time of current day
@prop_readonly( NSString *,     weekStringOfXingQi ); // 星期几
@prop_readonly( NSString *,     weekStringOfZhou ); // 周几
@prop_readonly( NSString *,     formattedTime );
@prop_readonly( NSUInteger,     firstWeekDayInMonth );

@prop_readonly( NSDate *,       beginningOfDay );
@prop_readonly( NSDate *,       endOfDay );
@prop_readonly( NSDate *,       beginningOfWeek );
@prop_readonly( NSDate *,       endOfWeek );
@prop_readonly( NSDate *,       beginningOfYear );
@prop_readonly( NSDate *,       endOfYear );

@property (readonly) NSInteger nearestHour;

/**
 * 获取一年中的总天数
 */
- (NSUInteger)daysInYear;

// Relative dates from the current date
+ (NSDate *)dateTomorrow;
+ (NSDate *)dateYesterday;
+ (NSDate *)dateWithDaysFromNow:(NSUInteger)days;
+ (NSDate *)dateWithDaysBeforeNow:(NSUInteger)days;
+ (NSDate *)dateWithHoursFromNow:(NSUInteger)dHours;
+ (NSDate *)dateWithHoursBeforeNow:(NSUInteger)dHours;
+ (NSDate *)dateWithMinutesFromNow:(NSUInteger)dMinutes;
+ (NSDate *)dateWithMinutesBeforeNow:(NSUInteger)dMinutes;
+ (NSDate *)dateFromHour:(NSInteger)hour day:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
+ (NSDate *)dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
+ (NSDate *)dateWithNoTime:(NSDate *)dateTime middleDay:(BOOL)middle;
+ (NSDate *)dateFromLongLong:(long long)msSince1970;

// Adjusting dates
- (NSDate *)dateByAddingDays:(NSUInteger)dDays;
- (NSDate *)dateBySubtractingDays:(NSUInteger)dDays;
- (NSDate *)dateByAddingHours:(NSUInteger)dHours;
- (NSDate *)dateBySubtractingHours:(NSUInteger)dHours;
- (NSDate *)dateByAddingMinutes:(NSUInteger)dMinutes;
- (NSDate *)dateBySubtractingMinutes:(NSUInteger)dMinutes;
- (NSDate *)dateAtStartOfDay;
- (NSDate *)dateAfterDay:(NSUInteger)day; // 返回day天后的日期(若day为负数,则为|day|天前的日期)
- (NSDate *)dateAfterMonth:(NSUInteger)month; // month个月后的日期

// Retrieving intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
- (NSInteger)daysAfterDate:(NSDate *)aDate;
- (NSInteger)daysBeforeDate:(NSDate *)aDate;

// Calculate month/day/hours count
+ (NSInteger)numberOfDaysInMonth:(NSInteger)month; // caculate number of days by specified month and current year
+ (NSInteger)numberOfDaysInMonth:(NSInteger)month year:(NSInteger) year; // caculate number of days by specified month and year

/**
 * 获取该日期是该年的第几周
 */
- (NSUInteger)weekOfYear;

/**
 * 返回当前月一共有几周(可能为4,5,6)
 */
- (NSUInteger)weeksOfMonth;

/**
 * 获取该月的第一天的日期
 */
- (NSDate *)begindayOfMonth;

/**
 * 获取该月的最后一天的日期
 */
- (NSDate *)lastdayOfMonth;

/**
 * 返回numYears年后的日期
 */
- (NSDate *)offsetYears:(int)numYears;

/**
 * 返回numMonths月后的日期
 */
- (NSDate *)offsetMonths:(int)numMonths;

/**
 * 返回numDays天后的日期
 */
- (NSDate *)offsetDays:(int)numDays;

/**
 * 返回numHours小时后的日期
 */
- (NSDate *)offsetHours:(int)hours;

/**
 * 距离该日期前几天
 */
- (NSUInteger)daysAgo;

/**
 *  获取星期几(名称)
 *
 *  @return Return weekday as a localized string
 *  [1 - Sunday]
 *  [2 - Monday]
 *  [3 - Tuerday]
 *  [4 - Wednesday]
 *  [5 - Thursday]
 *  [6 - Friday]
 *  [7 - Saturday]
 */
- (NSString *)dayFromWeekday;

/**
 *  Get the month as a localized string from the given month number
 *
 *  @param month The month to be converted in string
 *  [1 - January]
 *  [2 - February]
 *  [3 - March]
 *  [4 - April]
 *  [5 - May]
 *  [6 - June]
 *  [7 - July]
 *  [8 - August]
 *  [9 - September]
 *  [10 - October]
 *  [11 - November]
 *  [12 - December]
 *
 *  @return Return the given month as a localized string
 */
+ (NSString *)monthWithMonthNumber:(NSInteger)month;

/**
 * 根据日期返回字符串
 */
- (NSString *)stringWithFormat:(NSString *)format;

/**
 * 获取指定月份的天数
 */
- (NSUInteger)daysInMonth:(NSUInteger)month;
+ (NSUInteger)daysInMonth:(NSDate *)date month:(NSUInteger)month;

/**
 * 获取当前月份的天数
 */
- (NSUInteger)daysInMonth;

@end
