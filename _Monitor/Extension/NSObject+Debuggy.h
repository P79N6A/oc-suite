//
//  NSObject+Debuggy.h
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Debuggy)

+ (void *)replaceSelector:(SEL)sel1 withSelector:(SEL)sel2;

@end
