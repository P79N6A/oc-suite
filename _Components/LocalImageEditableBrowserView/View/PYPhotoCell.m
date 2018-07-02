#import "_building_precompile.h"
#import "PYPhotoCell.h"
#import "PYPhoto.h"
#import "PYPhotoView.h"
#import "PYConst.h"
#import "UIImageView+WebCache.h"

@interface PYPhotoCell ()

@end

@implementation PYPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // 创建contentScrollView
        UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
        
        // 取消滑动指示器
        contentScrollView.showsVerticalScrollIndicator = NO;
        contentScrollView.showsHorizontalScrollIndicator = NO;
        self.contentScrollView = contentScrollView;
        [self.contentView addSubview:contentScrollView];
        
        // 创建图片
        PYPhotoView *imageView = [[PYPhotoView alloc] init];
        imageView.isBig = YES;
        imageView.photo = [PYPhoto new];
        
        [self.contentScrollView addSubview:imageView];
        
        self.photoView = imageView;
    }
    return self;
}

- (void)setPhotoView:(PYPhotoView *)photoView {
    _photoView = photoView;
    
    // 绑定photoCell
    photoView.photoCell = self;
}

// 设置图片（图片来源自本地相册）
- (void)setImage:(UIImage *)image {
    _image = image;
    self.photoView.image = image;

    // 取出图片大小
    CGSize imageSize = image.size;
    
    // 放大图片
    self.photoView.width = self.width;
    self.photoView.height = self.width * imageSize.height / imageSize.width;
    self.photoView.center = CGPointMake(self.photoView.width * 0.5, self.photoView.height * 0.5);
    // 设置scrollView的大小
    self.contentScrollView.size = self.photoView.size;
    self.contentScrollView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

// 快速创建collectionCell
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    PYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PYPhotoCell identifier] forIndexPath:indexPath];
    cell.size = CGSizeMake(collectionView.width - ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).minimumLineSpacing, collectionView.height);
    
    return cell;
}

@end
