//
//  NSURLRequest+Web.m
//  student
//
//  Created by fallen.ink on 16/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "NSURLRequest+Web.h"

@implementation NSURLRequest ( Web )

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}

@end
