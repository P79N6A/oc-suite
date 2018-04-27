//
//  UICollectionViewCell+_.h
//  FATodos
//
//  Created by qingqing on 16/1/29.
//  Copyright © 2016年 fallen.ink. All rights reserved.
//

#import <UIKit/UIKit.h>

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
