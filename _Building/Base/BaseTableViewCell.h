//
//  BaseTableViewCell.h
//  consumer
//
//  Created by fallen on 16/9/23.
//
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Template)

+ (NSString *)identifier;
+ (UINib *)nib;

+ (CGFloat)cellHeight;
- (CGFloat)cellHeight;
+ (CGFloat)cellHeightWithModel:(id)model;

// 一般在setup中初始化，在setModel / setdown中填充数据
- (void)setup;
- (void)setdown:(id)data;
- (void)setModel:(id)obj;

#pragma mark - On UITableView

+ (void)registerOnNib:(UITableView *)tableView;
+ (void)registerOnClass:(UITableView *)tableView;

@end

@interface UICollectionViewCell (Template)

+ (NSString *)identifier;
+ (UINib *)nib;

- (void)setModel:(id)model;

+ (CGSize)cellSize;
- (CGSize)cellSize;
+ (CGSize)cellSizeWithModel:(id)model;

+ (CGFloat)cellHeight;
- (CGFloat)cellHeight;
+ (CGFloat)cellHeightWithModel:(id)model;

#pragma mark - On UITableView

+ (void)registerOnNib:(UICollectionView *)collectionView;
+ (void)registerOnClass:(UICollectionView *)collectionView;

@end

@interface BaseTableViewCell : UITableViewCell

@end
