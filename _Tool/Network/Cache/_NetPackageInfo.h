//
//  _net_package_info.h
//  consumer
//
//  Created by fallen.ink on 9/22/16.
//
//

#import <Foundation/Foundation.h>

@interface _NetPackageInfo : NSObject {
    NSURL *packageURL;
    NSURL *baseURL;
    NSArray *resourceURLs;
    NSMutableDictionary *userData;
}

@property (nonatomic, strong) NSURL *packageURL;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSArray *resourceURLs;
@property (nonatomic, strong) NSMutableDictionary *userData;

@end
