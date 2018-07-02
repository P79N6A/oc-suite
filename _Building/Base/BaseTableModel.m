//
//  TableModel.m
//  QQing
//
//  Created by fallen.ink on 10/6/15.
//
//

#import "BaseTableModel.h"
#import "_Foundation.h"

#pragma mark - 上面可以合一，可以作为通用，如下

@implementation TableModel

#pragma mark - Initializer

+ (instancetype)instance {
    TableModel *model   = [self new];
    
    // Set defaults
    model.title         = nil;
    model.imageName     = nil;
    model.detail        = nil;
    
    model.accessable    = YES;
    
    model.tag           = 0;
    model.type          = 0;
    
    model.expanded      = NO;
    model.selected      = NO;
    
    return model;
}

// 初始化
+ (instancetype)modelWith:(NSString *)title {
    TableModel *model   = [self instance]; // need to!!! grab default values!!!
    model.title         = title;
    
    return model;
}

+ (instancetype)modelWith:(NSString *)title image:(NSString *)image {
    TableModel *model   = [self modelWith:title];
    model.imageName     = image;
    
    return model;
}

+ (instancetype)modelWith:(NSString *)title image:(NSString *)image detail:(NSString *)detail {
    TableModel *model   = [self modelWith:title image:image];
    model.detail        = detail;
    
    return model;
}

+ (instancetype)modelWith:(NSString *)title image:(NSString *)image detail:(NSString *)detail default:(NSString *)defaultDetail {
    TableModel *model   = [self modelWith:title image:image detail:detail];
    
    model.defaultDetail = defaultDetail;
    
    return model;
}

+ (instancetype)modelWith:(NSString *)title image:(NSString *)image tag:(NSUInteger)tag {
    TableModel *model   = [self modelWith:title image:image];
    model.tag           = tag;
    
    return model;
}

+ (instancetype)modelWith:(NSString *)title image:(NSString *)image detail:(NSString *)detail tag:(NSInteger)tag {
    TableModel *model   = [self modelWith:title image:image tag:tag];
    
    model.detail        = detail;
    
    return model;
}

#pragma mark - Property

- (BOOL)isDetailDefault {
    return [self.detail is:self.defaultDetail];
}

- (void)setAccessable:(BOOL)accessable {
    _accessable = accessable;
    
    self.accessoryType  = accessable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

- (NSString *)accessory {
    if (self.selected) {
        return self.accessorySelected;
    } else {
        return self.accessoryNormal;
    }
}

- (CGFloat)expandHeight {
    if (self.expanded) {
        return _expandHeight;
    } else {
        return 0.f;
    }
}

@end

#pragma mark -

@implementation ItemModel

+ (instancetype)modelWithId:(int64_t)id code:(NSString *)code name:(NSString *)name {
    ItemModel *model = [ItemModel new];
    
    model.id = id;
    model.code = code;
    model.name = name;
    
    return model;
}

+ (instancetype)modelWithId:(int64_t)id name:(NSString *)name {
    return [self modelWithId:id code:@"null" name:name];
}

@end
