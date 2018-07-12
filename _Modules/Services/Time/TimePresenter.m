//
//  TimePresenter.m
//  consumer
//
//  Created by fallen on 16/8/24.
//
//

#import "_greats.h"
#import "_date.h"
#import "TimePresenter.h"

@interface TimePresenter ()

@property (nonatomic, strong) NSDate *date;
//@property (nonatomic, strong) NSFormatter

@end

@implementation TimePresenter

- (instancetype)init {
    if (self = [super init]) {
        self.date = [NSDate date];
    }
    
    return self;
}

#pragma mark - Config

- (NSDate *)currentDate {
    return self.date;
}

- (void)setDate:(NSDate *)date orSetItNow:(BOOL)setItNow {
    
}

- (void)setDefaultTimeZone:(NSTimeZone *)zone {
    
}

- (void)setDefaultDateFormatter:(NSDateFormatter *)formatter {
    
}


#pragma mark - Day

- (NSArray *)weekdayNamesWithStart:(int32_t)start count:(int32_t)count nameMapper:(NSArray *)nameMapper {
    NSAssert(nameMapper, @"nameMaper should be nil");
    NSAssert(nameMapper.count > 7, @"nameMapper count should more than 7");
    
    NSMutableArray *names = [NSMutableArray new];
    
    for (int i = start; i < count + start; i++) {
        if (i) {
            NSDate *date = [self.date dateByAddingDays:i];
            
            [names addObject:[nameMapper objectAtIndex:date.weekday]];
        } else {
            [names addObject:[nameMapper objectAtIndex:self.date.weekday]];
        }
    }
    
    return names;
}

- (NSArray *)dayDescriptionsWithStart:(int32_t)start count:(int32_t)count formatString:(NSString *)format {
    NSMutableArray *descriptions = [NSMutableArray new];
    
    for (int i = start; i < start+count; i++) {
        if (i) {
            NSDate *date = [self.date dateByAddingDays:i];
            
            [descriptions addObject:[date toString:format]];
        } else {
            [descriptions addObject:[self.date toString:format]];
        }
    }
    
    return descriptions;
}

- (NSString *)stringWithDate:(NSDate *)date year:(NSString *)year month:(NSString *)month day:(NSString *)day {
    NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
    
    if ([year notEmpty]) [string appendFormat:@"%@%@", @(date.year), year];
    if ([month notEmpty]) [string appendFormat:@"%@%@", @(date.month), month];
    if ([day notEmpty]) [string appendFormat:@"%@%@", @(date.day), day];
    
    return string;
}

- (NSArray *)dayDescriptionsWithStart:(int32_t)start count:(int32_t)count year:(NSString *)year month:(NSString *)month day:(NSString *)day {
    NSMutableArray *descriptions = [NSMutableArray new];
    
    for (int i = start; i < start + count; i++) {
        if (i) {
            NSDate *date = [self.date dateByAddingDays:i];
            NSString *desc = [self stringWithDate:date year:year month:month day:day];
            
            [descriptions addObject:desc];
        } else {
            NSString *desc = [self stringWithDate:self.date year:year month:month day:day];
            [descriptions addObject:desc];
        }
    }
    
    return descriptions;
}

@end
