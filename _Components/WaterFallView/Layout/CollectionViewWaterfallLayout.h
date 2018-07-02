//
//  UICollectionViewWaterfallLayout.h
//
//  Created by Nelson on 12/11/19.
//  Copyright (c) 2012 Nelson Tai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Enumerated structure to define direction in which items can be rendered.
 */
typedef NS_ENUM (NSUInteger, CollectionViewWaterfallLayoutItemRenderDirection) {
  CollectionViewWaterfallLayoutItemRenderDirectionShortestFirst,
  CollectionViewWaterfallLayoutItemRenderDirectionLeftToRight,
  CollectionViewWaterfallLayoutItemRenderDirectionRightToLeft
};

/**
 *  Constants that specify the types of supplementary views that can be presented using a waterfall layout.
 */

/// A supplementary view that identifies the header for a given section.
extern NSString *const CollectionElementKindSectionHeader;
/// A supplementary view that identifies the footer for a given section.
extern NSString *const CollectionElementKindSectionFooter;

#pragma mark - CollectionViewDelegateWaterfallLayout

@class CollectionViewWaterfallLayout;

/**
 *  The CollectionViewDelegateWaterfallLayout protocol defines methods that let you coordinate with a
 *  CollectionViewWaterfallLayout object to implement a waterfall-based layout.
 *  The methods of this protocol define the size of items.
 *
 *  The waterfall layout object expects the collection view’s delegate object to adopt this protocol.
 *  Therefore, implement this protocol on object assigned to your collection view’s delegate property.
 */
@protocol CollectionViewDelegateWaterfallLayout <UICollectionViewDelegate>
@required
/**
 *  Asks the delegate for the size of the specified item’s cell.
 *
 *  @param collectionView
 *    The collection view object displaying the waterfall layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param indexPath
 *    The index path of the item.
 *
 *  @return
 *    The original size of the specified item. Both width and height must be greater than 0.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the delegate for the column count in a section
 *
 *  @param collectionView
 *    The collection view object displaying the waterfall layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param section
 *    The section.
 *  @param item
 *      如果是－1，则传该section最大列数
 *
 *  @return
 *    The original column count for that section. Must be greater than 0.
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section item:(NSInteger)item;

@optional

/**
 *  Asks the delegate for the height of the header view in the specified section.
 *
 *  @param collectionView
 *    The collection view object displaying the waterfall layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param section
 *    The index of the section whose header size is being requested.
 *
 *  @return
 *    The height of the header. If you return 0, no header is added.
 *
 *  @discussion
 *    If you do not implement this method, the waterfall layout uses the value in its headerHeight property to set the size of the header.
 *
 *  @see
 *    headerHeight
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;

/**
 *  Asks the delegate for the height of the footer view in the specified section.
 *
 *  @param collectionView
 *    The collection view object displaying the waterfall layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param section
 *    The index of the section whose header size is being requested.
 *
 *  @return
 *    The height of the footer. If you return 0, no footer is added.
 *
 *  @discussion
 *    If you do not implement this method, the waterfall layout uses the value in its footerHeight property to set the size of the footer.
 *
 *  @see
 *    footerHeight
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section;

/**
 * Asks the delegate for the insets in the specified section.
 *
 * @param collectionView
 *   The collection view object displaying the waterfall layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose insets are being requested.
 *
 * @discussion
 *   If you do not implement this method, the waterfall layout uses the value in its sectionInset property.
 *
 * @return
 *   The insets for the section.
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

/**
 * Asks the delegate for the header insets in the specified section.
 *
 * @param collectionView
 *   The collection view object displaying the waterfall layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose header insets are being requested.
 *
 * @discussion
 *   If you do not implement this method, the waterfall layout uses the value in its headerInset property.
 *
 * @return
 *   The headerInsets for the section.
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForHeaderInSection:(NSInteger)section;

/**
 * Asks the delegate for the footer insets in the specified section.
 *
 * @param collectionView
 *   The collection view object displaying the waterfall layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose footer insets are being requested.
 *
 * @discussion
 *   If you do not implement this method, the waterfall layout uses the value in its footerInset property.
 *
 * @return
 *   The footerInsets for the section.
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForFooterInSection:(NSInteger)section;

/**
 * Asks the delegate for the minimum spacing between two items in the same column
 * in the specified section. If this method is not implemented, the
 * minimumInteritemSpacing property is used for all sections.
 *
 * @param collectionView
 *   The collection view object displaying the waterfall layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose minimum interitem spacing is being requested.
 *
 * @discussion
 *   If you do not implement this method, the waterfall layout uses the value in its minimumInteritemSpacing property to determine the amount of space between items in the same column.
 *
 * @return
 *   The minimum interitem spacing.
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

/**
 * Asks the delegate for the minimum spacing between colums in a secified section. If this method is not implemented, the
 * minimumColumnSpacing property is used for all sections.
 *
 * @param collectionView
 *   The collection view object displaying the waterfall layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose minimum interitem spacing is being requested.
 *
 * @discussion
 *   If you do not implement this method, the waterfall layout uses the value in its minimumColumnSpacing property to determine the amount of space between columns in each section.
 *
 * @return
 *   The minimum spacing between each column.
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section;

@end

#pragma mark - CollectionViewWaterfallLayout

/**
 *  The CollectionViewWaterfallLayout class is a concrete layout object that organizes items into waterfall-based grids
 *  with optional header and footer views for each section.
 *
 *  A waterfall layout works with the collection view’s delegate object to determine the size of items, headers, and footers
 *  in each section. That delegate object must conform to the `CollectionViewDelegateWaterfallLayout` protocol.
 *
 *  Each section in a waterfall layout can have its own custom header and footer. To configure the header or footer for a view,
 *  you must configure the height of the header or footer to be non zero. You can do this by implementing the appropriate delegate
 *  methods or by assigning appropriate values to the `headerHeight` and `footerHeight` properties.
 *  If the header or footer height is 0, the corresponding view is not added to the collection view.
 *
 *  @note CollectionViewWaterfallLayout doesn't support decoration view, and it supports vertical scrolling direction only.
 */
