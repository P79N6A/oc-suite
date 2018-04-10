//
//  extobjc.h
//  extobjc
//
//  Created by Justin Spahr-Summers on 2010-11-09.
//  Copyright (C) 2012 Justin Spahr-Summers.
//  Released under the MIT license.
//

#import "EXTADT.h"
#import "EXTConcreteProtocol.h"
#import "EXTKeyPathCoding.h"
#import "EXTNil.h"
#import "EXTSafeCategory.h"
#import "EXTScope.h"
#import "EXTSelectorChecking.h"
#import "EXTSynthesize.h"
#import "NSInvocation+EXT.h"
#import "NSMethodSignature+EXT.h"

/**
 
 Features
 libextobjc currently includes the following features:
 
 Safe categories, using EXTSafeCategory, for adding methods to a class without overwriting anything already there (identifying conflicts for you).
 Concrete protocols, using EXTConcreteProtocol, for providing default implementations of the methods in a protocol.
 Simpler and safer key paths, using EXTKeyPathCoding, which automatically checks key paths at compile-time.
 Compile-time checking of selectors to ensure that an object declares a given selector, using EXTSelectorChecking.
 Easier use of weak variables in blocks, using @weakify, @unsafeify, and @strongify from the EXTScope module.
 Scope-based resource cleanup, using @onExit in the EXTScope module, for automatically cleaning up manually-allocated memory, file handles, locks, etc., at the end of a scope.
 Algebraic data types generated completely at compile-time, defined using EXTADT.
 Synthesized properties for categories, using EXTSynthesize.
 Block-based coroutines, using EXTCoroutine.
 EXTNil, which is like NSNull, but behaves much more closely to actual nil (i.e., doesn't crash when sent unrecognized messages).
 Lots of extensions and additional functionality built on top of <objc/runtime.h>, including extremely customizable method injection, reflection upon object properties, and various functions to extend class hierarchy checks and method lookups.
 
 */