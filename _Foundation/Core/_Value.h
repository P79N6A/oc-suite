//
//  _value.h
//  student
//
//  Created by fallen.ink on 12/12/2017.
//  Copyright © 2017 alliance. All rights reserved.
//
//  refer to http://www.nshipster.com/nsvalue
//  Between C and Objective-C, there is casts, bridges and [boxes]!!
//  Boxing is the process of encapsulating scalars (int,double,BOOL,etc) and value types (struct,enum) with an object container.

//  NSNumber
//  NSArray和NSDictionary不支持存储基本类型，Cocoa提供了NSNumber类类包装基本类型，而NSNumber继承NSValue。
//  通常，将一个基本类型的数据包装成对象，叫做装箱（boxing)；
//  从对象中取出基本类型叫做取消装箱（unboxing）

//  NSValue
//  NSValue 可以包装任意一个对象／数据包，可以用它来将struct存储到NSArray和NSDictionary

//  NSNull
//  在集合中不能存放nil，空
//  如果有些时候，必须要标识 空值，则用 NSNull

#import <Foundation/Foundation.h>

// TODO:

#define valueof_integer( value )    [_Value withInteger:value]

#define valueof_int32( value )      [_Value withLong:value]
#define valueof_int64( value )      [_Value withLongLong:value]

#define valueof_float32( value )    [_Value withFloat:value]
#define valueof_float64( value )    [_Value withDouble:value]

// NSValue, NSNumber
// 请额外关注 _Value, _Directive, _Coder
@interface _Value : NSObject

// NSPointerArray, NSMapTable
+ (NSValue *)withNonretained:(id)object;

//
+ (NSValue *)withRange:(NSRange)range;

// NSNumber
+ (NSValue *)withChar:(char)value;
+ (NSValue *)withUnsignedChar:(unsigned char)value;
+ (NSValue *)withShort:(short)value;
+ (NSValue *)withUnsignedShort:(unsigned short)value;
+ (NSValue *)withInt:(int)value;
+ (NSValue *)withUnsignedInt:(unsigned int)value;
+ (NSValue *)withLong:(long)value;
+ (NSValue *)withUnsignedLong:(unsigned long)value;
+ (NSValue *)withLongLong:(long long)value;
+ (NSValue *)withUnsignedLongLong:(unsigned long long)value;
+ (NSValue *)withFloat:(float)value;
+ (NSValue *)withDouble:(double)value;
+ (NSValue *)withBool:(BOOL)value;
+ (NSValue *)withInteger:(NSInteger)value;
+ (NSValue *)withUnsignedInteger:(NSUInteger)value;

@end
