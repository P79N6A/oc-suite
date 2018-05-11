
#import <objc/runtime.h>
#import "_Encoding.h"
#import "_Foundation.h"

// ----------------------------------
// MARK: C functions
// ----------------------------------

EncodingType __EncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return EncodingType_Unknown;
    size_t len = strlen(type);
    if (len == 0) return EncodingType_Unknown;
    
    EncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= EncodingType_QualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= EncodingType_QualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= EncodingType_QualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= EncodingType_QualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= EncodingType_QualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= EncodingType_QualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= EncodingType_QualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return EncodingType_Unknown | qualifier;
    
    switch (*type) {
        case 'v': return EncodingType_Void | qualifier;
        case 'B': return EncodingType_Bool | qualifier;
        case 'c': return EncodingType_Int8 | qualifier;
        case 'C': return EncodingType_UInt8 | qualifier;
        case 's': return EncodingType_Int16 | qualifier;
        case 'S': return EncodingType_UInt16 | qualifier;
        case 'i': return EncodingType_Int32 | qualifier;
        case 'I': return EncodingType_UInt32 | qualifier;
        case 'l': return EncodingType_Int32 | qualifier;
        case 'L': return EncodingType_UInt32 | qualifier;
        case 'q': return EncodingType_Int64 | qualifier;
        case 'Q': return EncodingType_UInt64 | qualifier;
        case 'f': return EncodingType_Float | qualifier;
        case 'd': return EncodingType_Double | qualifier;
        case 'D': return EncodingType_LongDouble | qualifier;
        case '#': return EncodingType_Class | qualifier;
        case ':': return EncodingType_SEL | qualifier;
        case '*': return EncodingType_CString | qualifier;
        case '^': return EncodingType_Pointer | qualifier;
        case '[': return EncodingType_CArray | qualifier;
        case '(': return EncodingType_Union | qualifier;
        case '{': return EncodingType_Struct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return EncodingType_Block | qualifier;
            else
                return EncodingType_Object | qualifier;
        }
        default: return EncodingType_Unknown | qualifier;
    }
}

// ----------------------------------
// MARK: Source code
// ----------------------------------

@implementation _Encoding

+ (BOOL)isReadOnly:(const char *)attr {
    if ( strstr(attr, "_ro") || strstr(attr, ",R") ) {
        return YES;
    }
    
    return NO;
}

// ----------------------------------
// MARK: Public
// ----------------------------------

+ (EncodingType)typeOfIvar:(Ivar)ivar {
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    
    return __EncodingGetType(typeEncoding);
}

+ (EncodingType)typeOfMethod:(Method)method {
    return EncodingType_Unknown;
}

+ (EncodingType)typeOfPropertyAttribute:(objc_property_attribute_t)attribute {
    return __EncodingGetType(attribute.value);
}

+ (NSString *)typeEncodingOfIvar:(Ivar)ivar {
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    
    return  [NSString stringWithUTF8String:typeEncoding];
}

+ (NSString *)typeEncodingOfPropertyAttribute:(objc_property_attribute_t)attribute {
    return [NSString stringWithUTF8String:attribute.value];
}

// ----------------------------------
// MARK: -
// ----------------------------------

+ (EncodingType)typeOfAttribute:(const char *)attr {
    if ( NULL == attr ) {
        return EncodingType_Unknown;
    }
    
    if ( attr[0] != 'T' )
        return EncodingType_Unknown;
    
    const char * type = &attr[1];
    if ( type[0] == '@' ) {
        if ( type[1] != '"' )
            return EncodingType_Unknown;
        
        char typeClazz[128] = { 0 };
        
        const char * clazzBegin = &type[2];
        const char * clazzEnd = strchr( clazzBegin, '"' );
        
        if ( clazzEnd && clazzBegin != clazzEnd ) {
            unsigned int size = (unsigned int)(clazzEnd - clazzBegin);
            strncpy( &typeClazz[0], clazzBegin, size );
        }
        
        return [self typeOfClassName:typeClazz];
    } else if ( type[0] == '[' ) {
        return EncodingType_Unknown;
    } else if ( type[0] == '{' ) {
        return EncodingType_Unknown;
    } else {
        if ( type[0] == 'c' || type[0] == 'C' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == 'i' || type[0] == 's' || type[0] == 'l' || type[0] == 'q' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == 'I' || type[0] == 'S' || type[0] == 'L' || type[0] == 'Q' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == 'f' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == 'd' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == 'B' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == 'v' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == '*' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == ':' ) {
            return EncodingType_Unknown;
        } else if ( 0 == strcmp(type, "bnum") ){
            return EncodingType_Unknown;
        } else if ( type[0] == '^' ) {
            return EncodingType_Unknown;
        } else if ( type[0] == '?' ) {
            return EncodingType_Unknown;
        } else {
            return EncodingType_Unknown;
        }
    }
    
    return EncodingType_Unknown;
}

+ (EncodingType)typeOfClass:(Class)typeClazz {
    if ( nil == typeClazz ) {
        return EncodingType_Unknown;
    }
    
    const char * className = [[typeClazz description] UTF8String];
    
    return [self typeOfClassName:className];
}

