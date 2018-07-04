//
//  DUMP.m
//  NewStructureTests
//
//  Created by 7 on 14/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "DUMP.h"

// -------------------------------------------
// MARK: -
// -------------------------------------------

void dump_url(NSURL *url) {
    NSLog(@"#################################");
    NSLog(@"DUMPING url = %@", url);
    NSLog(@"host=%@", [url host]);
    NSLog(@"absolute=%@", [url absoluteString]);
    NSLog(@"relativePath=%@", [url relativePath]);
    NSLog(@"relativeString=%@", [url relativeString]);
    NSLog(@"query=%@", [url query]);
    NSLog(@"path=%@", [url path]);
    NSLog(@"parameterString=%@", [url parameterString]);
    NSLog(@"scheme=%@", [url scheme]);
    NSLog(@"#################################");
}

// -------------------------------------------
// MARK: -
// -------------------------------------------

@implementation DUMP

@end
