
#import <Foundation/Foundation.h>

/**
 *  Get the type from a Type-Encoding string.
 *
 *  @discussion See also:
 *  https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 *  https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 *
 *  @param typeEncoding  A Type-Encoding string.
 *  @return The encoding type.
 */

#pragma mark -

// 枚举值一般是4个字节的int值,在64位系统上是8个字节
typedef enum {
    EncodingType_Mask       = 0xFF, ///< mask of type value
    EncodingType_Unknown    = 0, ///< unknown
    
    // 基础数据与结构
    EncodingType_Void       = 1, ///< void
    EncodingType_Bool       = 2, ///< bool
    EncodingType_Int8       = 3, ///< char / BOOL
    EncodingType_UInt8      = 4, ///< unsigned char
    EncodingType_Int16      = 5, ///< short
    EncodingType_UInt16     = 6, ///< unsigned short
    EncodingType_Int32      = 7, ///< int
    EncodingType_UInt32     = 8, ///< unsigned int
    EncodingType_Int64      = 9, ///< long long
    EncodingType_UInt64     = 10, ///< unsigned long long
    EncodingType_Float      = 11, ///< float
    EncodingType_Double     = 12, ///< double
    EncodingType_LongDouble = 13, ///< long double
    EncodingType_Object     = 14, ///< id
    EncodingType_Class      = 15, ///< Class
    EncodingType_SEL        = 16, ///< SEL
    EncodingType_Block      = 17, ///< block
    EncodingType_Pointer    = 18, ///< void*
    EncodingType_Struct     = 19, ///< struct
    EncodingType_Union      = 20, ///< union
    EncodingType_CString    = 21, ///< char*
    EncodingType_CArray     = 22, ///< char[10] (for example)
    
    // 修饰符
    EncodingType_QualifierMask   = 0xFF00,   ///< mask of qualifier
    EncodingType_QualifierConst  = 1 << 8,  ///< const
    EncodingType_QualifierIn     = 1 << 9,  ///< in
    EncodingType_QualifierInout  = 1 << 10, ///< inout
    EncodingType_QualifierOut    = 1 << 11, ///< out
    EncodingType_QualifierBycopy = 1 << 12, ///< bycopy
    EncodingType_QualifierByref  = 1 << 13, ///< byref
    EncodingType_QualifierOneway = 1 << 14, ///< oneway
    
    // 属性
    EncodingType_PropertyMask         = 0xFF0000, ///< mask of property
    EncodingType_PropertyReadonly     = 1 << 16, ///< readonly
    EncodingType_PropertyCopy         = 1 << 17, ///< copy
    EncodingType_PropertyRetain       = 1 << 18, ///< retain
    EncodingType_PropertyNonatomic    = 1 << 19, ///< nonatomic
    EncodingType_PropertyWeak         = 1 << 20, ///< weak
    EncodingType_PropertyCustomGetter = 1 << 21, ///< getter=
    EncodingType_PropertyCustomSetter = 1 << 22, ///< setter=
    EncodingType_PropertyDynamic      = 1 << 23, ///< @dynamic
    
    // 对象, NSType
    EncodingType_Null,
    EncodingType_Value,
    EncodingType_String,
    EncodingType_MutableString,
    EncodingType_Number,
    EncodingType_DecimalNumber,
    EncodingType_Data,
    EncodingType_MutableData,
    EncodingType_Date,
    EncodingType_Url,
    EncodingType_Array,
    EncodingType_MutableArray,
    EncodingType_Dict,
    EncodingType_MutableDict,
    EncodingType_Set,
    EncodingType_MutableSet,
    
} EncodingType;

#pragma mark -

/**
 *  类型編碼器
 */

@interface _Encoding : NSObject

/**
 *  判斷對象屬性是否為只讀？
 *
 *  @param attr 屬性名稱
 *
 *  @return YES或NO
 */

+ (BOOL)isReadOnly:(const char *)attr;

+ (EncodingType)typeOfAttribute:(const char *)attr;
+ (EncodingType)typeOfClassName:(const char *)clazz;
+ (EncodingType)typeOfClass:(Class)clazz;
+ (EncodingType)typeOfObject:(id)obj;
+ (EncodingType)typeOfIvar:(Ivar)ivar;
+ (EncodingType)typeOfMethod:(Method)method;
+ (EncodingType)typeOfPropertyAttribute:(objc_property_attribute_t)attribute;

+ (NSString *)typeEncodingOfIvar:(Ivar)ivar;
+ (NSString *)typeEncodingOfPropertyAttribute:(objc_property_attribute_t)attribute;

+ (NSString *)classNameOfAttribute:(const char *)attr;
+ (NSString *)classNameOfClass:(Class)clazz;
+ (NSString *)classNameOfObject:(id)obj;

+ (Class)classOfAttribute:(const char *)attr;

+ (BOOL)isAtomAttribute:(const char *)attr;
+ (BOOL)isAtomClassName:(const char *)clazz;
+ (BOOL)isAtomClass:(Class)clazz;
+ (BOOL)isAtomObject:(id)obj;

+ (BOOL)isObjectClass:(Class)class;

@end

