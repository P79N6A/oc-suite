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

#import "NSDateFormatter+Extension.h"
#import "NSDate+Extension.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSDate(Extension)

#pragma mark - Decomposing Dates

@def_prop_dynamic( NSInteger,	year )
@def_prop_dynamic( NSInteger,	month )
@def_prop_dynamic( NSInteger,	day )
@def_prop_dynamic( NSInteger,	hour )
@def_prop_dynamic( NSInteger,	minute )
@def_prop_dynamic( NSInteger,	second )
@def_prop_dynamic( NSInteger,	weekday )
@def_prop_dynamic( NSInteger,	week )
@def_prop_dynamic( NSInteger,   beginningOfDay)

- (NSInteger)year {
    return [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self].year;
}

- (NSInteger)month {
    return [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self].month;
}

- (NSInteger)day {
    return [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self].day;
}

- (NSInteger)hour {
    return [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self].hour;
}

- (NSInteger)minute {
    return [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self].minute;
}

- (NSInteger)second {
    return [[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self].second;
}

- (WeekdayType)weekday {
    return (WeekdayType)[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self].weekday;
}

- (NSInteger)week {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components weekOfYear];
}

- (NSDate *)beginningOfDay {
    NSDateComponents *components = [CURRENT_CALENDAR components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ) fromDate:self];
    NSDate *absDate = [CURRENT_CALENDAR dateFromComponents:components];
    NSInteger gmtOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
    
    return [NSDate dateWithTimeInterval:gmtOffset sinceDate:absDate];
}

/////// MARK: -

+ (NSTimeInterval)unixTime {
    return [[NSDate date] timeIntervalSince1970];
}

+ (NSString *)unixDate {
    return [[NSDate date] toString:@"yyyy/MM/dd HH:mm:ss z"];
}

+ (NSDate *)gmtDate {
    NSDate * now = [NSDate date];
    NSInteger gmtOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
    return [NSDate dateWithTimeInterval:gmtOffset sinceDate:now];
}

+ (NSTimeInterval)gmtTime {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return [localeDate timeIntervalSince1970];
}

////// MARK:

+ (NSDateFormatter *)format {
    return [self format:@"yyyy/MM/dd HH:mm:ss z"];
}

+ (NSDateFormatter *)format:(NSString *)format {
    return [self format:format timeZoneGMT:[[NSTimeZone defaultTimeZone] secondsFromGMT]];
}

+ (NSDateFormatter *)format:(NSString *)format timeZoneGMT:(NSInteger)seconds {
    static __strong NSMutableDictionary * __formatters = nil;
    
    if ( nil == __formatters ) {
        __formatters = [[NSMutableDictionary alloc] init];
    }
    
    NSString * key = [NSString stringWithFormat:@"%@ %ld", format, (long)seconds];
    NSDateFormatter * formatter = [__formatters objectForKey:key];
    if ( nil == formatter ) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:format];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:seconds]];
        [__formatters setObject:formatter forKey:key];
    }
    
    return formatter;
}

+ (NSDateFormatter *)format:(NSString *)format timeZoneName:(NSString *)name {
    static __strong NSMutableDictionary * __formatters = nil;
    
    if ( nil == __formatters ) {
        __formatters = [[NSMutableDictionary alloc] init];
    }
    
    NSString * key = [NSString stringWithFormat:@"%@ %@", format, name];
    NSDateFormatter * formatter = [__formatters objectForKey:key];
    if ( nil == formatter ) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:format];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:name]];
        [__formatters setObject:formatter forKey:key];
    }
    
    return formatter;
}

#pragma mark -

- (NSString *)toString:(NSString *)format {
    return [self toString:format timeZoneGMT:[[NSTimeZone defaultTimeZone] secondsFromGMT]];
}

- (NSString *)toString:(NSString *)format timeZoneGMT:(NSInteger)seconds {
    return [[NSDate format:format timeZoneGMT:seconds] stringFromDate:self];
}

- (NSString *)toString:(NSString *)format timeZoneName:(NSString *)name {
    return [[NSDate format:format timeZoneName:name] stringFromDate:self];
}


+ (NSDate *)fromString:(NSString *)string {
    if ( nil == string || 0 == string.length )
        return nil;
    
    NSDate * date = [[NSDate format:@"yyyy/MM/dd HH:mm:ss z"] dateFromString:string];
    if ( nil == date ) {
        date = [[NSDate format:@"yyyy-MM-dd HH:mm:ss z"] dateFromString:string];
        if ( nil == date ) {
            date = [[NSDate format:@"yyyy-MM-dd HH:mm:ss"] dateFromString:string];
            if ( nil == date ) {
                date = [[NSDate format:@"yyyy/MM/dd HH:mm:ss"] dateFromString:string];
            }
        }
    }
    
    return date;
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:dateString];
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)fmt {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:fmt];
    return [formatter dateFromString:dateString];
}

- (NSString *)dateOfStringWithFormatOfGMT8:(NSString *)fmt {
    // to fix alipay bug
    NSTimeZone* gmt8Zone = [NSTimeZone timeZoneForSecondsFromGMT:3600*8];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:gmt8Zone];
    [formatter setDateFormat:fmt];
    return [formatter stringFromDate:self];
}

@end
