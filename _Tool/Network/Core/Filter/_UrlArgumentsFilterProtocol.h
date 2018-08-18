//
//  _NetUrlFilterProtocol.h
//  component
//
//  Created by fallen.ink on 5/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _NetRequest;

@protocol _UrlArgumentsFilterProtocol <NSObject>

- (NSString *)filterUrl:(NSString *)originUrl;

@end
