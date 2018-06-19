//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/    /__|       \/____/
//
//	Copyright BinaryArtists development team and other contributors
//
//	https://github.com/BinaryArtists/suite.great
//
//	Free to use, prefer to discuss!
//
//  Welcome!
//

#import "NSDateFormatter+Extension.h"
#import "NSDate+Extension.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSDate(Extension)

#pragma mark - Decomposing Dates

@def_prop_dynamic( NSInteger,	year );
@def_prop_dynamic( NSInteger,	month );
@def_prop_dynamic( NSInteger,	day );
@def_prop_dynamic( NSInteger,	hour );
@def_prop_dynamic( NSInteger,	minute );
@def_prop_dynamic( NSInteger,	second );
@def_prop_dynamic( NSInteger,	weekday );
@def_prop_dynamic( NSInteger,	week );
@def_prop_dynamic( NSInteger,	nthWeekday );
@def_prop_dynamic( NSInteger,   totalDaysInMonth )
@def_prop_dynamic( NSDate *,    beginningOfMonth );
@def_prop_dynamic( NSDate *,    endOfMonth );
@def_prop_dynamic( NSDate *,    beginningOfDaytime );
@def_prop_dynamic( NSString *,     weekStringOfXingQi );
@def_prop_dynamic( NSString *,     weekStringOfZhou );
@def_prop_dynamic( NSString *,  formattedTime );
@def_prop_dynamic( NSDate *,       firstWeekDayInMonth );

@def_prop_dynamic( NSDate *,       beginningOfDay );
@def_prop_dynamic( NSDate *,       endOfDay );
@def_prop_dynamic( NSDate *,       beginningOfWeek );
@def_prop_dynamic( NSDate *,       endOfWeek );
@def_prop_dynamic( NSDate *,       beginningOfYear );
@def_prop_dynamic( NSDate *,       endOfYear );

#pragma mark - Decomposing Dates

- (NSInteger) nearestHour {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitHour fromDate:newDate];
    return components.hour;
}

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
- (NSInteger)nthWeekday {// e.g. 2nd Tuesday of the month is 2
    
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components weekdayOrdinal];
}

- (NSDate *)beginningOfMonth {
    return [self dateAfterDay:-[self day] + 1];
}

- (NSDate *)endOfMonth {
    return [[[self beginningOfMonth] dateAfterMonth:1] dateAfterDay:-1];
}

- (NSDate *)beginningOfDaytime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self];
    
    [dateComponent setHour:0];
    [dateComponent setMinute:0];
    [dateComponent setSecond:0];
    
    return [calendar dateFromComponents:dateComponent];
}

- (NSString *)weekStringOfXingQi {
    WeekdayType type = [self weekday];
    
    if (type == WeekdayType_Sunday) {
        return @"星期日";
    } else {
        NSArray *weekdays = @[@"placeholder", @"placeholder", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
        
        return [weekdays objectAtIndex:type];
    }
}

- (NSString *)weekStringOfZhou {
    WeekdayType type = [self weekday];
    
    if (type == WeekdayType_Sunday) {
        return @"周日";
    } else {
        NSArray *weekdays = @[@"placeholder", @"placeholder", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
        
        return [weekdays objectAtIndex:type];
    }
}

/*标准时间日期描述*/
- (NSString *)formattedTime {
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(8,2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(5,2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
    
    NSCalendar *gregorian = CURRENT_CALENDAR;
    NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间
    
    NSInteger hour = [self hoursAfterDate:date];
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";
    
    //hasAMPM==TURE为12小时制，否则为24小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    
    if (!hasAMPM) { //24小时制
        if (hour <= 24 && hour >= 0) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
        }else if (hour < 0 && hour >= -24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天HH:mm"];
        }else {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd HH:mm"];
        }
    } else {
        if (hour >= 0 && hour <= 6) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"凌晨hh:mm"];
        }else if (hour > 6 && hour <=11 ) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"上午hh:mm"];
        }else if (hour > 11 && hour <= 17) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"下午hh:mm"];
        }else if (hour > 17 && hour <= 24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"晚上hh:mm"];
        }else if (hour < 0 && hour >= -24){
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天HH:mm"];
        }else  {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd HH:mm"];
        }
    }
    
    ret = [dateFormatter stringFromDate:self];
    return ret;
}

