

#import "BaseDataSource.h"

@interface BaseDataSource ()

@property (nonatomic, copy) NumberOfSectionsBlock numberOfSectionHandler;
@property (nonatomic, copy) NumberOfRowsBlock numberOfRowsHandler;
@property (nonatomic, copy) ModelForRowBlock modelForRowHandler;

@end

@implementation BaseDataSource

+ (instancetype)withName:(NSString *)name
        numberOfSections:(NumberOfSectionsBlock)numberOfSectionHandler
            numberOfRows:(NumberOfRowsBlock)numberOfRowsHandler
             modelForRow:(ModelForRowBlock)modelForRowHandler {
    BaseDataSource *dataSource = [self new];
    
    dataSource->_name = name;
    dataSource.numberOfSectionHandler = numberOfSectionHandler;
    dataSource.numberOfRowsHandler = numberOfRowsHandler;
    dataSource.modelForRowHandler = modelForRowHandler;
    
    return dataSource;
}

- (NSInteger)numberOfSections {
    return self.numberOfSectionHandler();
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRowsHandler(section);
}

- (id)modelForRowAtSection:(NSInteger)section row:(NSInteger)row {
    return self.modelForRowHandler(section, row);
}

@end
