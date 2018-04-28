//
//  AppDelegate+Usage.m
//  startup
//
//  Created by 7 on 2018/4/28.
//  Copyright © 2018 7. All rights reserved.
//

#import "AppDelegate+Usage.h"
#import "Reachability.h"

@implementation AppDelegate (Usage)

- (void)usageOfReachability {
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach) {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach) {
        NSLog(@"UNREACHABLE!");
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
}

@end