- (NSUInteger)firstWeekDayInMonth {
    NSCalendar *gregorian = CURRENT_CALENDAR;
    [gregorian setFirstWeekday:2]; //1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    
    //Set date to first of month
    NSDateComponents *comps = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                           fromDate:self];
    [comps setDay:1];
    NSDate *newDate = [gregorian dateFromComponents:comps];
    
    return [gregorian ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:newDate];
}

- (NSDate *)beginningOfDay {
    NSCalendar *calendar = CURRENT_CALENDAR;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    NSDateComponents *components;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];
#pragma clang diagnostic pop
    }
#else
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];
#endif
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfDay {
    NSCalendar *calendar = CURRENT_CALENDAR;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    
    return [[calendar dateByAddingComponents:components toDate:[self beginningOfDay] options:0] dateByAddingTimeInterval:-1];
}

- (NSDate *)beginningOfWeek {
    NSCalendar *calendar = CURRENT_CALENDAR;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    NSDateComponents *components;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday|NSCalendarUnitDay fromDate:self];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit|NSDayCalendarUnit fromDate:self];
#pragma clang diagnostic pop
    }
#else
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |NSWeekdayCalendarUnit| NSDayCalendarUnit fromDate:self];
#endif
    
    NSUInteger offset = ([components weekday] == [calendar firstWeekday]) ? 6 : [components weekday] - 2;
    [components setDay:[components day] - offset];
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    NSCalendar *calendar = CURRENT_CALENDAR;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfMonth:1];
    
    return [[calendar dateByAddingComponents:components toDate:[self beginningOfWeek] options:0] dateByAddingTimeInterval:-1];
}

- (NSDate *)beginningOfYear {
    NSCalendar *calendar = CURRENT_CALENDAR;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    NSDateComponents *components;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        components = [calendar components:NSCalendarUnitYear   fromDate:self];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        components = [calendar components:NSYearCalendarUnit  fromDate:self];
#pragma clang diagnostic pop
    }
#else
    NSDateComponents *components = [calendar components:NSYearCalendarUnit  fromDate:self];
#endif
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfYear {
    NSCalendar *calendar = CURRENT_CALENDAR;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:1];
    
    return [[calendar dateByAddingComponents:components toDate:[self beginningOfYear] options:0] dateByAddingTimeInterval:-1];
}

#pragma mark -

- (NSInteger)totalDaysInMonth {
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return totaldaysInMonth.length;
}

+ (NSTimeInterval)unixTime {
    return [[NSDate date] timeIntervalSince1970];
}

+ (NSString *)unixDate {
    return [[NSDate date] toString:@"yyyy/MM/dd HH:mm:ss z"];
}

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

/*
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */
+ (NSString *)compareCurrentTime:(NSDate *) compareDate {
    NSTimeInterval timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long long temp = 0;
    NSString *result;
    if (timeInterval < 0) {
        result = [compareDate toString:@"MM月dd日"];
    } else if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    } else if((temp = timeInterval/60) <60) {
        result = [NSString stringWithFormat:@"%lld分钟前",temp];
    } else if((temp = temp/60) <24) {
        result = [NSString stringWithFormat:@"%lld小时前",temp];
    } else if((temp = temp/24) <30) {
        result = [NSString stringWithFormat:@"%lld天前",temp];
    } else if((temp = temp/30) <12) {
        result = [NSString stringWithFormat:@"%lld月前",temp];
    } else {
        temp = temp/12;
        result = [NSString stringWithFormat:@"%lld年前",temp];
    }
    return  result;
}

@end

#pragma mark Comparing Dates

@implementation NSDate ( Comparison )

