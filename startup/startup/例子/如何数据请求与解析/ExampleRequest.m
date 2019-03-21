//
//  ExampleRequest.m
//  gege
//
//  Created by fallen.ink on 2019/3/14.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import "ExampleRequest.h"

@implementation ExampleRequest

@end

@implementation MemberCarddetailRequest

@end


@implementation MemberBindParent

@end

@implementation MemberBindcard

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"bind_parent" : [MemberBindParent class]};
}

@end


@implementation MemberBindcardsResponse

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"alisp_data" : [MemberBindcard class]};
}

@end
