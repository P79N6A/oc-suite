
#import "_Handler.h"
#import "_Property.h"
#import "_pragma_push.h"

// ----------------------------------
// MARK: Source code
// ----------------------------------

#pragma mark -

typedef void (^ __handlerBlockType )( id object );

#pragma mark -

@implementation NSObject ( BlockHandler )

- (_Handler *)blockHandlerOrCreate {
    _Handler * handler = [self getAssociatedObjectForKey:"blockHandler"];
    
    if ( nil == handler ) {
        handler = [[_Handler alloc] init];
        
        [self retainAssociatedObject:handler forKey:"blockHandler"];
    }
    
    return handler;
}

- (_Handler *)blockHandler {
    return [self getAssociatedObjectForKey:"blockHandler"];
}

- (void)addBlock:(id)block forName:(NSString *)name {
    _Handler * handler = [self blockHandlerOrCreate];
    
    if ( handler ) {
        [handler addHandler:block forName:name];
    }
}

- (void)removeBlockForName:(NSString *)name {
    _Handler * handler = [self blockHandler];
    
    if ( handler ) {
        [handler removeHandlerForName:name];
    }
}

- (void)removeAllBlocks {
    _Handler * handler = [self blockHandler];
    
    if ( handler ) {
        [handler removeAllHandlers];
    }
    
    [self removeAssociatedObjectForKey:"blockHandler"];
}

@end

// ----------------------------------
// MARK: -
// ----------------------------------

@implementation _Handler {
    NSMutableDictionary * _blocks;
}

- (id)init {
    self = [super init];
    if ( self ) {
        _blocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_blocks removeAllObjects];
    _blocks = nil;
}

- (BOOL)trigger:(NSString *)name {
    return [self trigger:name withObject:nil];
}

- (BOOL)trigger:(NSString *)name withObject:(id)object {
    if ( nil == name )
        return NO;
    
    __handlerBlockType block = (__handlerBlockType)[_blocks objectForKey:name];
    if ( nil == block )
        return NO;
    
    block( object );
    return YES;
}

- (void)addHandler:(id)handler forName:(NSString *)name {
    if ( nil == name )
        return;
    
    if ( nil == handler ) {
        [_blocks removeObjectForKey:name];
    } else {
        [_blocks setObject:handler forKey:name];
    }
}

- (void)removeHandlerForName:(NSString *)name {
    if ( nil == name )
        return;
    
    [_blocks removeObjectForKey:name];
}

- (void)removeAllHandlers {
    [_blocks removeAllObjects];
}

@end

// ----------------------------------
// MARK: Unit test
// ----------------------------------

#if __TESTING__

TEST_CASE( Foundation, Handler )

DESCRIBE( before )
{
}

DESCRIBE( after )
{
}

TEST_CASE_END

#endif	// #if __TESTING__

#import "_pragma_pop.h"

