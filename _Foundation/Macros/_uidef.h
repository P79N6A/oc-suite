#import "_colordef.h"
#import "_fontdef.h"

/**
 *  inspired by https://github.com/guanghuili/TODATY/blob/master/iHistory/iHistory/Macro/UIMacro.h
 */

// ----------------------------------
// 系统屏幕
// ----------------------------------
#define screen_bounds                   [[UIScreen mainScreen] bounds]
#define screen_size                     screen_bounds.size
#define screen_width                    [[UIScreen mainScreen] bounds].size.width
#define screen_height                   [[UIScreen mainScreen] bounds].size.height
#define screen_scale                    [[UIScreen mainScreen] scale]
#define border_width                    (1.0 / screen_scale)

#define app_frame                       [[UIScreen mainScreen] applicationFrame]
#define app_frame_height                ([[UIScreen mainScreen] applicationFrame].size.height)
#define app_frame_width                 ([[UIScreen mainScreen] applicationFrame].size.width)

// ----------------------------------
// 系统控件基础定义，如：导航栏、状态栏、标签栏
// ----------------------------------
#define is_iPhoneX (screen_width == 375.f && screen_height == 812.f ? YES : NO)

#define status_bar_height      (is_iPhoneX ? 44.f : 20.f)
#define navigation_bar_height           44.f
#define navigation_status_bar_height    (status_bar_height+navigation_bar_height)
#define large_navigation_bar_height     96.f
#define large_navigation_status_bar_height (status_bar_height+large_navigation_bar_height)

#define keyboard_height                 216.f

#define tabbar_height         (is_iPhoneX ? (49.f+34.f) : 49.f)
#define tabbar_safe_bottom_margin         (is_iPhoneX ? 34.f : 0.f)
#define status_bar_navigation_bar_height  (is_iPhoneX ? 88.f : 64.f)

#define separator_height                8

#define status_bar_orientation          [[UIApplication sharedApplication] statusBarOrientation]

#define iPhone4_4s     (screen_width == 320.f && screen_height == 480.f ? YES : NO)
#define iPhone5_5s     (screen_width == 320.f && screen_height == 568.f ? YES : NO)
#define iPhone6_6s     (screen_width == 375.f && screen_height == 667.f ? YES : NO)
#define iPhone6_6sPlus (screen_width == 414.f && screen_height == 736.f ? YES : NO)

// ----------------------------------
// 间隔与边距基础定义
// ----------------------------------

#define PIXEL_sss                       0.5f
#define PIXEL_1                         1.f
#define PIXEL_3                         3.f
#define PIXEL_2                         2.f
#define PIXEL_4                         4.f
#define PIXEL_5                         5.f
#define PIXEL_6                         6.f
#define PIXEL_8                         8.f
#define PIXEL_10                        10.f
#define PIXEL_12                        12.f
#define PIXEL_16                        16.f
#define PIXEL_24                        24.f
#define PIXEL_36                        36.f
#define PIXEL_40                        40.f
#define PIXEL_48                        48.f
#define PIXEL_56                        56.f

#define margin_l    PIXEL_16
#define margin_m    PIXEL_8
#define margin_s    PIXEL_4

//=========================
// 底边栏的按钮

//  主级按钮：整行1按钮 major
//  次级按钮：整行2按钮 minor

// 只举例了，挂在下面，单一的大按钮的样式，其他各自VC中定义：
// const static CGFloat kXXXXXXXX   = ....;
//=========================

#define kDefaultButtonMargin            PIXEL_12    // 上下左右边距都是它

#define ButtonHeight_M                  51.f

#define DefaultCellHeight               51.f

#define CellHeight_S                    40.f
#define CellHeight_M                    51.f
#define CellHeight_T                    70.f

#define BarHeight                       48.f

//=========================
// 分割线
//=========================

#define kDefaultSeperatorWidth          0.5f // 0.5f 也是 系统导航栏 下部边线的宽度
#define kDefaultBorderWidth             0.5f

// ----------------------------------
// 字体基础定义
// ----------------------------------
#define POUND_9                         9.f// 24, PS 大小
#define POUND_13                        13.f// 36???
#define POUND_14                        14.f// 36
#define POUND_15                        15.f// 40 ＊＊＊
#define POUND_18                        18.f// 48 ＊＊＊
#define POUND_23                        23.f// 60

#define POUND_7                         7.f // 18
#define POUND_11                        11.f// 30 ＊＊＊
#define POUND_12                        12.f// 32

// system font
#define FONT_9                          [UIFont systemFontOfSize:POUND_9]
#define FONT_13                         [UIFont systemFontOfSize:POUND_13]
#define FONT_14                         [UIFont systemFontOfSize:POUND_14]
#define FONT_15                         [UIFont systemFontOfSize:POUND_15]
#define FONT_18                         [UIFont systemFontOfSize:POUND_18]
#define FONT_23                         [UIFont systemFontOfSize:POUND_23]

#define font_sm                         font_normal_9
#define font_ss                         font_normal_11
#define font_s                          font_normal_14
#define font_m                          font_normal_15
#define font_l                          font_normal_18
#define font_xl                         font_normal_23

//粗体
#define bold_font_ss                    font_bold_11
#define bold_font_s                     font_bold_14
#define bold_font_m                     font_bold_15
#define bold_font_l                     font_bold_18
#define bold_font_xl                    font_bold_23

// 定义UIImage对象
#define image_named( _pointer_ )        [UIImage imageNamed:_pointer_]
#define image_pathof( _path_ )          [UIImage imageWithContentsOfFile:(path)]
#define png_image( _name_ )             [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(_name_) ofType:@"png"]]
#define jpg_image( _name_ )             [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(_name_) ofType:@"jpg"]]

