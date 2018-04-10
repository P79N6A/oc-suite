//
//  NSObject+UserDefaults.m
// fallen.ink
//
//  Created by 李杰 on 5/19/15.
//
//

#import "NSObject+UserDefaults.h"

@implementation NSObject (UserDefaults)

- (void)userDefaultsSetObject:(id)value forKey:(NSString *)keyName {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:keyName];
    [ud setObject:value forKey:keyName];
    [ud synchronize];
}

- (id)userDefaultsObjectForKey:(NSString *)keyName {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:keyName];
}

#pragma mark - 

- (void)userDefaultsClear {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
