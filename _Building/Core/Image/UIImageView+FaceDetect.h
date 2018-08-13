//
//  UIImageView+FaceDetect.h
//  teacher
//
//  Created by fallen.ink on 03/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (FaceDetect)

// inspired by https://github.com/Julioacarrettoni/UIImageView_FaceAwareFill
// debug mode by enable DEBUGGING_FACE_AWARE_FILL

//Ask the image to perform an "Aspect Fill" but centering the image to the detected faces
//Not the simple center of the image
- (void)faceAwareFill;

- (void)faceAwareFillWithImage:(UIImage *)image;

@end
