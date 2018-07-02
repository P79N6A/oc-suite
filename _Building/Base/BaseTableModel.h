//
//  TableModel.h
//  QQing
//
//  Created by fallen.ink on 10/6/15.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// ----------------------------------
// 面向view的数据model
// ----------------------------------

#pragma mark - 上面可以合一，可以作为通用，如下

@interface TableModel : NSObject

@property (nonatomic, assign) BOOL          hasRightArrow;// 是否有右侧箭头
@property (nonatomic, assign) BOOL          isImageView;

@property (nonatomic, strong) NSString *    imageName;      // 默认：nil
@property (nonatomic, strong) NSString *    _2ImageName;    // 二态
@property (nonatomic, strong) NSString *    title;          // 默认：nil
@property (nonatomic, strong) UIColor *     titleColor;
@property (nonatomic, strong) NSString *    detail;         // 默认：nil
@property (nonatomic, strong) UIColor *     detailColor;
@property (nonatomic, strong) NSString *    defaultDetail;  // 默认文字
@property (nonatomic, assign) BOOL          isDetailDefault;// 当model还是显示的默认问题

@property (nonatomic, assign) BOOL          accessable;     // 是否可以展开，默认：YES

@property (nonatomic, assign) BOOL          isAddress;

@property (nonatomic, assign) NSInteger     accessoryType;

@property (nonatomic, assign) NSInteger     tag;            // 用于分辨点击index，默认：0
@property (nonatomic, assign) NSInteger     type;           // 用于区别不同类型的TableViewCell，默认：0

@property (nonatomic, assign) BOOL          expanded;       // 用于标记是否展开状态
@property (nonatomic, assign) CGFloat       expandHeight;   // 追加的高度

// 选择状态
@property (nonatomic, assign) BOOL          selected;

// 有效状态
@property (nonatomic, assign) BOOL          validated;

// 用于尾部图片
// 1. 前后一样，则只需要使用第三个
// 2. 前后不一样，则用前两个
@property (nonatomic, copy) NSString *      accessoryNormal;
@property (nonatomic, copy) NSString *      accessorySelected;
@property (nonatomic, copy) NSString *      accessory;

// Initializer

// enabled 'title'
+ (instancetype)modelWith:(NSString *)title;

// enabled 'title' 'imageName'
+ (instancetype)modelWith:(NSString *)title image:(NSString *)image;

// enabled 'title' 'imageName' 'detail'
+ (instancetype)modelWith:(NSString *)title image:(NSString *)image detail:(NSString *)detail;

+ (instancetype)modelWith:(NSString *)title image:(NSString *)image detail:(NSString *)detail default:(NSString *)defaultDetail;

// enabled 'title' 'imageName' 'tag'
+ (instancetype)modelWith:(NSString *)title image:(NSString *)image tag:(NSUInteger)tag;

// enabled 'title' 'image' 'detail' 'tag'
+ (instancetype)modelWith:(NSString *)title image:(NSString *)image detail:(NSString *)detail tag:(NSInteger)tag;

// Extend field
@property (nonatomic, strong) NSString *placeHolderImageName;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) int64_t id;

@property (nonatomic, assign) BOOL isDefault;

@end

// ----------------------------------
// 面向数据处理的通用model
// ----------------------------------
@interface ItemModel : NSObject

@property (nonatomic, assign) int64_t id;

@property (nonatomic, strong) NSString *code;

@property (nonatomic, strong) NSString *name;

@property (nonatomic,copy) NSString *des;


+ (instancetype)modelWithId:(int64_t)id name:(NSString *)name;
+ (instancetype)modelWithId:(int64_t)id code:(NSString *)code name:(NSString *)name;

@end
