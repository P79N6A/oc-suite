
#import <Foundation/Foundation.h>

@interface _StringBuilder : NSObject

- (instancetype)initWithString:(NSString *)string;

/**
 *  重复追加
 *
 *  @param part 需要重复的字符串片段
 */
- (void)repeat:(NSString *)part count:(NSUInteger)count;

/**
 *  追加
 *
 *  @param s 字符串
 */
- (void)add:(NSString *)s;

/**
 *  迭代追加字符串
 *
 *  @param objs   字符串数组
 *  @param separator 分隔符
 */
- (void)add:(NSArray *)objs withSeparator:(NSString *)separator;

/**
 *  生成字符串
 *
 *  @return nsstring
 */
- (NSString *)build;

/**
 *  清理
 */
- (void)clear;

#pragma mark - Query

/**
 *  是否为空
 *
 *  @return bool
 */
- (BOOL)empty;

@end
