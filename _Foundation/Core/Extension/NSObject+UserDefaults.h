//
//  NSObject+UserDefaults.h
// fallen.ink
//
//  Created by 李杰 on 5/19/15.
//

#import <Foundation/Foundation.h>

@interface NSObject ( UserDefaults )

- (void)userDefaultsSetObject:(id)value forKey:(NSString *)keyName;
- (id)userDefaultsObjectForKey:(NSString *)keyName;

#pragma mark -

- (void)userDefaultsClear;

@end
