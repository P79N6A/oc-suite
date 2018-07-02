//
//  UICollectionViewWaterfallLayout.m
//
//  Created by Nelson on 12/11/19.
//  Copyright (c) 2012 Nelson Tai. All rights reserved.
//

#import "CollectionViewWaterfallLayout.h"
//#import "tgmath.h"

NSString *const CollectionElementKindSectionHeader = @"CollectionElementKindSectionHeader";
NSString *const CollectionElementKindSectionFooter = @"CollectionElementKindSectionFooter";

@interface CollectionViewWaterfallLayout ()
/// The delegate will point to collection view's delegate automatically.
@property (nonatomic, weak) id <CollectionViewDelegateWaterfallLayout> delegate;
/// Array to store height for each column
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// Array of arrays. Each array stores item attributes for each section
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
/// Array to store attributes for all items includes headers, cells, and footers
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// Dictionary to store section headers' attribute
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
/// Dictionary to store section footers' attribute
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
/// Array to store union rectangles
@property (nonatomic, strong) NSMutableArray *unionRects;
@end

@implementation CollectionViewWaterfallLayout

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

static CGFloat __FloorCGFloat(CGFloat value) {
  CGFloat scale = [UIScreen mainScreen].scale;
  return floor(value * scale) / scale;
}

#pragma mark - Public Accessors

- (void)setMinimumColumnSpacing:(CGFloat)minimumColumnSpacing {
  if (_minimumColumnSpacing != minimumColumnSpacing) {
    _minimumColumnSpacing = minimumColumnSpacing;
    [self invalidateLayout];
  }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
  if (_minimumInteritemSpacing != minimumInteritemSpacing) {
    _minimumInteritemSpacing = minimumInteritemSpacing;
    [self invalidateLayout];
  }
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
  if (_headerHeight != headerHeight) {
    _headerHeight = headerHeight;
    [self invalidateLayout];
  }
}

- (void)setFooterHeight:(CGFloat)footerHeight {
  if (_footerHeight != footerHeight) {
    _footerHeight = footerHeight;
    [self invalidateLayout];
  }
}

- (void)setHeaderInset:(UIEdgeInsets)headerInset {
  if (!UIEdgeInsetsEqualToEdgeInsets(_headerInset, headerInset)) {
    _headerInset = headerInset;
    [self invalidateLayout];
  }
}

- (void)setFooterInset:(UIEdgeInsets)footerInset {
  if (!UIEdgeInsetsEqualToEdgeInsets(_footerInset, footerInset)) {
    _footerInset = footerInset;
    [self invalidateLayout];
  }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
  if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
    _sectionInset = sectionInset;
    [self invalidateLayout];
  }
}

- (void)setItemRenderDirection:(CollectionViewWaterfallLayoutItemRenderDirection)itemRenderDirection {
  if (_itemRenderDirection != itemRenderDirection) {
    _itemRenderDirection = itemRenderDirection;
    [self invalidateLayout];
  }
}

- (NSInteger)columnCountForSection:(NSInteger)section item:(NSInteger)item {
    return [self.delegate collectionView:self.collectionView layout:self columnCountForSection:section item:item];
}

- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section item:(NSInteger)item {
  UIEdgeInsets sectionInset;
  if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
    sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
  } else {
    sectionInset = self.sectionInset;
  }
  CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
  NSInteger columnCount = [self columnCountForSection:section item:item];

  CGFloat columnSpacing = self.minimumColumnSpacing;
  if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumColumnSpacingForSectionAtIndex:)]) {
    columnSpacing = [self.delegate collectionView:self.collectionView layout:self minimumColumnSpacingForSectionAtIndex:section];
  }

  return __FloorCGFloat((width - (columnCount - 1) * columnSpacing) / columnCount);
}

#pragma mark - Private Accessors
- (NSMutableDictionary *)headersAttribute {
  if (!_headersAttribute) {
    _headersAttribute = [NSMutableDictionary dictionary];
  }
  return _headersAttribute;
}

- (NSMutableDictionary *)footersAttribute {
  if (!_footersAttribute) {
    _footersAttribute = [NSMutableDictionary dictionary];
  }
  return _footersAttribute;
}

- (NSMutableArray *)unionRects {
  if (!_unionRects) {
    _unionRects = [NSMutableArray array];
  }
  return _unionRects;
}

