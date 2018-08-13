#import "_Property.h"

#pragma mark -

#define SECOND		(1)
#define MINUTE		(60 * SECOND)
#define HOUR		(60 * MINUTE)
#define DAY			(24 * HOUR)
#define WEEK        (7 * DAY)
#define MONTH		(30 * DAY)
#define YEAR		(12 * MONTH)
#define NOW			[NSDate date]

#define ymdhms      @"yyyy-MM-dd HH:mm:ss"

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
@prop_readonly( NSDate *,       beginningOfDay ); // NSDate convenience methods which shortens some of frequently used formatting and date altering methods.


+ (NSTimeInterval)unixTime;
+ (NSString *)unixDate;
+ (NSDate *)gmtDate; // 格林威治时间 (GMT)
+ (NSTimeInterval)gmtTime;

+ (NSDateFormatter *)format;
+ (NSDateFormatter *)format:(NSString *)format;
+ (NSDateFormatter *)format:(NSString *)format timeZoneGMT:(NSInteger)hours;
+ (NSDateFormatter *)format:(NSString *)format timeZoneName:(NSString *)name;

- (NSString *)toString:(NSString *)format;
- (NSString *)toString:(NSString *)format timeZoneGMT:(NSInteger)hours;
- (NSString *)toString:(NSString *)format timeZoneName:(NSString *)name;

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

@end
