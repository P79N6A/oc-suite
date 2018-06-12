//
//  _image.m
//  kata
//
//  Created by fallen.ink on 18/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "_image.h"
#import "_pragma_push.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

NS_INLINE CGRect CGRectScaleRect(CGRect r, CGFloat scale) {
    return CGRectMake(r.origin.x * scale,
                      r.origin.y * scale,
                      r.size.width * scale,
                      r.size.height * scale);
}

NS_INLINE CGRect CGRectInsetAll(CGRect r, UIEdgeInsets i) {
    return CGRectMake(r.origin.x + i.left,
                      r.origin.y + i.top,
                      r.size.width - i.right,
                      r.size.height - i.bottom);
}

NS_INLINE CGRect CGRectInsetLeft(CGRect r, CGFloat dx, CGFloat dy) {
    return CGRectMake(r.origin.x + dx,
                      r.origin.y + dy,
                      r.size.width - dx,
                      r.size.height - dy);
}

NS_INLINE CGRect CGRectInsetRight(CGRect r, CGFloat dx, CGFloat dy) {
    return CGRectMake(r.origin.x,
                      r.origin.y,
                      r.size.width - dx,
                      r.size.height - dy);
}

@implementation _image

+ (void)saveImage:(UIImage *)image toLibrary:(void (^)(NSError *))completion {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (completion) completion(error);
    }];
}

+ (UIImage *)getVideoSubnailImage:(NSString *)videoURL timeWithSecond:(float)secondTime {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    secondTime = secondTime < 0 ? 0 : secondTime;
    CMTime time = CMTimeMakeWithSeconds(secondTime, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

@end

#import "_pragma_pop.h"
