//
//  BaseTableViewCell.m
//  consumer
//
//  Created by fallen on 16/9/23.
//
//

#import "BaseTableViewCell.h"

@implementation UITableViewCell (Template)

#pragma mark - Class

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self identifier] bundle:nil];
}

+ (CGFloat)cellHeight {
    return 0.f;
}

+ (CGFloat)cellHeightWithModel:(id)model {
    return 0.f;
}

#pragma mark - Object

- (CGFloat)cellHeight {
    return 0.f;
}

- (void)setup {
    
}

- (void)setdown:(id)data {
    
}

- (void)setModel:(id)obj {
    // do nothing.
}

#pragma mark - On UITableView

+ (void)registerOnNib:(UITableView *)tableView {
    NSAssert(tableView, @"tableView nil");
    
    [tableView registerNib:[self nib]
    forCellReuseIdentifier:[self identifier]];
}

+ (void)registerOnClass:(UITableView *)tableView {
    NSAssert(tableView, @"tableView nil");
    
    [tableView registerClass:[self class]
      forCellReuseIdentifier:[self identifier]];
}

@end

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

@interface BaseTableViewCell ()

@property (nonatomic, assign) BOOL isInit;

@end

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (!self.isInit) {
        [self setup];
        
        self.isInit = YES;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if (!self.isInit) {
            [self setup];
            
            self.isInit = YES;
        }
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if (!self.isInit) {
            [self setup];
            
            self.isInit = YES;
        }
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
