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

// from https://github.com/SunilSpaceo/SKTaskManager

@class _Task;

typedef void(^BlockTaskCompletion)(id result);
typedef void(^BlockTask)(id result, BlockTaskCompletion completion);

@interface _TaskManager : NSObject

+ (void)sequenceOperations:(NSMutableArray *)arrOperation completion:(void(^)(void))completion;

+ (void)parallerOperations:(NSMutableArray *)arrOperation completion:(void(^)(void))completion;

@end

@interface _Task : NSObject

@property(copy) BlockTask blockTask;

+(_Task *)taskWithBlock:(BlockTask)blockTask;

@end
