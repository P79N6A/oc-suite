//
//  NSURLRequest+H5WhiteList.h
//  wesg
//
//  Created by Altair on 06/04/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (H5WhiteList)

- (NSMutableURLRequest *)filteredRequest;

@end
