// weak, 自动变量为 '_'
#define weakly( value ) __unused __weak typeof(value) _ = value;

// 调试代码块
#ifdef DEBUG

#   define LOG( s, ... ) fprintf(stderr,"%s, %d, %s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String]);
#   define debug_code( code_fragment ) { code_fragment }

#else

#   define LOG( s, ... )
#   define debug_code( code_fragment )

#endif

// 大小
#ifndef MAX3
#   define MAX3(a, b, c) ((a) > (b) ? ((a) > (c) ? (a) : (c)) : ((b) > (c) ? (b) : (c)))
#endif

#ifndef MIN3
#   define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))
#endif

// 判断某个方法是否覆写
#define is_method_overrided( _subclass_ , _class_ , _selector_ ) [_subclass_ instanceMethodForSelector:_selector_] != [_class_ instanceMethodForSelector:_selector_]

// 判断某个方法是否实现
#define is_method_implemented( _object_, _method_ ) ([_object_ respondsToSelector:@selector(_method_)])

// 判断某个协议是否被实现
#define is_protocol_implemented( _instance_, _protocol_ ) [_instance_ conformsToProtocol:@protocol(_protocol_)]

// compiler help
#define invalidate_timer( _timer_ ) { [_timer_ invalidate]; _timer_ = nil; }
#define verified_class( _className_ ) ((_className_ *) NSClassFromString(@"" # _className_))

#define nonullify( _obj_, _obj_class_ ) (is_null(_obj_)? instanceof(_obj_class_) :_obj_)

// 判断对象是否null
static inline BOOL is_null(id thing) {
    return thing == nil ||
    ([thing isEqual:[NSNull null]]) ||
    ([thing isKindOfClass:[NSNull class]]);
}

// 判断任何容器是否为空
// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL is_empty(id thing) {
    return thing == nil ||
    ([thing isEqual:[NSNull null]]) ||
    ([thing isKindOfClass:[NSNull class]]) ||
    ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

#define return_if( _exp_ )              if (_exp_) { return; }

// 从 String 到 NSURL
#undef  url_with_string
#define url_with_string( _str_ )        [NSURL URLWithString:_str_]

// 从 String.filePath 到 NSURL
#undef  url_with_filepath
#define url_with_filepath( _path_ )     [NSURL fileURLWithPath:_path_]

#undef  app_set_indicator
#define app_set_indicator( _value_ )    [UIApplication sharedApplication].networkActivityIndicatorVisible = _value_;

#undef  invoke_nullable_block_noarg
#define invoke_nullable_block_noarg( _block_ )  { if (_block_) _block_(); }

#undef  invoke_nullable_block
#define invoke_nullable_block( _block_, ... )   { if (_block_) _block_(__VA_ARGS__); }

#undef  selectorify
#define selectorify( _code_ )                   NSSelectorFromString( @#_code_ )

#define keypathify( __keypath__ ) NSStringFromSelector(@selector(__keypath__))

#define take_nonull( ... ) macro_concat(take_nonull_, macro_count(__VA_ARGS__))( __VA_ARGS__ )
#define take_nonull_0( ... )
#define take_nonull_1( ... )
#define take_nonull_2( a, b )   ( a ? a : b )
#define take_nonull_3( a, b, c ) take_nonull_2( take_nonull_2(a, b), c)

// 类型转换：从 id 到 NSObject

#undef  objectype
#define objectype( _val_ )                      ((NSObject *)_val_)

#undef  stringtype
#define stringtype( _val_ )                     ((NSString *)_val_)

#undef  arraytype
#define arraytype( _val_ )                      ((NSArray *)_val_)

#undef  dictionarytype
#define dictionarytype( _val_ )                 ((NSDictionary *)_val_)

#undef  is_main_thread
#define is_main_thread                          [NSThread isMainThread]

#define view_SafeAreaInsets(view) ({UIEdgeInsets insets; if(@available(iOS 11.0, *)) {insets = view.safeAreaInsets;} else {insets = UIEdgeInsetsZero;} insets;})
