//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/     \_|       \/____/
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

@implementation NSDateFormatter (Category)

+ (id)dateFormatter {
    return [[self alloc] init];
}

+ (id)dateFormatterWithFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[self alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (id)defaultDateFormatter {
    return [self dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

#pragma mark -

- (NSDateFormatter *)withLocaleType:(LocaleType)type {
    [self setLocaleType:type];
    
    return self;
}

- (NSDateFormatter *)withFormat:(NSString *)dateFormat {
    self.dateFormat = dateFormat;
    
    return self;
}

#pragma mark - Private

- (void)setLocaleType:(LocaleType)locale {
    switch (locale) {
        case LocaleType_EN: {
            NSLocale *zh_Locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [self setLocale:zh_Locale];
        }
            break;
            
        case LocaleType_ZH: {
            NSLocale *zh_Locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            [self setLocale:zh_Locale];
        }
            break;
            
        default:
            break;
    }
}

@end

#pragma mark - 

@implementation NSDateFormatter (ChiSymbols)

- (NSArray *)chiSingleWeekdaySymbols {
    return [NSArray arrayWithObjects:@"一", @"二", @"三", @"四", @"五", @"六", @"日", nil];
}

- (NSArray *)chiZhouWeekdaySymbols {
    return [NSArray arrayWithObjects:@"周一", @"周二", @"周三", @"周四", @"周五", @"周六", @"周日", nil];
}

- (NSArray *)chiXingQiWeekdaySymbols {
    return [NSArray arrayWithObjects:@"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", @"星期日", nil];
}

- (NSArray *)chiLiBaiWeekdaySymbols {
    return [NSArray arrayWithObjects:@"礼拜一", @"礼拜二", @"礼拜三", @"礼拜四", @"礼拜五", @"礼拜六", @"礼拜天", nil];
}

@end


