#import <UIKit/UIKit.h>

@interface PYPhoto : NSObject

// 缩略图：thumbnailUrl;
// 原图：originalUrl;


/** 记录旋转前的大小（只记录最开始的大小） */
@property (nonatomic, assign) CGSize originalSize;

/** 旋转90°或者270°时的宽(默认为屏幕宽度) */
@property (nonatomic, assign) CGFloat verticalWidth;

@end