+ (EncodingType)typeOfClassName:(const char *)className {
    if ( nil == className ) {
        return EncodingType_Unknown;
    }
    
#undef	__MATCH_CLASS
#define	__MATCH_CLASS( X ) \
0 == strcmp((const char *)className, "NS" #X) || \
0 == strcmp((const char *)className, "NSMutable" #X) || \
0 == strcmp((const char *)className, "_NSInline" #X) || \
0 == strcmp((const char *)className, "__NS" #X) || \
0 == strcmp((const char *)className, "__NSMutable" #X) || \
0 == strcmp((const char *)className, "__NSCF" #X) || \
0 == strcmp((const char *)className, "__NSCFConstant" #X)
    
    if ( __MATCH_CLASS( Number ) ) {
        return EncodingType_Number;
    } else if ( __MATCH_CLASS( String ) ) {
        return EncodingType_String;
    } else if ( __MATCH_CLASS( Date ) ) {
        return EncodingType_Date;
    } else if ( __MATCH_CLASS( Array ) ) {
        return EncodingType_Array;
    } else if ( __MATCH_CLASS( Set ) ) {
        return EncodingType_Array;
    } else if ( __MATCH_CLASS( Dictionary ) ) {
        return EncodingType_Dict;
    } else if ( __MATCH_CLASS( Data ) ) {
        return EncodingType_Data;
    } else if ( __MATCH_CLASS( URL ) ) {
        return EncodingType_Url;
    }
    
    return EncodingType_Unknown;
}

+ (EncodingType)typeOfObject:(id)obj {
    if ( nil == obj ) {
        return EncodingType_Unknown;
    }
    
    if ( [obj isKindOfClass:[NSNumber class]] ) {
        return EncodingType_Number;
    } else if ( [obj isKindOfClass:[NSString class]] ) {
        return EncodingType_String;
    } else if ( [obj isKindOfClass:[NSDate class]] ) {
        return EncodingType_Date;
    } else if ( [obj isKindOfClass:[NSArray class]] ) {
        return EncodingType_Array;
    } else if ( [obj isKindOfClass:[NSSet class]] ) {
        return EncodingType_Array;
    } else if ( [obj isKindOfClass:[NSDictionary class]] ) {
        return EncodingType_Dict;
    } else if ( [obj isKindOfClass:[NSData class]] ) {
        return EncodingType_Data;
    } else if ( [obj isKindOfClass:[NSURL class]] ) {
        return EncodingType_Url;
    } else {
        const char * className = [[[obj class] description] UTF8String];
        return [self typeOfClassName:className];
    }
}

#pragma mark -

+ (NSString *)classNameOfAttribute:(const char *)attr {
    if ( NULL == attr ) {
        return nil;
    }
    
    if ( attr[0] != 'T' )
        return nil;
    
    const char * type = &attr[1];
    if ( type[0] == '@' ) {
        if ( type[1] != '"' )
            return nil;
        
        char typeClazz[128] = { 0 };
        
        const char * clazz = &type[2];
        const char * clazzEnd = strchr( clazz, '"' );
        
        if ( clazzEnd && clazz != clazzEnd ) {
            unsigned int size = (unsigned int)(clazzEnd - clazz);
            strncpy( &typeClazz[0], clazz, size );
        }
        
        return [NSString stringWithUTF8String:typeClazz];
    }
    
    return nil;
}

+ (NSString *)classNameOfClass:(Class)clazz {
    if ( nil == clazz ) {
        return nil;
    }
    
    const char * className = class_getName( clazz );
    if ( className ) {
        return [NSString stringWithUTF8String:className];
    }
    
    return nil;
}

+ (NSString *)classNameOfObject:(id)obj {
    if ( nil == obj ) {
        return nil;
    }
    
    return [[obj class] description];
}

#pragma mark -

+ (Class)classOfAttribute:(const char *)attr {
    if ( NULL == attr ) {
        return nil;
    }
    
    NSString * className = [self classNameOfAttribute:attr];
    if ( nil == className )
        return nil;
    
    return NSClassFromString( className );
}

#pragma mark -

+ (BOOL)isAtomObject:(id)obj {
    if ( nil == obj ) {
        return NO;
    }
    
    return [self isAtomClass:[obj class]];
}

+ (BOOL)isAtomAttribute:(const char *)attr {
    if ( NULL == attr ) {
        return NO;
    }
    
    NSInteger encoding = [self typeOfAttribute:attr];
    
    if ( EncodingType_Unknown != encoding ) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isAtomClassName:(const char *)clazz {
    if ( NULL == clazz ) {
        return NO;
    }
    
    NSInteger encoding = [self typeOfClassName:clazz];
    
    if ( EncodingType_Unknown != encoding ) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isAtomClass:(Class)clazz {
    if ( nil == clazz ) {
        return NO;
    }
    
    NSInteger encoding = [self typeOfClass:clazz];
    
    if ( EncodingType_Unknown != encoding ) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isObjectClass:(Class)class {
    BOOL flag = class_conformsToProtocol(class, @protocol(NSObject));
    
    if (flag) {
        return flag;
    } else {
        Class superClass = class_getSuperclass(class);
        if (!superClass) {
            return NO;
        } else {
            return  [self isObjectClass:superClass];
        }
    }
}

@end
