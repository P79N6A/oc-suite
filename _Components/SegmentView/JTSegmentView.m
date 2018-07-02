
#import "_building_precompile.h"
#import "JTSegmentView.h"

@interface JTSegmentView ()

@property (nonatomic, strong) UILabel   *firstLabel;

@end

@implementation JTSegmentView {
    NSMutableArray *allItems;
}

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles images:(NSArray *)images {
    self = [super initWithFrame:frame];
    if (self) {
        [self setImages:images];
        
        [self _initViews:titles];
    }
    
    return self;
}

- (void)_initViews:(NSArray *)titles {
    allItems = [[NSMutableArray alloc] initWithCapacity:titles.count];

    float viewWidth =  [UIScreen mainScreen].bounds.size.width ;
    float itemWidth = viewWidth/titles.count;

    self.titles = titles;

    for (int i = 0; i < titles.count; i++) {
        NSArray *imgs = [self.images objectAtIndex:i];
        NSString *itemName = titles[i];
        UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(i*itemWidth, 0, itemWidth, self.height)];
        
        UILabel *titleLabel =[[UILabel alloc] initWithFrame:itemView.bounds];
        if (i == 0) {
            self.firstLabel = titleLabel;
        }

        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15.f];
        titleLabel.textColor = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1];
        titleLabel.text = itemName;
        titleLabel.tag = 2013;
        [itemView addSubview:titleLabel];
        
        if (i != 1) {
            JTSegmentArrowView *arrowView = [[JTSegmentArrowView alloc] initWithFrame:CGRectMake(itemWidth-27, 0, 13, 18)];
//            if (__IPHONE_10_3) {
//                arrowView.frame = CGRectMake(itemWidth - 17, 0, 13, 18);
//            }
            arrowView.images = imgs;
            
            @weakify(self)
            arrowView.block = ^(JTSegmentArrowStates state){
                @strongify(self)
                
                self.currentState = state;
            };
            
            arrowView.tag = 2014;
            if (i == 0) {
                arrowView.isSelected = YES;
            } else if (i == 2) {
                arrowView.states = SegmentArrowNormalStates;
            }
            
            [itemView addSubview:arrowView];
            [arrowView setCenterY:itemView.height/2];
        }
        
        [self addSubview:itemView];
        [allItems addObject:itemView];
        
        { // 加分隔符
            if (i < titles.count-1) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(itemView.width-1,
                                                                        10, 2, itemView.height-10*2)];
                line.backgroundColor = [UIColor colorWithRed:232./255.
                                                       green:232./255.
                                                        blue:232./255.
                                                       alpha:1.0];
                [itemView addSubview:line];
                [line bringToFront];
            }
        }
    }

    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-1, screen_width, 1)];
    lineView.backgroundColor = font_gray_3;
    [self addSubview:lineView];
}

- (void)setSelectedIndex:(int)selectedIndex {
    _selectedIndex = selectedIndex;

    for (int i = 0; i < allItems.count; i++) {
        UIView *itemView = allItems[i];
        UILabel *titleLabel = (UILabel *)[itemView viewWithTag:2013];
        JTSegmentArrowView *arrowView = (JTSegmentArrowView *)[itemView viewWithTag:2014];

        if (i == selectedIndex) {
            titleLabel.textColor = color_blue;
            arrowView.isSelected = YES;
            
            if (selectedIndex == 2) {
                if (arrowView.states == SegmentArrowNormalStates) {
                    arrowView.states = SegmentArrowDownStates;
                } else {
                    arrowView.states = arrowView.states == SegmentArrowUpStates ? SegmentArrowDownStates : SegmentArrowUpStates;
                }
            } else {
                arrowView.states = SegmentArrowDownStates;
            }
        } else {
            titleLabel.textColor = font_gray_4;
            arrowView.isSelected = NO;

            arrowView.states = SegmentArrowNormalStates;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    float width = screen_width/self.titles.count;
    int index = point.x /width;
    self.selectedIndex = index;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end

