//
//  LocationServiceProt.h
//  student
//
//  Created by fallen.ink on 10/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LocationServiceProt <NSObject>

// MARK: Life cycle
- (void)prepare;
- (void)start;
- (void)stop;

// MARK: Business logic


@end
