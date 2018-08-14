
#define color_with_rgba_value( value, a ) \
        [UIColor \
        colorWithRed:((float)((value & 0xFF0000) >> 16))/255.0 \
        green:((float)((value & 0xFF00) >> 8))/255.0 \
        blue:((float)(value & 0xFF))/255.0 \
        alpha:a]
#define color_with_hex( value )             color_with_rgba_value( value, 1.0 )
#define color_with_hexa( value, a )         color_with_rgba_value( value, a )
#define color_with_rgba(r, g, b, a)         [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define color_with_rgb(r, g,  b)            color_with_rgba(r, g, b, 1.0f)

#define color_white                         [UIColor whiteColor]            // 1.0 white
#define color_black                         [UIColor blackColor]            // 0.0 white
#define color_darkGray                      [UIColor darkGrayColor]         // 0.333 white
#define color_lightGray                     [UIColor lightGrayColor]        // 0.667 white
#define color_gray                          [UIColor grayColor]             // 0.5 white
#define color_red                           [UIColor redColor]              // 1.0, 0.0, 0.0 RGB
#define color_green                         [UIColor greenColor]            // 0.0, 1.0, 0.0 RGB
#define color_blue                          [UIColor blueColor]             // 0.0, 0.0, 1.0 RGB
#define color_cyan                          [UIColor cyanColor]             // 0.0, 1.0, 1.0 RGB
#define color_yellow                        [UIColor yellowColor]           // 1.0, 1.0, 0.0 RGB
#define color_magenta                       [UIColor magentaColor]          // 1.0, 0.0, 1.0 RGB
#define color_orange    [UIColor orangeColor]           // 1.0, 0.5, 0.0 RGB
#define color_purple    [UIColor purpleColor]           // 0.5, 0.0, 0.5 RGB
#define color_brown     [UIColor brownColor]            // 0.6, 0.4, 0.2 RGB
#define color_clear     [UIColor clearColor]            // 0.0 white, 0.0 alpha

#define font_gray_1     [UIColor colorWithRGBHex:0xc8c8c8]
#define font_gray_2     [UIColor colorWithRGBHex:0x5e5e5e]
#define font_gray_3     [UIColor colorWithRGBHex:0x1e1e1e]
#define font_gray_4     [UIColor colorWithRGBHex:0x000000]

#define gray_1     [UIColor colorWithRGBHex:0xf7f7f7]
#define gray_2     [UIColor colorWithRGBHex:0xf0f0f0]
#define gray_3     [UIColor colorWithRGBHex:0xebebeb]
#define gray_4     [UIColor colorWithRGBHex:0xcccccc]
#define gray_5     [UIColor colorWithRGBHex:0x999999]
#define gray_6     [UIColor colorWithRGBHex:0x666666]
#define gray_7     [UIColor colorWithRGBHex:0x333333]
#define gray_8     [UIColor colorWithHexString:@"979797"]

// ----------------------------------
// MARK: Custom color
// ----------------------------------

#define color_disabled  [UIColor colorWithHexString:@"BBBBBB"]
