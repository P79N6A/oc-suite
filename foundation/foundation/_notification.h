
#import <Foundation/Foundation.h>

// ----------------------------------
// MARK: -
// ----------------------------------

#undef  notification
#define notification( name ) \
        static_property( name )

#undef  def_notification
#define def_notification( name ) \
        def_static_property2( name, @"notification", NSStringFromClass([self class]) )

#undef  def_notification_alias
#define def_notification_alias( name, alias ) \
        alias_static_property( name, alias )

#undef  makeNotification
#define makeNotification( ... ) \
        macro_string( macro_join(notification, __VA_ARGS__) )

#undef  handleNotification
#define handleNotification( ... ) \
        - (void) macro_join( handleNotification, __VA_ARGS__):(NSNotification *)notification

#undef  notification_nameof_int
#define notification_nameof_int( _int_value_ ) \
        ([NSString stringWithFormat:@"notification.temp.%ld", (long)_int_value_])

// ----------------------------------
// MARK: -
// ----------------------------------

typedef NSObject *	(^ _NotificationBlock )( NSString * name, id object );

// ----------------------------------
// MARK: -
// ----------------------------------

@protocol ManagedNotification <NSObject>
@end

typedef NSNotification NotificationType;

// ----------------------------------
// MARK: -
// ----------------------------------

@interface NSNotification ( Extension )

- (BOOL)is:(NSString *)name;
- (BOOL)isKindOf:(NSString *)prefix;

+ (instancetype)notificationWithName:(NSString *)aName;

@end

// ----------------------------------
// MARK: -
// ----------------------------------

@interface NSObject ( NotificationResponder )

- (void)handleNotification:(NSNotification *)notification; // 通知响应函数模板 ^_^

/**
 * 隐性约定：
 *
 *
 */
- (void)observeNotification:(NSString *)name;
- (void)observeAllNotifications;

- (void)unobserveNotification:(NSString *)name;
- (void)unobserveAllNotifications;

@end

// ----------------------------------
// MARK: -
// ----------------------------------

@interface NSObject ( NotificationSender )

+ (BOOL)postNotification:(NSString *)name;
- (BOOL)postNotification:(NSString *)name;

+ (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object;
- (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object;

- (void)postNotificationOnMainThread:(NSNotification *)notification;
- (void)postNotificationOnMainThreadName:(NSString *)name object:(id)object;
- (void)postNotificationOnMainThreadName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end

