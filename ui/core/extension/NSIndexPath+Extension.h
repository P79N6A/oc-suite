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

@interface NSIndexPath (Util)

+ (NSArray *)indexPathsInSection:(NSUInteger)section inRange:(NSRange)range;
+ (NSArray *)indexPathsInSection:(NSUInteger)section withIndexes:(NSIndexSet *)indexes;
+ (NSArray *)indexPathsForArrayToAppend:(NSUInteger)appendCount to:(NSUInteger)currentCount;

@end


@interface NSMoveIndexPath : NSObject

@property (nonatomic, readonly) NSIndexPath *from;
@property (nonatomic, readonly) NSIndexPath *to;
+ (instancetype)moveFrom:(NSIndexPath *)initial to:(NSIndexPath *)final;
+ (NSArray *)movesWithInitialIndexPaths:(NSArray *)initial andFinalIndexPaths:(NSArray *)final;

@end