@interface CollectionViewWaterfallLayout : UICollectionViewLayout

/**
 *  @brief The minimum spacing to use between successive columns.
 *  @discussion Default: 10.0
 */
@property (nonatomic, assign) CGFloat minimumColumnSpacing;

/**
 *  @brief The minimum spacing to use between items in the same column.
 *  @discussion Default: 10.0
 *  @note This spacing is not applied to the space between header and columns or between columns and footer.
 */
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

/**
 *  @brief Height for section header
 *  @discussion
 *    If your collectionView's delegate doesn't implement `collectionView:layout:heightForHeaderInSection:`,
 *    then this value will be used.
 *
 *    Default: 0
 */
@property (nonatomic, assign) CGFloat headerHeight;

/**
 *  @brief Height for section footer
 *  @discussion
 *    If your collectionView's delegate doesn't implement `collectionView:layout:heightForFooterInSection:`,
 *    then this value will be used.
 *
 *    Default: 0
 */
@property (nonatomic, assign) CGFloat footerHeight;

/**
 *  @brief The margins that are used to lay out the header for each section.
 *  @discussion
 *    These insets are applied to the headers in each section.
 *    They represent the distance between the top of the collection view and the top of the content items
 *    They also indicate the spacing on either side of the header. They do not affect the size of the headers or footers themselves.
 *
 *    Default: UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets headerInset;

/**
 *  @brief The margins that are used to lay out the footer for each section.
 *  @discussion
 *    These insets are applied to the footers in each section.
 *    They represent the distance between the top of the collection view and the top of the content items
 *    They also indicate the spacing on either side of the footer. They do not affect the size of the headers or footers themselves.
 *
 *    Default: UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets footerInset;

/**
 *  @brief The margins that are used to lay out content in each section.
 *  @discussion
 *    Section insets are margins applied only to the items in the section.
 *    They represent the distance between the header view and the columns and between the columns and the footer view.
 *    They also indicate the spacing on either side of columns. They do not affect the size of the headers or footers themselves.
 *
 *    Default: UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets sectionInset;

/**
 *  @brief The direction in which items will be rendered in subsequent rows.
 *  @discussion
 *    The direction in which each item is rendered. This could be left to right (CollectionViewWaterfallLayoutItemRenderDirectionLeftToRight), right to left (CollectionViewWaterfallLayoutItemRenderDirectionRightToLeft), or shortest column fills first (CollectionViewWaterfallLayoutItemRenderDirectionShortestFirst).
 *
 *    Default: CollectionViewWaterfallLayoutItemRenderDirectionShortestFirst
 */
@property (nonatomic, assign) CollectionViewWaterfallLayoutItemRenderDirection itemRenderDirection;

/**
 *  @brief The minimum height of the collection view's content.
 *  @discussion
 *    The minimum height of the collection view's content. This could be used to allow hidden headers with no content.
 *
 *    Default: 0.f
 */
@property (nonatomic, assign) CGFloat minimumContentHeight;

/**
 *  @brief The calculated width of an item in the specified section.
 *  @discussion
 *    The width of an item is calculated based on number of columns, the collection view width, and the horizontal insets for that section.
 */
- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section item:(NSInteger)item;

