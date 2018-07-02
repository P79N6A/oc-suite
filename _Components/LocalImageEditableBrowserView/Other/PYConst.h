#import <UIKit/UIKit.h>

// TODO: 井字型显示
// TODO: 井字型显示的点击放大

typedef NS_ENUM(NSInteger, PYPhotosViewPageType) { // 分页类型
    PYPhotosViewPageTypeControll = 0, // pageControll（当图片超过九张，改为label显示）
    PYPhotosViewPageTypeLabel = 1  // label
};

// 井字型显示图片的默认值
UIKIT_EXTERN const CGFloat PYPhotoMargin;   // 图片之间的默认间距(默认为5)
UIKIT_EXTERN const CGFloat PYPhotoWidth;    // 图片的默认宽度（默认为70）
UIKIT_EXTERN const CGFloat PYPhotoHeight;   // 图片的默认高度（默认为70）
UIKIT_EXTERN const CGFloat PYPhotosMaxCol;  // 图片每行默认最多个数（默认为3）
UIKIT_EXTERN const CGFloat PYPreviewPhotoSpacing;   // 预览图片时，图片的间距（默认为30）
UIKIT_EXTERN const CGFloat PYPreviewPhotoMaxScale;  // 预览图片时，图片最大放大倍数（默认为2）
UIKIT_EXTERN const CGFloat PYImagesMaxCountWhenWillCompose; // 在发布状态时，最多可以上传的图片张数（默认为9）

/** ---------------自定义通知------------- */
UIKIT_EXTERN NSString *const PYBigImageDidClikedNotification;       // 大图被点击（缩小）
UIKIT_EXTERN NSString *const PYSmallgImageDidClikedNotification;    // 小图被点击（放大）
UIKIT_EXTERN NSString *const PYImagePageDidChangedNotification;     // 浏览过程中的图片被点击（放回原位）
UIKIT_EXTERN NSString *const PYPreviewImagesDidChangedNotification; // 预览图片被点击
UIKIT_EXTERN NSString *const PYChangeNavgationBarStateNotification; // 改变状态栏
UIKIT_EXTERN NSString *const PYAddImageDidClickedNotification;      // 添加图片被点击
UIKIT_EXTERN NSString *const PYCollectionViewDidScrollNotification; // 滚动通知


