//
//  NSString+FirstLetter.h
//  HTLetterManger
//
//  Created by Mr.Yang on 13-8-25.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString ( Letter )

- (NSString *)firstLetter;

- (NSString *)firstLetters;

- (NSString *)allLetters;

/**
 *  去名字的特殊字符
 */
- (NSString *)trimSpecialCharacter;

@end