- (NSMutableArray *)columnHeights {
  if (!_columnHeights) {
    _columnHeights = [NSMutableArray array];
  }
  return _columnHeights;
}

- (NSMutableArray *)allItemAttributes {
  if (!_allItemAttributes) {
    _allItemAttributes = [NSMutableArray array];
  }
  return _allItemAttributes;
}

- (NSMutableArray *)sectionItemAttributes {
  if (!_sectionItemAttributes) {
    _sectionItemAttributes = [NSMutableArray array];
  }
  return _sectionItemAttributes;
}

- (id <CollectionViewDelegateWaterfallLayout> )delegate {
  return (id <CollectionViewDelegateWaterfallLayout> )self.collectionView.delegate;
}

#pragma mark - Init

- (void)commonInit {
  _minimumColumnSpacing = 10;
  _minimumInteritemSpacing = 10;
  _headerHeight = 0;
  _footerHeight = 0;
  _sectionInset = UIEdgeInsetsZero;
  _headerInset  = UIEdgeInsetsZero;
  _footerInset  = UIEdgeInsetsZero;
  _itemRenderDirection = CollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
}

- (id)init {
  if (self = [super init]) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self commonInit];
  }
  return self;
}

#pragma mark - Methods to Override
- (void)prepareLayout {
  [super prepareLayout];

  [self.headersAttribute removeAllObjects];
  [self.footersAttribute removeAllObjects];
  [self.unionRects removeAllObjects];
  [self.columnHeights removeAllObjects];
  [self.allItemAttributes removeAllObjects];
  [self.sectionItemAttributes removeAllObjects];

  NSInteger numberOfSections = [self.collectionView numberOfSections];
  if (numberOfSections == 0) {
    return;
  }

  NSAssert([self.delegate conformsToProtocol:@protocol(CollectionViewDelegateWaterfallLayout)], @"UICollectionView's delegate should conform to CollectionViewDelegateWaterfallLayout protocol");
  NSAssert([self.delegate respondsToSelector:@selector(collectionView:layout:columnCountForSection: item:)], @"UICollectionViewWaterfallLayout's columnCount should be greater than 0, or delegate must implement columnCountForSection:");

  // Initialize variables
  NSInteger idx = 0;

  for (NSInteger section = 0; section < numberOfSections; section++) {
    NSInteger columnCount = [self columnCountForSection:section item:-1];
    NSMutableArray *sectionColumnHeights = [NSMutableArray arrayWithCapacity:columnCount];
    for (idx = 0; idx < columnCount; idx++) {
      [sectionColumnHeights addObject:@(0)];
    }
    [self.columnHeights addObject:sectionColumnHeights];
  }
    
  // Create attributes
  CGFloat top = 0;
  UICollectionViewLayoutAttributes *attributes;

  for (NSInteger section = 0; section < numberOfSections; ++section) {
    /*
     * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
     */
    CGFloat minimumInteritemSpacing;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
      minimumInteritemSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    } else {
      minimumInteritemSpacing = self.minimumInteritemSpacing;
    }

    CGFloat columnSpacing = self.minimumColumnSpacing;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumColumnSpacingForSectionAtIndex:)]) {
      columnSpacing = [self.delegate collectionView:self.collectionView layout:self minimumColumnSpacingForSectionAtIndex:section];
    }

    UIEdgeInsets sectionInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
      sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    } else {
      sectionInset = self.sectionInset;
    }

    CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
    NSInteger maxColumnCount = [self columnCountForSection:section item:-1];
      
    /*
     * 2. Section header
     */
    CGFloat headerHeight;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)]) {
      headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
    } else {
      headerHeight = self.headerHeight;
    }

    UIEdgeInsets headerInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForHeaderInSection:)]) {
      headerInset = [self.delegate collectionView:self.collectionView layout:self insetForHeaderInSection:section];
    } else {
      headerInset = self.headerInset;
    }

    top += headerInset.top;

    if (headerHeight > 0) {
      attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
      attributes.frame = CGRectMake(headerInset.left,
                                    top,
                                    self.collectionView.bounds.size.width - (headerInset.left + headerInset.right),
                                    headerHeight);

      self.headersAttribute[@(section)] = attributes;
      [self.allItemAttributes addObject:attributes];

      top = CGRectGetMaxY(attributes.frame) + headerInset.bottom;
    }

    top += sectionInset.top;
      
      
    for (idx = 0; idx < maxColumnCount; idx++) {
      self.columnHeights[section][idx] = @(top);
    }

    /*
     * 3. Section items
     */
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
    NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];

    // Item will be put into shortest column.
    for (idx = 0; idx < itemCount; idx++) {
        NSInteger columnCount = 0;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
        NSUInteger columnIndex = [self nextColumnIndexForItem:idx inSection:section];
        CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        CGFloat itemWidth = 0;

        {
            // 通过判断当前item大小所倾向于的列数
            columnCount = [self columnCountForSection:section item:idx];
            itemWidth = __FloorCGFloat((width - (columnCount - 1) * columnSpacing) / columnCount);
        }
        
        CGFloat xOffset = sectionInset.left + (itemWidth + columnSpacing) * columnIndex;
        CGFloat yOffset = [self.columnHeights[section][columnIndex] floatValue];
      
        CGFloat itemHeight = 0;
        if (itemSize.height > 0 && itemSize.width > 0) {
            itemHeight = __FloorCGFloat(itemSize.height * itemWidth / itemSize.width);
        }

        attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
        
      
        [itemAttributes addObject:attributes];
        [self.allItemAttributes addObject:attributes];
        self.columnHeights[section][columnIndex] = @(CGRectGetMaxY(attributes.frame) + minimumInteritemSpacing);
        
        if (columnCount < maxColumnCount) {
            for (idx = columnCount; idx < maxColumnCount; idx++) {
                // 当前item不足，最大列数，所以需要将空缺补位；然后选择的时候，可以将不同类型的分开。
                self.columnHeights[section][idx] = @([self longestColumnHeightInSection:section]);
                
                // 重要假设：列数不同，则另起一行！！！这是重要的规则！！！
                /**
                 
                 同一sectin的item分布、填充顺序（最短height优先）：
                 
                 
                 一列             __________________________________________
                                 |                                        |
                                 |                    1                   |
                                 ------------------------------------------
                 
                 两列             ____________________  ____________________
                                 |                  |  |                  |
                                 |                  |  |                  |
                                 |                  |  |                  |
                                 |                  |  |                  |
                                 |                  |  |                  |
                                 |                  |  |                  |
                                 |                  |  |                  |
                                 |                  |  |                  |
                                 |                  |  |                  |
                                 |                  |  |         3        |
                                 |                  |  |                  |
                                 |                  |  --------------------
                                 |        2         |
                                 |                  |
                                 --------------------
                 
                 三列             ___________     ___________     ___________
                                 |         |     |         |     |         |
                                 |         |     |         |     |         |
                                 |         |     |         |     |         |
                                 |         |     |    5    |     |         |
                                 |         |     |         |     |         |
                                 |         |     -----------     |         |
                                 |         |     ___________     |         |
                                 |    4    |     |         |     |         |
                                 |         |     |         |     |         |
                                 -----------     |         |     |         |
                                 ___________     |         |     |    6    |
                                 |         |     |         |     |         |
                                 |         |     |         |     -----------
                                 |         |     |    7    |
                                 |    8    |     |         |
                 
                 
                 */
            }
        }
    }

    [self.sectionItemAttributes addObject:itemAttributes];

    /*
     * 4. Section footer
     */
    CGFloat footerHeight;
    NSUInteger columnIndex = [self longestColumnIndexInSection:section];
    top = [self.columnHeights[section][columnIndex] floatValue] - minimumInteritemSpacing + sectionInset.bottom;

    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)]) {
      footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
    } else {
      footerHeight = self.footerHeight;
    }

    UIEdgeInsets footerInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForFooterInSection:)]) {
      footerInset = [self.delegate collectionView:self.collectionView layout:self insetForFooterInSection:section];
    } else {
      footerInset = self.footerInset;
    }

    top += footerInset.top;

    if (footerHeight > 0) {
      attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
      attributes.frame = CGRectMake(footerInset.left,
                                    top,
                                    self.collectionView.bounds.size.width - (footerInset.left + footerInset.right),
                                    footerHeight);

      self.footersAttribute[@(section)] = attributes;
      [self.allItemAttributes addObject:attributes];

      top = CGRectGetMaxY(attributes.frame) + footerInset.bottom;
    }

    for (idx = 0; idx < maxColumnCount; idx++) {
      self.columnHeights[section][idx] = @(top);
    }
  } // end of for (NSInteger section = 0; section < numberOfSections; ++section)

  // Build union rects
  idx = 0;
  NSInteger itemCounts = [self.allItemAttributes count];
  while (idx < itemCounts) {
    CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
    NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);

    for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
      unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
    }

    idx = rectEndIndex;

    [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
  }
}

