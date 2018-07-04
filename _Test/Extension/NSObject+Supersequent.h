//
//  NSObject+Supersequent.h
//  wesg
//
//  Created by 7 on 31/07/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//
//  inspired by http://blog.csdn.net/zengconggen/article/details/45558579
//
//  refer to http://www.cocoawithlove.com/2008/03/supersequent-implementation.html
//  do know this: 如果使用invokeSupersequentNoArgs()提示'Too many arguments to function call,expected 0,have 2',设置Build Setting下的Enable Strict Checking of objc_msgSend Calls,设置为NO

#import <objc/runtime.h>
#import <objc/message.h>
#import <Foundation/Foundation.h>

// C function declaration

IMP impOfCallingMethod(id lookupObject, SEL selector);

// Macro definition

#define invokeSupersequent(...) \
        ([self getImplementationOf:_cmd \
            after:impOfCallingMethod(self, _cmd)]) \
                (self, _cmd, ##__VA_ARGS__)

#define invokeSupersequentNoParameters() \
        ([self getImplementationOf:_cmd \
            after:impOfCallingMethod(self, _cmd)]) \
                (self, _cmd)

// Class declaration

@interface NSObject (Supersequent)

- (IMP)getImplementationOf:(SEL)lookup after:(IMP)skip;

@end

// Usage warnings

/**
 
 Warning about these macros
 
 These macros use the IMP in an uncast way. This means that the compiler will treat the method as though it returns id and takes a variable argument list (since this is how an IMP is declared).
 
 If your method returns something that is passed differently to an id (like a double or a struct) or some of your method arguments are structs or integer values shorter than a pointer, then you will need to cast the IMP to the correct signature before using or the parameters won't be passed correctly.
 
 So for a method that takes a char and an unsigned short parameter and returns a double you would need:
 
 ```
 IMP superSequentImp =
 [self getImplementationOf:_cmd after:impOfCallingMethod(self, _cmd)];
 double result =
 ((double(*)(id, SEL, char, unsigned short))superSequentImp)
 (self, _cmd, someChar, someUShort);
 ```
 */
