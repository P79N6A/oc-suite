#import <Foundation/Foundation.h>

@interface NSObject ( UserDefaults )

- (void)userDefaultsSetObject:(id)value forKey:(NSString *)keyName;
- (id)userDefaultsObjectForKey:(NSString *)keyName;

#pragma mark -

- (void)userDefaultsClear;

@end