- (CGSize)collectionViewContentSize {
  NSInteger numberOfSections = [self.collectionView numberOfSections];
  if (numberOfSections == 0) {
    return CGSizeZero;
  }

  CGSize contentSize = self.collectionView.bounds.size;
  contentSize.height = [[[self.columnHeights lastObject] firstObject] floatValue];

  if (contentSize.height < self.minimumContentHeight) {
    contentSize.height = self.minimumContentHeight;
  }

  return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
  if (path.section >= [self.sectionItemAttributes count]) {
    return nil;
  }
  if (path.item >= [self.sectionItemAttributes[path.section] count]) {
    return nil;
  }
  return (self.sectionItemAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *attribute = nil;
  if ([kind isEqualToString:CollectionElementKindSectionHeader]) {
    attribute = self.headersAttribute[@(indexPath.section)];
  } else if ([kind isEqualToString:CollectionElementKindSectionFooter]) {
    attribute = self.footersAttribute[@(indexPath.section)];
  }
  return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSInteger i;
  NSInteger begin = 0, end = self.unionRects.count;
  NSMutableArray *attrs = [NSMutableArray array];

  for (i = 0; i < self.unionRects.count; i++) {
    if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
      begin = i * unionSize;
      break;
    }
  }
  for (i = self.unionRects.count - 1; i >= 0; i--) {
    if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
      end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
      break;
    }
  }
  for (i = begin; i < end; i++) {
    UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
    if (CGRectIntersectsRect(rect, attr.frame)) {
      [attrs addObject:attr];
    }
  }

  return [NSArray arrayWithArray:attrs];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  CGRect oldBounds = self.collectionView.bounds;
  if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
    return YES;
  }
  return NO;
}

