//
//  _image.h
//  kata
//
//  Created by fallen.ink on 18/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "UIImage+Alpha.h"
#import "UIImage+Capture.h"
#import "UIImage+Compress.h"
#import "UIImage+Crop.h"
#import "UIImage+Effects.h"
#import "UIImage+FileName.h"
#import "UIImage+GIF.h"
#import "UIImage+Merge.h"
#import "UIImage+Transform.h"
#import "UIImage+Vector.h"

#import "UIImageView+FaceDetect.h"

// BEGIN of TODO: 需要化简
#import "YYCache.h"

#import "YYImage.h"
#import "YYImageCoder.h"
#import "YYFrameImage.h"
#import "YYAnimatedImageView.h"
#import "YYSpriteSheetImage.h"

#import "_web_image.h"
// END of TODO: 需要化简

CGFloat DegreesToRadians(CGFloat degrees);
CGFloat RadiansToDegrees(CGFloat radians);

@interface _image : NSObject

/// Saves the recieving image to the camera roll.
+ (void)saveImage:(UIImage *)image toLibrary:(void (^)(NSError *error))completion;

+ (UIImage *)getVideoSubnailImage:(NSString *)videoURL timeWithSecond:(float)secondTime;

@end
