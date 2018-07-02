#import <UIKit/UIKit.h>

@class PYPhoto, PYPhotoCell, PYPhotoView;

@protocol PYPhotoViewDelegate <NSObject>

@optional
- (void)didSingleClick:(PYPhotoView *)photoView; // 单击
- (void)didLongPress:(PYPhotoView *)photoView;   // 长按

@end

@interface PYPhotoView : UIImageView

@property (nonatomic, weak) id<PYPhotoViewDelegate> delegate;

/** 图片模型 */
@property (nonatomic, strong) PYPhoto *photo;

/** 是否放大状态 */
@property (nonatomic, assign) BOOL isBig;
/** 是否正在预览*/
@property (nonatomic, assign) BOOL isPreview;
/** 是否是视频 */
@property (nonatomic, assign) BOOL isMovie;
/** 原来的frame*/
@property (nonatomic, assign) CGRect orignalFrame;
/** 放大的倍数 */
@property (nonatomic, assign) CGFloat scale;
/** 判断是否是旋转手势 */
@property (nonatomic, assign, getter=isRotationGesture) BOOL rotationGesture;

/** 在window呈现的view*/
@property (nonatomic, strong) PYPhotoView *windowView;

/** 每个photoView的photoCell */
@property (nonatomic, weak) PYPhotoCell *photoCell;

@end
