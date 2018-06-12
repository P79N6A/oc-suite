//
//  NSDate+Extension.h
//  component
//
//  Created by fallen.ink on 4/13/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_greats.h"

/**
 
 格式化参数如下：
 G: 公元时代，例如AD公元
 yy: 年的后2位
 yyyy: 完整年
 MM: 月，显示为1-12
 MMM: 月，显示为英文月份简写,如 Jan//跟系统语言版本有关系，中文显示“3月”，英文显示“Jan”
 MMMM: 月，显示为英文月份全称，如 Janualy//跟系统语言版本有关系，中文显示“3月”，英文显示“Jan”
 dd: 日，2位数表示，如02
 d: 日，1-2位显示，如 2
 EEE: 简写星期几，如Sun
 EEEE: 全写星期几，如Sunday
 aa: 上下午，AM/PM
 H: 时，24小时制，0-23
 K：时，12小时制，0-11
 m: 分，1-2位
 mm: 分，2位
 s: 秒，1-2位
 ss: 秒，2位
 S: 毫秒
 
 */

/**
 *  @knowledge http://www.cnblogs.com/QianChia/p/5782755.html
 
 根据提供的日历标示符初始化。
 
 identifier 的范围可以是:
 
 NSCalendarIdentifierGregorian         公历
 NSCalendarIdentifierBuddhist          佛教日历
 NSCalendarIdentifierChinese           中国农历
 NSCalendarIdentifierHebrew            希伯来日历
 NSCalendarIdentifierIslamic           伊斯兰日历
 NSCalendarIdentifierIslamicCivil      伊斯兰教日历
 NSCalendarIdentifierJapanese          日本日历
 NSCalendarIdentifierRepublicOfChina   中华民国日历（台湾）
 NSCalendarIdentifierPersian           波斯历
 NSCalendarIdentifierIndian            印度日历
 NSCalendarIdentifierISO8601           ISO8601
 
 */

#pragma mark -

#define SECOND		(1)
#define MINUTE		(60 * SECOND)
#define HOUR		(60 * MINUTE)
#define DAY			(24 * HOUR)
#define MONTH		(30 * DAY)
#define YEAR		(12 * MONTH)
#define NOW			[NSDate date]

#define DATE_COMPONENTS (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

#pragma mark -

typedef enum {
    WeekdayType_Sunday = 1,
    WeekdayType_Monday,
    WeekdayType_Tuesday,
    WeekdayType_Wednesday,
    WeekdayType_Thursday,
    WeekdayType_Friday,
    WeekdayType_Saturday
} WeekdayType;

#pragma mark -

@interface NSDate (Extension)

#pragma mark - Decomposing Dates

// Decomposing dates
@prop_readonly( NSInteger,		year );
@prop_readonly( NSInteger,		month );
@prop_readonly( NSInteger,		day );
@prop_readonly( NSInteger,		hour );
@prop_readonly( NSInteger,		minute );
@prop_readonly( NSInteger,		second );
@prop_readonly( WeekdayType,	weekday );
@prop_readonly( NSInteger,	    week );
@prop_readonly( NSInteger,	    nthWeekday ); // e.g. 2nd Tuesday of the month == 2
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

+ (NSTimeInterval)unixTime;
+ (NSString *)unixDate;

+ (NSDateFormatter *)format;
+ (NSDateFormatter *)format:(NSString *)format;
+ (NSDateFormatter *)format:(NSString *)format timeZoneGMT:(NSInteger)hours;
+ (NSDateFormatter *)format:(NSString *)format timeZoneName:(NSString *)name;

- (NSString *)toString:(NSString *)format;
- (NSString *)toString:(NSString *)format timeZoneGMT:(NSInteger)hours;
- (NSString *)toString:(NSString *)format timeZoneName:(NSString *)name;

/*
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */
+ (NSString *)compareCurrentTime:(NSDate *) compareDate;

@end

#pragma mark - Comparing dates

@interface NSDate ( Comparison )

+ (BOOL)isLeapYear:(NSInteger)year;

- (BOOL)isDayEqualToDate:(NSDate *)anotherDate;
- (BOOL)isYearMonthDayEqualToDate:(NSDate *)anotherDate;
- (BOOL)isYearMonthEqualToDate:(NSDate *)anotherDate;
- (BOOL)isComponentDayEqualToDate:(NSDate *)anotherDate;
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;
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

@end

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface NSDate ( Computation )

// Transite by format
+ (NSDate *)fromString:(NSString *)string;
/*
 *  @abstract init a NSDate instance with string
 *
 *  @param dateString: yyyy-MM-dd
 *
 *  @return NSDate instance
 */
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)fmt;

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
- (NSDate *)dateAfterDay:(NSInteger)day; // 返回day天后的日期(若day为负数,则为|day|天前的日期)
- (NSDate *)dateAfterMonth:(int)month; // month个月后的日期

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

@end
