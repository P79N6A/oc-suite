
//  refer to http://www.nshipster.com/at-compile-directives/

#import <Foundation/Foundation.h>

// 指令， 关键字（😄）

@interface _Directive : NSObject

// Interface & Implementation

// @interface...@end
// @implementation...@end

// 类别: @interface Object (...)
// 扩展: @interface Object ()

// Properties

// @property
// @synthesize
// @dynamic

// Foward Class Declarations

// @class

// Instance Variable Visibility

// @public
// @package
// @protected
// @private

// Protocols

// @protocol...@end

// Requirement Options

// @required
// @optional

// Exception Handling

// @try {...@throw exception;...} @catch (e) {} @finally {}

// Literals

// - Object Literals

// @""
// @[]
// @{}
// @() , i.e. NSString for const char *, NSNumber for int, etc.

// - ObjectiveC Literals

// @selector()
// @protocol()

// - C Literals

// @encode()
// @defs()

// Optimizations

// @autoreleasepool {...}
// @synchronized() {...}

// Compatibility

// @compatibility_alias 别名, i.e. PSTCollectionView

// Availibles

// @available(iOS, introduced=9.0) 简写为 @available(iOS 11.0, *)
// introduce=
// deprecated=
// obsoleted=
// message=
// unavailable=
// renamed=

// #available(iOS 8, *) i.e. if #available(iOS 8, *) {...}

// #available() is a run-time check which returns a Boolean, and @available() is a way of generating compile-time warnings/errors

@end
