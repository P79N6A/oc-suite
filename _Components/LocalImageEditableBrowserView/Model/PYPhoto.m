#import "_building_precompile.h"
#import "PYPhoto.h"

@implementation PYPhoto

- (instancetype)init {
    if (self = [super init]) {
        self.verticalWidth = screen_width;
    }
    return self;
}

@end