+ (BOOL)isLeapYear:(NSInteger)year {
    NSAssert(!(year < 1), @"invalid year number");
    
    BOOL leap = FALSE;
    if ((0 == (year % 400))) {
        leap = TRUE;
    }
    else if((0 == (year%4)) && (0 != (year % 100))) {
        leap = TRUE;
    }
    return leap;
}

- (BOOL)isYearMonthDayEqualToDate:(NSDate *)anotherDate {
    NSCalendar *gregorian = CURRENT_CALENDAR;
    NSDateComponents *components1 = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    NSDateComponents *components2 = nil;
    if (anotherDate) {
        components2 = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:anotherDate];
    }
    return ((components1.day == components2.day) && (components1.month == components2.month) && (components1.year == components2.year));
}

- (BOOL)isYearMonthEqualToDate:(NSDate *)anotherDate {
    NSCalendar *gregorian = CURRENT_CALENDAR;
    NSDateComponents *components1 = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = nil;
    if (anotherDate) {
        components2 = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:anotherDate];
    }
    return ((components1.month == components2.month) && (components1.year == components2.year));
}

- (BOOL)isComponentDayEqualToDate:(NSDate *)anotherDate {
    NSCalendar *gregorian = CURRENT_CALENDAR;
    NSDateComponents *components1 = [gregorian components:NSCalendarUnitDay fromDate:self];
    NSDateComponents *components2 = nil;
    if (anotherDate) {
        components2 = [gregorian components:NSCalendarUnitDay fromDate:anotherDate];
    }
    
    return ([components1 day] == [components2 day]);
}

- (BOOL)isDayEqualToDate:(NSDate *)anotherDate {
    return [self day] != [anotherDate day] ? NO : YES;
}

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return (([components1 year] == [components2 year]) &&
            ([components1 month] == [components2 month]) &&
            ([components1 day] == [components2 day]));
}

- (BOOL)isToday {
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isTomorrow {
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL)isYesterday {
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL)isSameWeekAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if ([components1 weekOfYear] != [components2 weekOfYear]) return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL)isThisWeek {
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL)isNextWeek {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameYearAsDate:newDate];
}

- (BOOL)isLastWeek {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameYearAsDate:newDate];
}

- (BOOL)isSameYearAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:aDate];
    return ([components1 year] == [components2 year]);
}

- (BOOL)isThisYear {
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL)isNextYear {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return ([components1 year] == ([components2 year] + 1));
}

- (BOOL)isLastYear {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return ([components1 year] == ([components2 year] - 1));
}

- (BOOL)isEarlierThanDate:(NSDate *)aDate {
    return ([self earlierDate:aDate] == self);
}

- (BOOL)isLaterThanDate:(NSDate *)aDate {
    return ([self laterDate:aDate] == self);
}

#pragma mark - 判断日期

// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) isThisMonth {
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL) isInFuture {
    return ([self isLaterThanDate:[NSDate date]]);
}

- (BOOL) isInPast {
    return ([self isEarlierThanDate:[NSDate date]]);
}


#pragma mark - 周末和工作日

