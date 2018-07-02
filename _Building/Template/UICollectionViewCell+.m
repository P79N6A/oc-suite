//
//  UICollectionViewCell+_.m
//  FATodos
//
//  Created by qingqing on 16/1/29.
//  Copyright © 2016年 fallen.ink. All rights reserved.
//

#import "UICollectionViewCell+.h"

@implementation UICollectionViewCell (Template)

#pragma mark - Class

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self identifier] bundle:nil];
}

#pragma mark - Object

- (void)setModel:(id)model {
    // do nothing.
}

#pragma mark -

+ (CGSize)cellSize {
    return CGSizeZero;
}

- (CGSize)cellSize {
    return self.class.cellSize;
}

+ (CGSize)cellSizeWithModel:(id)model {
    return self.cellSize;
}

+ (CGFloat)cellHeight {
    return 0.f;
}

- (CGFloat)cellHeight {
    return self.class.cellHeight;
}

+ (CGFloat)cellHeightWithModel:(id)model {
    return self.cellHeight;
}

#pragma mark - On UITableView

+ (void)registerOnNib:(UICollectionView *)collectionView{
    NSAssert(collectionView, @"collectionView nil");

    [collectionView registerNib:[self nib]
     forCellWithReuseIdentifier:[self identifier]];
}

+ (void)registerOnClass:(UICollectionView *)collectionView {
    NSAssert(collectionView, @"collectionView nil");
    
    [collectionView registerClass:[self class]
       forCellWithReuseIdentifier:[self identifier]];
}

@end
