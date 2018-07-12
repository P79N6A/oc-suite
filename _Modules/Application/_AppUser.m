
#import <_Tool/_Cache.h>
#import "_AppUser.h"

@implementation _AppUser

@def_singleton_with(_AppUser, ^{if (!cacheInst[stringify(_AppUser)]) {cacheInst[stringify(_AppUser)] = [_AppUser new];} return cacheInst[stringify(_AppUser)];})

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
    cacheInst[stringify(_AppUser)] = self;
}

@end