#pragma mark - Private Methods

/**
 *  Find the shortest column.
 *
 *  @return index for the shortest column
 */
- (NSUInteger)shortestColumnIndexInSection:(NSInteger)section item:(NSInteger)item {
  __block NSUInteger index = 0;
  __block CGFloat shortestHeight = MAXFLOAT;

  [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    CGFloat height = [obj floatValue];
    if (height < shortestHeight) {
      shortestHeight = height;
      index = idx;
    }
  }];

  return index;
}

/**
 *  Find the longest column.
 *
 *  @return index for the longest column
 */
- (NSUInteger)longestColumnIndexInSection:(NSInteger)section {
  __block NSUInteger index = 0;
  __block CGFloat longestHeight = 0;

  [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    CGFloat height = [obj floatValue];
    if (height > longestHeight) {
      longestHeight = height;
      index = idx;
    }
  }];

  return index;
}

- (CGFloat)longestColumnHeightInSection:(NSInteger)section {
    __block CGFloat longestHeight = 0;
    
    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
        }
    }];
    
    return longestHeight;
}

/**
 *  Find the index for the next column.
 *
 *  @return index for the next column
 */
- (NSUInteger)nextColumnIndexForItem:(NSInteger)item inSection:(NSInteger)section {
  NSUInteger index = 0;
  NSInteger columnCount = [self columnCountForSection:section item:item];
  switch (self.itemRenderDirection) {
    case CollectionViewWaterfallLayoutItemRenderDirectionLeftToRight:
      index = (item % columnCount);
      break;

    case CollectionViewWaterfallLayoutItemRenderDirectionRightToLeft:
      index = (columnCount - 1) - (item % columnCount);
      break;

      case CollectionViewWaterfallLayoutItemRenderDirectionShortestFirst:
      default:
          index = [self shortestColumnIndexInSection:section item:item]; // 当前需要兼容，同一个section，多个排列，就需要知道，目标item是否的列数区别
          break;
    
//      index = [self shortestColumnIndexInSection:section];
//      break;
  }
  return index;
}

@end
