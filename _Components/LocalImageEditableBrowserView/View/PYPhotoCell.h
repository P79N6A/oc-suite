#import <UIKit/UIKit.h>
@class PYPhoto,PYPhotoView;

@interface PYPhotoCell : UICollectionViewCell

/** 图片模型 */
@property (nonatomic, strong) PYPhoto *photo;

/** 本地相册图片 */
@property (nonatomic, strong) UIImage *image;

/** cell上的photoView */
@property (nonatomic, weak) PYPhotoView *photoView;

/** 放在最底下的contentScrollView(所有子控件都添加在这里) */
@property (nonatomic, weak) UIScrollView *contentScrollView;

/** 快速创建PYPhotoCell的方法 */
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
