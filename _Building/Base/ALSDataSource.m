//
//  ALSDataSource.m
//  wesg
//
//  Created by 7 on 29/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSDataSource.h"

@interface ALSDataSource ()

@property (nonatomic, copy) NumberOfSectionsBlock numberOfSectionHandler;
@property (nonatomic, copy) NumberOfRowsBlock numberOfRowsHandler;
@property (nonatomic, copy) ModelForRowBlock modelForRowHandler;

@end

@implementation ALSDataSource

+ (instancetype)withName:(NSString *)name
        numberOfSections:(NumberOfSectionsBlock)numberOfSectionHandler
            numberOfRows:(NumberOfRowsBlock)numberOfRowsHandler
             modelForRow:(ModelForRowBlock)modelForRowHandler {
    ALSDataSource *dataSource = [ALSDataSource new];
    
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
