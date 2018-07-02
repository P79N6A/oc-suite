//
//  _app_user.m
//  student
//
//  Created by fallen.ink on 19/05/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_app_user.h"
#import "_building_tools.h"

@implementation _AppUser

@def_singleton_with(_AppUser, ^{if (!_cache_[stringify(_AppUser)]) {_cache_[stringify(_AppUser)] = [_AppUser new];} return _cache_[stringify(_AppUser)];})

@def_prop_assign( int64_t, id )
@def_prop_strong( NSString *, token )
@def_prop_strong( NSString *, session )

@def_prop_strong( NSString *, orgUuid)

@def_prop_strong( NSString *, firstCity )

@def_prop_strong( NSString *, registrationId)

- (void)clear {
    self.id = 0;
    self.token = nil;
    self.session = nil;
    
    [self save];
}

- (void)save {
    _cache_[stringify(_AppUser)] = self;
}

@end