@end

//
//
// 用法

// 创建与初始化
//CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
//
////        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//layout.headerHeight = kCellHeaderHeight;
//layout.footerHeight = 0;
////        layout.minimumColumnSpacing = kInformationCellGap;
////        layout.minimumInteritemSpacing = kInformationCellGap;
//
//_collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
//_collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
////        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 12, 0);
//_collectionView.dataSource = self;
//_collectionView.delegate = self;
//_collectionView.backgroundColor = [UIColor whiteColor];
//
//UINib *nib = [HomeCollectionHeader nib];
//NSString *identifier = [HomeCollectionHeader identifier];
//[_collectionView registerNib:nib
//  forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
//         withReuseIdentifier:identifier];
//
//[_collectionView registerClass:[UICollectionReusableView class]
//    forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
//           withReuseIdentifier:[UICollectionReusableView identifier]];
//
//[_collectionView registerNib:[MasterSubscribeInfoCell nib]
//  forCellWithReuseIdentifier:[MasterSubscribeInfoCell identifier]];
//
//[_collectionView registerNib:[RecommendCategoryCell nib]
//  forCellWithReuseIdentifier:[RecommendCategoryCell identifier]];
//
//[_collectionView registerNib:[RecommendContentCell nib]
//  forCellWithReuseIdentifier:[RecommendContentCell identifier]];
//
//[_collectionView registerClass:[UICollectionViewCell class]
//    forCellWithReuseIdentifier:[UICollectionViewCell identifier]];
//
//[self.view addSubview:_collectionView];

// 代理方法的实现
//#pragma mark - CHTCollectionViewDelegateWaterfallLayout
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return CGSizeMake(screen_width, kBannerListHeight);
//    }
//    if (indexPath.section == 1) {
//        //        Snapshot *info = [_masterAds safeObjectAtIndex:0];
//        // 大师订阅
//        //        return [MasterSubscribeInfoCell cellSizeWithModel:info];
//        return CGSizeMake(screen_width, 90);;
//    } else if (indexPath.section == 2) {
//        return [RecommendCategoryCell cellSizeWithModel:nil];
//    } else if (indexPath.section == 3) {
//        Snapshot *info = [_selectedAds safeObjectAtIndex:indexPath.item];
//        
//        // 美发急诊室
//        //        return [RecommendContentCell cellSizeWithModel:info];
//        
//        CGFloat width = kInformationCellWidth;
//        
//        if (!info || !info.width || !info.height) {
//            return CGSizeMake(width, 220);
//        }
//        
//        //        LOG(@"cell size cal = %@", snapshot);
//        
//        // 限制两行 ，所以限制 66 (因为加了行距)
//        
//        CGFloat height = kInformationCellWidth + 90;
//        return CGSizeMake(width, height);
//    } else if (indexPath.section == 4) {
//        
//        Snapshot *info = [_puppyAds safeObjectAtIndex:indexPath.item];
//        
//        // 狗仔日记
//        return [MasterSubscribeInfoCell cellSizeWithModel:info];
//    } else if (indexPath.section == 5) {
//        id model = [self.home.snapshotList safeObjectAtIndex:indexPath.item];
//        
//        // 疯狂头发
//        return [RecommendContentCell cellSizeWithModel:model];
//    }
//    
//    return CGSizeZero;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section item:(NSInteger)item {
//    if (section == 0) {
//        return 1;
//    }
//    if (section == 1) {
//        // 大师订阅
//        return 1;
//    } else if (section == 2) {
//        return 1;
//    }  else if (section == 3) {
//        // 美发急诊室
//        return 2;
//    } else if (section == 4) {
//        // 狗仔日记
//        
//        return 1;
//    } else if (section == 5) {
//        // 疯狂头发
//        return 2;
//    }
//    
//    return 0;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    CGFloat spacing = 0.f;
//    
//    switch (section) {
//        case 0:
//        case 1:
//        case 2:
//        case 3:
//        case 4:
//            spacing = 0.f;
//            break;
//            
//        case 5:
//            spacing = 8.f;
//            
//        default:
//            break;
//    }
//    
//    return spacing;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section {
//    CGFloat spacing = 0.f;
//    
//    switch (section) {
//        case 0:
//        case 1:
//        case 2:
//        case 4:
//            spacing = 0.f;
//            break;
//            
//        case 3:
//            spacing = 4.f;
//            break;
//            
//        case 5:
//            spacing = 8.f;
//            
//        default:
//            break;
//    }
//    
//    return spacing;
//}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    if (section == 5) {
//        return UIEdgeInsetsMake(0, 8, 0, 8);
//    }
//    
//    return UIEdgeInsetsZero;
//}
