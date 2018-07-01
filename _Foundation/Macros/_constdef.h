
// 常用的沙盒目录
#define path_of_app_home    NSHomeDirectory()
#define path_of_temp        NSTemporaryDirectory()
#define path_of_document    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define path_of_library    [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define path_of_cache       [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

// 预设文件存储位置
#define path_to_database    [path_of_cache stringByAppendingPathComponent:@"dbs"]
#define path_to_filecache   [path_of_cache stringByAppendingPathComponent:@"files"]
#define path_to_imagecache  [path_of_cache stringByAppendingPathComponent:@"images"]

#define path_for_png_res( _name_ )    [[NSBundle mainBundle] pathForResource:(_name_) ofType:@"png"]
#define path_for_xml_res( _name_ )    [[NSBundle mainBundle] pathForResource:(_name_) ofType:@"xml"]
#define path_for_res( _res_, _type_)  [[NSBundle mainBundle] pathForResource:(_res_) ofType:(_type_)]

// 特殊数值
#undef  invalid_int32
#define invalid_int32 INT32_MAX

#undef  invalid_int64
#define invalid_int64 INT64_MAX

#undef  invalid_float
#define invalid_float MAXFLOAT

#undef  invalid_bool
#define invalid_bool NO

#undef  MIN_FLOAT
#define MIN_FLOAT 0.000001f

// 特定的字符串

#define empty_string        @""

#undef undefined_string
#define undefined_string @"未定义"

#undef unselected_string
#define unselected_string @"请选择"

// 中文
#define yyyy                @"yyyy"
#define yyyyMM              @"yyyy年MM月"
#define yyyyMMdd            @"yyyy年MM月dd日"
#define MMdd                @"MM月dd日"

// 短横分割线
#define yyyy_MM_dd          @"yyyy-MM-dd"

// inspired by https://github.com/6david9/CBExtension/tree/master/CBExtension/CBExtension/UtilityMacro
/** 一天的秒数 */
#define seconds_of_1day                 (24.f * 60.f * 60.f)
/** 几天的秒数 */
#define seconds_of( value )             (24.f * 60.f * 60.f * (value))
/** 一天的毫秒数 */
#define milliseconds_of_1day            (24.f * 60.f * 60.f * 1000.f)
/** 几天的毫秒数 */
#define milliseconds_of( value )        (24.f * 60.f * 60.f * 1000.f * (value))

