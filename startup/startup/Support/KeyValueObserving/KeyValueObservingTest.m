//
//  KeyValueObservingTest.m
//  startup
//
//  Created by 7 on 2018/7/12.
//  Copyright © 2018 7. All rights reserved.
//

#import <_Support/KeyValueObserving.h>
#import <_Foundation/_Foundation.h>
#import "KeyValueObservingTest.h"

@interface Person : NSObject
@property int32_t age;
@property NSString *name;
@end

@implementation Person

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return [super automaticallyNotifiesObserversForKey:key];
}

@end

TEST_CASE( KeyValueObserving, UnitExample )
{
    Person *_person;
}

DESCRIBE( Usage )
{
    _person = [Person new];
    
    
//    [self observe:_person
//              for:@"age"
//             with:^(id obj, NSString *key, id oldValue, id newValue) {
//                 LOG(@"obj(%@), key(%@), old(%@), new(%@)", obj, key, oldValue, newValue);
//             }];
    
    [self observe:_person
              for:@"name"
             with:^(id obj, NSString *key, id oldValue, id newValue) {
                 LOG(@"obj(%@), key(%@), old(%@), new(%@)", obj, key, oldValue, newValue);
             }];
    
//    [_person observeForKeyPath:@"age" block:^(id obj, id oldVal, id newVal) {
//        LOG(@"obj(%@), old(%@), new(%@)", obj, oldVal, newVal);
//    }];
//
    _person.age = 10;

    _person.age = 11000;

    _person.age = 9999;
    
    _person.name = @"ddddd";
    
    _person.name = @"bbbbb";
    
    _person.name = @"aaaaa";
    
//    [self unobserve:_person for:@"age"];
    
//    [self unobserve:_person for:@"name"];
}


TEST_CASE_END
