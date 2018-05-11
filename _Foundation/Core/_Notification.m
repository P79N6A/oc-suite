
#import "_pragma_push.h"
#import "_Precompile.h"
#import "_Notification.h"
#import "_Runtime.h"

// ----------------------------------
// MARK: -
// ----------------------------------

@implementation NSNotification ( Extension )

- (BOOL)is:(NSString *)name {
    return [self.name isEqualToString:name];
}

- (BOOL)isKindOf:(NSString *)prefix {
    return [self.name hasPrefix:prefix];
}

+ (instancetype)notificationWithName:(NSString *)aName {
    return [NSNotification notificationWithName:aName object:nil];
}

@end

// ----------------------------------
// MARK: -
// ----------------------------------

@implementation NSObject ( NotificationResponder )

- (void)handleNotification:(NSNotification *)notification {
}

- (void)observeNotification:(NSString *)notificationName {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:notificationName
                                                  object:nil];
    
    NSArray * array = [notificationName componentsSeparatedByString:@"."];
    if ( array && array.count > 1 ) {
        //        NSString * prefix = (NSString *)[array objectAtIndex:0];
        NSString * clazz = (NSString *)[array objectAtIndex:1];
        NSString * name = (NSString *)[array objectAtIndex:2];
        
        {
            NSString * selectorName;
            SEL selector;
            
            selectorName = [NSString stringWithFormat:@"handleNotification_%@_%@:", clazz, name];
            selector = NSSelectorFromString(selectorName);
            
            if ( [self respondsToSelector:selector] ) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:selector
                                                             name:notificationName
                                                           object:nil];
                return;
            }
            
            selectorName = [NSString stringWithFormat:@"handleNotification_%@:", clazz];
            selector = NSSelectorFromString(selectorName);
            
            if ( [self respondsToSelector:selector] )
            {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:selector
                                                             name:notificationName
                                                           object:nil];
                return;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:notificationName
                                               object:nil];
}

- (void)observeAllNotifications {
    NSArray * methods = [[self class] methodsWithPrefix:@"handleNotification_" untilClass:[NSObject class]];
    
    if ( nil == methods || 0 == methods.count ) {
        return;
    }
    
    for ( NSString * selectorName in methods ) {
        SEL sel = NSSelectorFromString( selectorName );
        if ( NULL == sel )
            continue;
        
        NSMutableString * notificationName = [self performSelector:sel];
        if ( nil == notificationName  )
            continue;
        
        [self observeNotification:notificationName];
    }
}

- (void)unobserveNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:name
                                                  object:nil];
}

- (void)unobserveAllNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark -

@implementation NSObject (NotificationSender)

+ (BOOL)postNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
    return YES;
}

- (BOOL)postNotification:(NSString *)name {
    return [[self class] postNotification:name];
}

+ (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
    return YES;
}

- (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object {
    return [[self class] postNotification:name withObject:object];
}

/**
 *  @brief  在主线程中发送一条通知
 *
 *  @param notification 一条通知
 */
- (void)postNotificationOnMainThread:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}
/**
 *  @brief  在主线程中发送一条通知
 *
 *  @param aName    用来生成新通知的通知名称
 *  @param anObject 通知携带的对象
 */
- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject
{
    NSNotification *notification = [NSNotification notificationWithName:aName object:anObject];
    [self postNotificationOnMainThread:notification];
}
/**
 *  @brief  在主线程中发送一条通知
 *
 *  @param aName     用来生成新通知的通知名称
 *  @param anObject  通知携带的对象
 *  @param aUserInfo 通知携带的用户信息
 */
- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification = [NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo];
    [self postNotificationOnMainThread:notification];
}

@end

#import "_pragma_pop.h"
