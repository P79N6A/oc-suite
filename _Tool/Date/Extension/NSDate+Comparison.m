//
//  NSDate+Comparison.m
//  _Foundation
//
//  Created by 7 on 2018/6/20.
//

#import "_Foundation.h"
#import "NSDate+Comparison.h"
#import "NSDate+Computation.h"

@implementation NSDate (Comparison)

- (BOOL)isLeapYear {
    NSUInteger year = [self year];
    if ((year % 4  == 0 && year % 100 != 0) || year % 400 == 0) {
        return YES;
    }
    return NO;
}

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
    return (fabs([self timeIntervalSinceDate:aDate]) < WEEK);
}

- (BOOL)isThisWeek {
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL)isNextWeek {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameYearAsDate:newDate];
}

- (BOOL)isLastWeek {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - WEEK;
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


- (NSString *)timeInfo {
    return [NSDate timeInfoWithDate:self];
}

+ (NSString *)timeInfoWithDate:(NSDate *)date {
    return [self timeInfoWithDateString:[self toString]];
}

+ (NSString *)timeInfoWithDateString:(NSString *)dateString {
    NSDate *date = [NSDate fromString:dateString];
    
    NSDate *curDate = [NSDate date];
    NSTimeInterval time = -[date timeIntervalSinceDate:curDate];
    
    int month = (int)([curDate month] - [date month]);
    int year = (int)([curDate year] - [date year]);
    int day = (int)([curDate day] - [date day]);
    
    NSTimeInterval retTime = 1.0;
    if (time < 3600) { // 小于一小时
        retTime = time / 60;
        retTime = retTime <= 0.0 ? 1.0 : retTime;
        return [NSString stringWithFormat:@"%.0f分钟前", retTime];
    } else if (time < 3600 * 24) { // 小于一天，也就是今天
        retTime = time / 3600;
        retTime = retTime <= 0.0 ? 1.0 : retTime;
        return [NSString stringWithFormat:@"%.0f小时前", retTime];
    } else if (time < 3600 * 24 * 2) {
        return @"昨天";
    }
    // 第一个条件是同年，且相隔时间在一个月内
    // 第二个条件是隔年，对于隔年，只能是去年12月与今年1月这种情况
    else if ((abs(year) == 0 && abs(month) <= 1)
             || (abs(year) == 1 && [curDate month] == 1 && [date month] == 12)) {
        int retDay = 0;
        if (year == 0) { // 同年
            if (month == 0) { // 同月
                retDay = day;
            }
        }
        
        if (retDay <= 0) {
            // 获取发布日期中，该月有多少天
            int totalDays = (int)[self daysInMonth:date month:[date month]];
            
            // 当前天数 + （发布日期月中的总天数-发布日期月中发布日，即等于距离今天的天数）
            retDay = (int)[curDate day] + (totalDays - (int)[date day]);
        }
        
        return [NSString stringWithFormat:@"%d天前", (abs)(retDay)];
    } else  {
        if (abs(year) <= 1) {
            if (year == 0) { // 同年
                return [NSString stringWithFormat:@"%d个月前", abs(month)];
            }
            
            // 隔年
            int month = (int)[curDate month];
            int preMonth = (int)[date month];
            if (month == 12 && preMonth == 12) {// 隔年，但同月，就作为满一年来计算
                return @"1年前";
            }
            return [NSString stringWithFormat:@"%d个月前", (abs)(12 - preMonth + month)];
        }
        
        return [NSString stringWithFormat:@"%d年前", abs(year)];
    }
    
    return @"1小时前";
}


@end
