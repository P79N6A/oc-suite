//
//  TimePresenter.h
//  consumer
//
//  Created by fallen on 16/8/24.
//
//

#import <Foundation/Foundation.h>

@interface TimePresenter : NSObject

- (NSDate *)currentDate;

- (void)setDate:(NSDate *)date orSetItNow:(BOOL)setItNow;

- (void)setDefaultTimeZone:(NSTimeZone *)zone;

- (void)setDefaultDateFormatter:(NSDateFormatter *)formatter;

#pragma mark - Week



#pragma mark - Day

/**
 *  Return weekday names, by count, with nameMapper, from now (today)
 *
 *  @param count      how many days of weekday, must 7 elements, and should accord with WeekdayType (from 0!!! so set 0 as placeholder).
 *  @param nameMapper how weekday display its name,like : “周五” “礼拜五” “星期五”
 *
 *  @return names array
 */
- (NSArray *)weekdayNamesWithStart:(int32_t)start count:(int32_t)count nameMapper:(NSArray *)nameMapper;

- (NSArray *)dayDescriptionsWithStart:(int32_t)start count:(int32_t)count formatString:(NSString *)format;

/**
 *  day description with different unit name
 *
 *  @param count like: 14
 *  @param year  like: 年
 *  @param month like: 月
 *  @param day   like: 号
 *
 *  @return 2016年8月19号 ... ( 14 elements )
 */
- (NSArray *)dayDescriptionsWithStart:(int32_t)start
                                count:(int32_t)count
                                 year:(NSString *)year
                                month:(NSString *)month
                                  day:(NSString *)day;

@end