- (BOOL) isTypicallyWeekend {
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitWeekday fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday {
    return ![self isTypicallyWeekend];
}


@end

@implementation NSDate ( Computation )

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

#pragma mark Relative Dates

+ (NSDate *)dateWithDaysFromNow:(NSUInteger)days {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithDaysBeforeNow:(NSUInteger)days {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateTomorrow {
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *)dateYesterday {
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *)dateWithHoursFromNow:(NSUInteger)dHours {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithHoursBeforeNow:(NSUInteger)dHours {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithMinutesFromNow:(NSUInteger)dMinutes {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithMinutesBeforeNow:(NSUInteger)dMinutes {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSString *)description {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    
    return [formatter stringFromDate:self];
}

- (NSString *)debugDescription {
    return [self description];
}

- (NSString *)descriptionWithLocale:(id)locale {
    return [self description];
}

+ (NSDate *)dateFromSecond:(NSInteger)second minute:(NSInteger)minute hour:(NSInteger)hour day:(NSInteger)day month:(NSInteger)month year:(NSInteger)year {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    
    [components setSecond:second];
    [components setMinute:minute];
    [components setHour:hour];
    [components setDay:day];
    
    if (month <= 0) {
        [components setMonth:12-month];
        [components setYear:year-1];
    } else if (month >= 13) {
        [components setMonth:month-12];
        [components setYear:year+1];
    } else {
        [components setMonth:month];
        [components setYear:year];
    }
    
    
    return [calendar dateFromComponents:components];
}

+ (NSDate *)dateFromHour:(NSInteger)hour day:(NSInteger)day month:(NSInteger)month year:(NSInteger)year {
    return [NSDate dateFromSecond:0 minute:0 hour:hour day:day month:month year:year];
}

+ (NSDate *)dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year {
    NSCalendar *calendar = CURRENT_CALENDAR;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    
    [components setDay:day];
    
    if (month <= 0) {
        [components setMonth:12-month];
        [components setYear:year-1];
    } else if (month >= 13) {
        [components setMonth:month-12];
        [components setYear:year+1];
    } else {
        [components setMonth:month];
        [components setYear:year];
    }
    
    
    return [NSDate dateWithNoTime:[calendar dateFromComponents:components] middleDay:NO];
}

+ (NSDate *)dateWithNoTime:(NSDate *)dateTime middleDay:(BOOL)middle {
    if( dateTime == nil ) {
        dateTime = [NSDate date];
    }
    
    NSCalendar       *calendar   = CURRENT_CALENDAR;
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                             fromDate:dateTime];
    
    NSDate *dateOnly = [calendar dateFromComponents:components];
    
    if (middle)
        dateOnly = [dateOnly dateByAddingTimeInterval:(60.0 * 60.0 * 12.0)];           // Push to Middle of day.
    
    return dateOnly;
}

+ (NSDate *)dateFromLongLong:(long long)msSince1970 {
    return [NSDate dateWithTimeIntervalSince1970:msSince1970 / 1000];
}

#pragma mark Adjusting Dates

- (NSDate *)dateByAddingDays:(NSUInteger)dDays {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingDays:(NSUInteger)dDays {
    return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *)dateByAddingHours:(NSUInteger)dHours {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingHours:(NSUInteger)dHours {
    return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *)dateByAddingMinutes:(NSUInteger)dMinutes {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingMinutes:(NSUInteger)dMinutes {
    return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *)dateAtStartOfDay {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate {
    NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}

- (NSDate *)dateAfterDay:(NSInteger)day {
    // Get the weekday component of the current date
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    // to get the end of week for a particular date, add (7 - weekday) days
    [componentsToAdd setDay:day];
    NSDate *dateAfterDay = [CURRENT_CALENDAR dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    return dateAfterDay;
}

- (NSDate *)dateAfterMonth:(int)month {
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setMonth:month];
    
    NSDate *dateAfterMonth = [CURRENT_CALENDAR dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    return dateAfterMonth;
}

#pragma mark - Retrieving Intervals

- (NSInteger)minutesAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_MINUTE);
}

- (NSInteger)minutesBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_MINUTE);
}

- (NSInteger)hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_HOUR);
}

- (NSInteger)hoursBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_HOUR);
}

- (NSInteger)daysAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger)(ti / D_DAY);
}

- (NSInteger)daysBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger)(ti / D_DAY);
}

#pragma mark -

+ (NSInteger)numberOfDaysInMonth:(NSInteger)month {
    return [NSDate numberOfDaysInMonth:month year:[NSDate new].year];
}

+ (NSInteger)numberOfDaysInMonth:(NSInteger)month year:(NSInteger) year {
    NSAssert(!(month < 1||month > 12), @"invalid month number");
    NSAssert(!(year < 1), @"invalid year number");
    month = month - 1;
    static int daysOfMonth[12] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    NSInteger days = daysOfMonth[month];
    /*
     * feb
     */
    if (month == 1) {
        if ([NSDate isLeapYear:year]) {
            days = 29;
        }
        else {
            days = 28;
        }
    }
    return days;
}

@end
