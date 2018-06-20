//
//  _UserDefaults.m
//  _Foundation
//
//  Created by 7 on 2018/6/20.
//

#import "_UserDefaults.h"

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
