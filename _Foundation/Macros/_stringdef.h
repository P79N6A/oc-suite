
// inspired by https://github.com/ObornJung/OBFoundationLib/blob/master/OBFoundationLib/Macro/OBEncodeMacro.h
#define stringify(string)                @#string

/**
 *  字符串拼接
 *
 *  @param _str_
 *  @param _cat_
 *
 *  @return 拼接结果
 */
#define string_concat( _str_, _cat_ )    (_str_ _cat_)
#define string_concat_3( _str1_, _str2_, _str3_ ) (_str1_ _str2_ _str3_)

/**
 *  字符串是否为空
 */
#define is_string_empty( _str_ )                is_empty( _str_ )

/**
 *  字符串是否可显示
 */
#define is_string_present( _str_ )              !is_string_empty(_str_)

/**
  *  URL到字符串
  */
#define string_format( _format_, ... )          [NSString stringWithFormat:_format_, __VA_ARGS__]
#define string_from_url( _url_ )                [NSString stringWithFormat:@"url = {scheme: %@, host: %@, port: %@, path: %@, relative path: %@, path components as array: %@, parameter string: %@, query: %@, fragment: %@, user: %@, password: %@}", url.scheme, url.host, url.port, url.path, url.relativePath, url.pathComponents, url.parameterString, url.query, url.fragment, url.user, url.password]
#define string_from_charPtr( _charPtr_ )        [NSString stringWithUTF8String:_charPtr_]
#define string_from_type( _type_ )              string_from_charPtr( @encode(_type_) )
#define string_from_int32( _value_ )            [NSString stringWithFormat:@"%d",(int32_t)_value_]
#define string_from_int64( _value_ )            [NSString stringWithFormat:@"%qi", (int64_t)_value_]
#define string_from_obj( _value_ )              [NSString stringWithFormat:@"%@", (NSObject *)_value_]
#define string_from_bool( _bool_ )              [NSString stringWithFormat:@"%d", _bool_]
#define string_from_float( _float_ )            [NSString stringWithFormat:@"%f", _float_]
#define string_from_double( _double_ )          [NSString stringWithFormat:@"%f", _double_]
#define string_from_selector( _selector_ )      NSStringFromSelector(_selector_)
#define string_from_char( _char_ )              [NSString stringWithFormat:@"%c", _char_]
#define string_from_short( _short_ )            [NSString stringWithFormat:@"%hi", _short_]
#define string_from_class( _class_ )            NSStringFromClass(_class_)
#define string_from_point( _point_ )            NSStringFromCGPoint(_point_)
#define string_from_rect( _rect_ )              NSStringFromCGRect(_rect_)
#define string_from_range( _range_ )            NSStringFromRange(_range_)

/**
 *  文件名
 */
#define __FILENAME__    [[string_from_charPtr(__FILE__) lastPathComponent] split:@"."][0]
#define __CMD_SEL__     _cmd
#define __CMD_NAME__    string_from_selector(_cmd)
