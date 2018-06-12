//
//  UIImageView+FaceDetect.m
//  teacher
//
//  Created by fallen.ink on 03/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "UIImageView+FaceDetect.h"

@implementation UIImageView (FaceDetect)

#pragma mark -

static CIDetector *_faceDetector;

+ (void)initialize {
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:nil
                                       options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
}

// based on this: http://maniacdev.com/2011/11/tutorial-easy-face-detection-with-core-image-in-ios-5/

- (void)faceAwareFillWithImage:(UIImage *)image {
    // Safe check!
    if (image == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect facesRect = [self rectWithFacesWithImage:image];
        if (facesRect.size.height + facesRect.size.width == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image; // set origin image
            });
            
            return;
        }
        
        
        self.contentMode = UIViewContentModeTopLeft;
        CGRect displayRect = [self scaleImageFocusingOnRect:facesRect withImage:image];
        
        // self.view isn't a node, so we can only use it on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawFaceRect:displayRect withImage:image];
        });
    });
}

- (void)faceAwareFill {
    // Safe check!
    if (self.image == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect facesRect = [self rectWithFacesWithImage:self.image];
        if (facesRect.size.height + facesRect.size.width == 0)
            return;
        
        self.contentMode = UIViewContentModeTopLeft;
        CGRect displayRect = [self scaleImageFocusingOnRect:facesRect withImage:self.image];
        
        // self.view isn't a node, so we can only use it on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self drawFaceRect:displayRect withImage:self.image];
            
            [self setNeedsDisplay];
        });
    });
}

- (CGRect)rectWithFacesWithImage:(UIImage *)image {
    // Get a CIIImage
    CIImage *ciImage = image.CIImage;
    
    // If now available we create one using the CGImage
    if (!ciImage) {
        ciImage = [CIImage imageWithCGImage:image.CGImage];
    }
    
    int exifOrientation;
    
    {
        switch (image.imageOrientation) {
            case UIImageOrientationUp:
                exifOrientation = 1;
                break;
            case UIImageOrientationDown:
                exifOrientation = 3;
                break;
            case UIImageOrientationLeft:
                exifOrientation = 8;
                break;
            case UIImageOrientationRight:
                exifOrientation = 6;
                break;
            case UIImageOrientationUpMirrored:
                exifOrientation = 2;
                break;
            case UIImageOrientationDownMirrored:
                exifOrientation = 4;
                break;
            case UIImageOrientationLeftMirrored:
                exifOrientation = 5;
                break;
            case UIImageOrientationRightMirrored:
                exifOrientation = 7;
                break;
            default:
                break;
        }
    }
    
    // Use the static CIDetector
    CIDetector* detector = _faceDetector;
    
    // create an array containing all the detected faces from the detector
    //    NSArray* features = [detector featuresInImage:image];
    NSArray *features = [detector featuresInImage:ciImage
                                          options:@{CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation]}];
    
    // we'll iterate through every detected face. CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected.
    CGRect totalFaceRects = CGRectMake(image.size.width/2.0, image.size.height/2.0, 0, 0);
    
    if (features.count > 0) {
        //We get the CGRect of the first detected face
        totalFaceRects = ((CIFaceFeature*)[features objectAtIndex:0]).bounds;
        
        // Now we find the minimum CGRect that holds all the faces
        for (CIFaceFeature* faceFeature in features) {
            totalFaceRects = CGRectUnion(totalFaceRects, faceFeature.bounds);
        }
    }
    
    //So now we have either a CGRect holding the center of the image or all the faces.
    return totalFaceRects;
}

- (void)drawFaceRect:(CGRect)imageRect withImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(imageRect.size, YES, 2.0);
    [image drawInRect:imageRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.image = newImage;
    
    //This is to show the red rectangle over the faces
#ifdef DEBUGGING_FACE_AWARE_FILL
    NSInteger theRedRectangleTag = -3312;
    UIView* facesRectLine = [self viewWithTag:theRedRectangleTag];
    if (!facesRectLine) {
        facesRectLine = [[UIView alloc] initWithFrame:facesRect];
        facesRectLine.tag = theRedRectangleTag;
    } else {
        facesRectLine.frame = facesRect;
    }
    
    facesRectLine.backgroundColor = [UIColor clearColor];
    facesRectLine.layer.borderColor = [UIColor redColor].CGColor;
    facesRectLine.layer.borderWidth = 4.0;
    
    CGRect frame = facesRectLine.frame;
    frame.origin.x = imageRect.origin.x + frame.origin.x;
    frame.origin.y = imageRect.origin.y + frame.origin.y;
    facesRectLine.frame = frame;
    
    [self addSubview:facesRectLine];
#endif
}

- (CGRect)scaleImageFocusingOnRect:(CGRect)facesRect withImage:(UIImage *)image {
    CGFloat multi1 = self.frame.size.width / image.size.width;
    CGFloat multi2 = self.frame.size.height / image.size.height;
    CGFloat multi = MAX(multi1, multi2);
    
    //We need to 'flip' the Y coordinate to make it match the iOS coordinate system one
    facesRect.origin.y = image.size.height - facesRect.origin.y - facesRect.size.height;
    
    facesRect = CGRectMake(facesRect.origin.x*multi, facesRect.origin.y*multi, facesRect.size.width*multi, facesRect.size.height*multi);
    
    CGRect imageRect = CGRectZero;
    imageRect.size.width = image.size.width * multi;
    imageRect.size.height = image.size.height * multi;
    imageRect.origin.x = MIN(0.0, MAX(-facesRect.origin.x + self.frame.size.width/2.0 - facesRect.size.width/2.0, -imageRect.size.width + self.frame.size.width));
    imageRect.origin.y = MIN(0.0, MAX(-facesRect.origin.y + self.frame.size.height/2.0 -facesRect.size.height/2.0, -imageRect.size.height + self.frame.size.height));
    
    imageRect = CGRectIntegral(imageRect);
    
    return imageRect;
}

@end
