//
//  NSObject+Property.h
//  wesg
//
//  Created by 7 on 01/08/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Property)

@property (nonatomic, readonly) NSString *className;
@property (class, readonly) NSString *className;

@end
