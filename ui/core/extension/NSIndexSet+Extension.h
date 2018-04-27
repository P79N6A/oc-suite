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

#import <Foundation/Foundation.h>

// inspired by https://github.com/ThePantsThief/Objc-Foundation-Extensions/blob/master/Pod/Classes/NSIndexSet%2BUtil.m

@interface NSIndexSet (Util)

+ (instancetype)indexSetByInvertingRange:(NSRange)range withLength:(NSUInteger)length;
+ (instancetype)indexSetWithoutIndexes:(NSIndexSet *)indexes inRange:(NSRange)range;
+ (instancetype)indexPathsInFirstSectionInCollection:(NSArray<NSIndexPath*> *)collection;

@end
