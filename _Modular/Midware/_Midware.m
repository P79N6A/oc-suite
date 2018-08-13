//
//  _Midware.m
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_Midware.h"

@implementation _Midware

@def_singleton( _Midware )

- (_MidwareManager *)manager {
    return  [_MidwareManager sharedInstance];
}

@end
