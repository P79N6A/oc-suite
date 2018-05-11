
#import <Foundation/Foundation.h>

// ----------------------------------
// Like Invokation...
// ----------------------------------

// ----------------------------------
// MARK: -
// ----------------------------------

@class _Handler;

@interface NSObject ( BlockHandler )

- (_Handler *)blockHandlerOrCreate;
- (_Handler *)blockHandler;

- (void)addBlock:(id)block forName:(NSString *)name;
- (void)removeBlockForName:(NSString *)name;
- (void)removeAllBlocks;

@end

// ----------------------------------
// MARK: NSMutableDictionary
// ----------------------------------

@interface _Handler : NSObject

- (BOOL)trigger:(NSString *)name;
- (BOOL)trigger:(NSString *)name withObject:(id)object;

- (void)addHandler:(id)handler forName:(NSString *)name;
- (void)removeHandlerForName:(NSString *)name;
- (void)removeAllHandlers;

@end
