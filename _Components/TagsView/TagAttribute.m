
#import "_building_precompile.h"
#import "TagAttribute.h"
#import "TagCollectionViewFlowLayout.h"

@implementation HXTagAttribute

@def_prop_class(BOOL, preferredEnabled, setPreferredEnabled)
@def_prop_class(CGSize, preferredItemSize, setPreferredItemSize)
@def_prop_class(UIEdgeInsets, preferredSectionInset, setPreferredSectionInset)
@def_prop_class(CGFloat, preferredMinimumInteritemSpacing, setPreferredMinimumInteritemSpacing)

- (instancetype)init {
    self = [super init];
    if (self) {
        UIColor *normalColor = font_gray_2;
        UIColor *normalBackgroundColor = [UIColor whiteColor];
        
        _borderWidth = 0.5f;
        _borderColor = normalColor;
        _cornerRadius = 2.0;
        _backgroundColor = normalBackgroundColor;
        _titleSize = 14;
        _textColor = normalColor;
        _keyColor = [UIColor redColor];
        _tagSpace = 20;
    }
    return self;
}

#pragma mark -

+ (instancetype)normal {
    HXTagAttribute *attr = [HXTagAttribute new];
    UIColor *normalColor = font_gray_2;
    
    attr.borderColor = normalColor;
    attr.textColor = normalColor;
    
    
    return attr;
}

+ (instancetype)selected {
    HXTagAttribute *attr = [HXTagAttribute new];
    UIColor *normalColor = color_green;
    
    attr.borderColor = normalColor;
    attr.textColor = normalColor;
    
    return attr;
}

#pragma mark - Layout

- (HXTagCollectionViewFlowLayout *)tagCellCollectionViewFlowLayout {
    self.layout = [HXTagCollectionViewFlowLayout new];
    
    if (HXTagAttribute.preferredEnabled) {
        self.layout.itemSize = HXTagAttribute.preferredItemSize;
        self.layout.sectionInset = HXTagAttribute.preferredSectionInset;
        self.layout.minimumInteritemSpacing = HXTagAttribute.preferredMinimumInteritemSpacing;
    }
    
    return self.layout;
}


@end
