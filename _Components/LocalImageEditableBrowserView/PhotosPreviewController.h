#import "PYConst.h"
#import "PYPhoto.h"
#import "PYPhotoView.h"
#import "PhotosReaderController.h"

@class PhotosPreviewController;

@protocol PhotosPreviewControllerDelegate <NSObject>

@optional
- (void)photosPreviewController:(PhotosPreviewController *)previewController didImagesChanged:(NSMutableArray *)images;

@end

// 本地图片预览
@interface PhotosPreviewController : PhotosReaderController

@property (nonatomic, weak) id<PhotosPreviewControllerDelegate> delegate;

+ (instancetype)previewController;

- (void)showInViewController:(UIViewController *)viewController;

@end
