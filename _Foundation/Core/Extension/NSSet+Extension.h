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

#import <Foundation/Foundation.h>

@interface NSSet ( Extension )

/**
 *  映射
 */
- (NSSet *)map: (id (^)(id obj))block;

/**
 *  筛选
 */
- (NSSet *)select: (BOOL (^)(id obj))block;

/**
 *  匹配
 */
- (id)match: (BOOL (^)(id obj))block;

/**
 *  遍历
 */
- (void)each:(void (^)(id))block;
- (void)eachWithIndex:(void (^)(id, int))block;

/**
 *  化简
 */
- (id)reduce:(id(^)(id accumulator, id object))block;
- (id)reduce:(id)initial withBlock:(id(^)(id accumulator, id object))block;

/**
 *  排除
 */
- (NSArray *)reject:(BOOL (^)(id object))block;

/**
 *  排序
 */
- (NSArray *)sort;

@end

