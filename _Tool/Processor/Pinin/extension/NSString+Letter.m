//
//  NSString+FirstLetter.m
//  HTLetterManger
//
//  Created by Mr.Yang on 13-8-25.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import "NSString+Letter.h"
#import "_pinyin.h"

@implementation NSString ( Letter )

- (NSString *)firstLetter {
    return [_Pinyin firstLetter:self];
}

- (NSString *)firstLetters {
    return [_Pinyin firstLetters:self];
}

- (NSString *)allLetters {
    return [_Pinyin pinyinWithLetterChn:self];
}

- (NSString *)trimSpecialCharacter {
    NSRange urgentRange = [self rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @",.？、 ~￥#&<>《》()[]{}【】^@/￡¤|§¨「」『』￠￢￣~@#&*（）——+|《》$_€"]];
    if (urgentRange.location != NSNotFound) {
        return [self trimSpecialCharacter];
    }
    return self;
}

#pragma mark - Private

- (NSString *)trimSpecialCharacter:(NSString *)srcString {
    NSRange urgentRange = [srcString rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @",.？、 ~￥#&<>《》()[]{}【】^@/￡¤|§¨「」『』￠￢￣~@#&*（）——+|《》$_€"]];
    if (urgentRange.location != NSNotFound) {
        return [self trimSpecialCharacter:[srcString stringByReplacingCharactersInRange:urgentRange withString:@""]];
    }
    return srcString;
}

@end
