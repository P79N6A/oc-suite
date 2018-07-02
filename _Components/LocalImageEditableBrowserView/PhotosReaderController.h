#import <UIKit/UIKit.h>
#import "PYConst.h"

@class PYPhotoView, PYPhoto;

@interface PhotosReaderController : UICollectionViewController

/** 网络图片*/
@property (nonatomic, copy) NSArray *photos;

/** 本地相册图片 */
@property (nonatomic, strong) NSMutableArray *images;

// 选择的图片的数组索引
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

/** 选中的照片的view*/
@property (nonatomic, weak) PYPhotoView *selectedPhotoView;

/** 图片分页指示类型(默认为pageControll。当图片超过九张，改为label显示) */
@property (nonatomic, assign) PYPhotosViewPageType pageType;

// 本地图片预览
- (void)configWithImages:(NSArray<UIImage *> *)images selectedIndex:(NSUInteger)selectedIndex;

// 网络图片预览
- (void)configWithPhotos:(NSArray<PYPhoto *> *)photos selectedIndex:(NSUInteger)selectedIndex;

@end
