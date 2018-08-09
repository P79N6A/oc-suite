
#import "NSNumber+Extension.h"

@implementation NSNumber (JKRound)

- (NSString *)toDisplayNumberWithDigit:(NSInteger)digit {
    NSString *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    
    result = [formatter  stringFromNumber:self];
    
    if (result == nil)
        return @"";
    
    return result;
}

- (NSString *)toDisplayPercentageWithDigit:(NSInteger)digit {
    NSString *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    
    result = [formatter  stringFromNumber:self];
    
    return result;
}

/**
 *  @brief  四舍五入
 *
 *  @param digit  限制最大位数
 *
 *  @return 结果
 */
- (NSNumber *)doRoundWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    [formatter setMinimumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

/**
 *  @brief  取上整
 *
 *  @param digit  限制最大位数
 *
 *  @return 结果
 */
- (NSNumber *)doCeilWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    [formatter setMaximumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

/**
 *  @brief  取下整
 *
 *  @param digit  限制最大位数
 *
 *  @return 结果
 */
- (NSNumber *)doFloorWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundFloor];
    [formatter setMaximumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

- (void)times:(void (^)())block {
    NSParameterAssert(block != nil);
    
    for (NSInteger idx = 0 ; idx < self.integerValue ; ++idx ) {
        block();
    }
}

@end
