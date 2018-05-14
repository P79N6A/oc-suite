//
//  _cache_domain.h
//  kata
//
//  Created by fallen.ink on 19/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import <Foundation/Foundation.h>

/// -initWithSuiteName: initializes an instance of NSUserDefaults that searches the shared preferences search list for the domain 'suitename'. For example, using the identifier of an application group will cause the receiver to search the preferences for that group. Passing the current application's bundle identifier, NSGlobalDomain, or the corresponding CFPreferences constants is an error. Passing nil will search the default search list.
//- (nullable instancetype)initWithSuiteName:(nullable NSString *)suitename NS_AVAILABLE(10_9, 7_0) NS_DESIGNATED_INITIALIZER;

/// -initWithUser: is equivalent to -init
//- (nullable id)initWithUser:(NSString *)username NS_DEPRECATED(10_0, 10_9, 2_0, 7_0);


@interface _CacheDomain : NSObject

@end
