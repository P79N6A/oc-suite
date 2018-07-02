//
//  MJGImageLoader.h
//  MJGFoundation
//
//  Created by Matt Galloway on 06/01/2012.
//  Copyright 2012 Matt Galloway. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ ImageLoaderHandler)(UIImage *image, NSError *error);

@interface ImageLoader : NSObject

- (id)initWithURL:(NSURL*)url;

- (void)startWithHandler:(ImageLoaderHandler)handler;
- (void)cancel;

@end
