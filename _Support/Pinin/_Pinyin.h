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

#import "_precompile.h"
#import "NSString+Pinin.h"
#import "NSArray+Letter.h"
#import "NSString+Letter.h"

EXTERN char pinyinFirstLetter(unsigned short hanzi);

@class PinyinMapObject;

@interface _Pinyin : NSObject

/**
 *  @param chnString 中文汉字
 
 *  @return 全拼
 */
+ (NSString *)pinyinWithLetterChn:(NSString *)chnString;

@end

#pragma mark - 拼音首字母

@interface _Pinyin ( FirstLetter )
/**
 *  @desc
 *  获取汉字首字母，如果参数既不是汉字也不是英文字母，则返回 @“#”
 
 *  @goal
 *  主要用于生成，通讯录右侧的indexes
 */
+ (NSString *)firstLetter:(NSString *)chnString;

/**
 *  @desc
 *  返回参数中所有汉字的首字母，遇到其他字符，则用 # 替换
 
 *  @goal
 *  主要用于生成，通讯录右侧的indexes
 */
+ (NSString *)firstLetters:(NSString *)chnString;


@end

#pragma mark -

@interface PinyinMapObject : NSObject

+ (NSArray<PinyinMapObject *> *)map;

@property (nonatomic, strong) NSString *pinyin; // 拼音
@property (nonatomic, strong) NSString *pinyinChn; // 汉子

@end
