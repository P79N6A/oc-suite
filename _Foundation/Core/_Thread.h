
#import "_Precompile.h"
#import "_Property.h"
#import "_Singleton.h"
#import "_Macros.h"

// ----------------------------------
// MARK: - Macros
// ----------------------------------

#define current_thread  [NSThread currentThread]
#define main_thread     [NSThread mainThread]

#ifndef on_main
#define on_main( void_block )     dispatch_async(dispatch_get_main_queue(), void_block);
#endif

/**
 *  Inserts code that executes a block only once, regardless of how many times the macro is invoked.
 *
 *  @param block The block to execute once.
 */
#undef  execute_once
#define execute_once( _block_ ) \
        { \
            static dispatch_once_t predicate; \
            dispatch_once(&predicate, _block_); \
        }

// main

#undef  dispatch_async_foreground
#define dispatch_async_foreground( block ) \
        dispatch_async( dispatch_get_main_queue(), block )

#undef  dispatch_after_foreground
#define dispatch_after_foreground( seconds, block ) \
        dispatch_after( dispatch_time( DISPATCH_TIME_NOW, seconds * 1ull * NSEC_PER_SEC ), dispatch_get_main_queue(), block ); \

#undef  dispatch_barrier_async_foreground
#define dispatch_barrier_async_foreground( seconds, block ) \
        dispatch_barrier_async( [_Queue sharedInstance].concurrent, ^{ \
            dispatch_async_foreground( block ); \
        });

// concurrent

#undef  dispatch_async_background_concurrent
#define dispatch_async_background_concurrent( block ) \
        dispatch_async( [_Queue sharedInstance].concurrent, block )

#undef  dispatch_after_background_concurrent
#define dispatch_after_background_concurrent( seconds, block ) \
        dispatch_after( dispatch_time( DISPATCH_TIME_NOW, seconds * 1ull * NSEC_PER_SEC ), [_Queue sharedInstance].concurrent, block ); \

#undef  dispatch_barrier_async_background_concurrent
#define dispatch_barrier_async_background_concurrent( seconds, block ) \
        dispatch_barrier_async( [_Queue sharedInstance].concurrent, block )

// serial

#undef  dispatch_async_background_serial
#define dispatch_async_background_serial( block ) \
        dispatch_async( [_Queue sharedInstance].serial, block )

#undef  dispatch_after_background_serial
#define dispatch_after_background_serial( seconds, block ) \
        dispatch_after( dispatch_time( DISPATCH_TIME_NOW, seconds * 1ull * NSEC_PER_SEC ), [_Queue sharedInstance].serial, block );

@interface NSThread ( Extension )

+ (BOOL)isMainThread;

+ (void)performBlockOnMainThread:(void (^)(void))block;
+ (void)performBlockInBackground:(void (^)(void))block;

- (void)performBlock:(void (^)(void))block waitUntilDone:(BOOL)wait;
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;


/**
 * Use thread without do clear work.
 */
+ (void)detachNewThreadBlock:(void(^)(void))aBlock;

@end

/**
 *  NSThread+LagDetection.h
 *
 * Created by Florian Agsteiner
 *
 *
 * This Category adds lag detection that can be used to generate Crashreports when a method blocks the main thread for too long.
 *
 * When the main thread timeouts the app will be killed, generating a Crashreport at the current state of the app.
 * Hopefully this crash will point you to a deadlock, wait or sleeping part of the code.
 *
 * Call the methods early (e.g. in IBActions oder other user events) and before your logic, e.g.:
 *
 * - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 *    [NSThread killIfMainThreadIsBlocked];
 *
 *    [self createAndPushViewController];
 * }
 */


/**
 * Adds the method to NSThread
 */
@interface NSThread (LagDetection)

/**
 * Force quits the App when the main thread is blocked for the given duration in seconds.
 */
+ (void)killIfMainThreadIsBlockedForDuration:(NSTimeInterval)duration;

/**
 * Force quits the App when the main thread is blocked for 1 second.
 */
+ (void)killIfMainThreadIsBlocked;

@end
