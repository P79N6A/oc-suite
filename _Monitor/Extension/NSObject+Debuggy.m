//
//  NSObject+Debuggy.m
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Debuggy.h"

@implementation NSObject (Debuggy)

+ (void *)replaceSelector:(SEL)sel1 withSelector:(SEL)sel2
{
    Method method = class_getInstanceMethod( self, sel1 );
    
    IMP implement = (IMP)method_getImplementation( method );
    IMP implement2 = class_getMethodImplementation( self, sel2 );
    
    method_setImplementation( method, implement2 );
    
    return (void *)implement;
}

@end
