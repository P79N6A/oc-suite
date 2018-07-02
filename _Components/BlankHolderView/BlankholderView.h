#import <UIKit/UIKit.h>

/**
 *  如果这里是个工厂，更好一些：空页面、错误页面
 */
@interface BlankholderView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) BOOL showLeaveoutPoint;

@property (nonatomic, assign) BOOL isError;

@end
