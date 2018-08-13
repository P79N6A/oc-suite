
#import "UIImage+Extension.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage ( Blur )

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor {
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    } else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self blurredImageWithSize:CGSizeMake(20, 20) tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}

- (UIImage *)blurredImageWithRadius:(CGFloat)blurRadius {
    return [self blurredImageWithSize:CGSizeMake(blurRadius, blurRadius)];
}

- (UIImage *)blurredImageWithSize:(CGSize)blurSize {
    return [self blurredImageWithSize:blurSize tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
}

- (UIImage *)blurredImageWithSize:(CGSize)blurSize tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage {
#define ENABLE_BLUR                     1
#define ENABLE_SATURATION_ADJUSTMENT    1
#define ENABLE_TINT                     1
    
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    
    if (!self.CGImage) {
        NSLog(@"*** error: inputImage must be backed by a CGImage: %@", self);
        return nil;
    }
    
    if (maskImage && !maskImage.CGImage) {
        NSLog(@"*** error: effectMaskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    BOOL hasBlur = blurSize.width > __FLT_EPSILON__ || blurSize.height > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    
    CGImageRef inputCGImage = self.CGImage;
    CGFloat inputImageScale = self.scale;
    CGBitmapInfo inputImageBitmapInfo = CGImageGetBitmapInfo(inputCGImage);
    CGImageAlphaInfo inputImageAlphaInfo = (inputImageBitmapInfo & kCGBitmapAlphaInfoMask);
    
    CGSize outputImageSizeInPoints = self.size;
    CGRect outputImageRectInPoints = { CGPointZero, outputImageSizeInPoints };
    
    // Set up output context.
    BOOL useOpaqueContext;
    if (inputImageAlphaInfo == kCGImageAlphaNone || inputImageAlphaInfo == kCGImageAlphaNoneSkipLast || inputImageAlphaInfo == kCGImageAlphaNoneSkipFirst)
        useOpaqueContext = YES;
    else
        useOpaqueContext = NO;
    UIGraphicsBeginImageContextWithOptions(outputImageRectInPoints.size, useOpaqueContext, inputImageScale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -outputImageRectInPoints.size.height);
    
    if (hasBlur || hasSaturationChange) {
        vImage_Buffer effectInBuffer;
        vImage_Buffer scratchBuffer1;
        
        vImage_Buffer *inputBuffer;
        vImage_Buffer *outputBuffer;
        
        vImage_CGImageFormat format = {
            .bitsPerComponent = 8,
            .bitsPerPixel = 32,
            .colorSpace = NULL,
            // (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
            // requests a BGRA buffer.
            .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little,
            .version = 0,
            .decode = NULL,
            .renderingIntent = kCGRenderingIntentDefault
        };
        
        vImage_Error e = vImageBuffer_InitWithCGImage(&effectInBuffer, &format, NULL, self.CGImage, kvImagePrintDiagnosticsToConsole);
        if (e != kvImageNoError) {
            NSLog(@"*** error: vImageBuffer_InitWithCGImage returned error code %zi for inputImage: %@", e, self);
            UIGraphicsEndImageContext();
            return nil;
        }
        
        vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, kvImageNoFlags);
        inputBuffer = &effectInBuffer;
        outputBuffer = &scratchBuffer1;
        
#if ENABLE_BLUR
        if (hasBlur) {
            CGFloat radiusX = [self gaussianBlurRadiusWithBlurRadius:blurSize.width * inputImageScale];
            CGFloat radiusY = [self gaussianBlurRadiusWithBlurRadius:blurSize.height * inputImageScale];
            
            NSInteger tempBufferSize = vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, NULL, 0, 0, radiusY, radiusX, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
            void *tempBuffer = malloc(tempBufferSize);
            
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
            
            free(tempBuffer);
            
            vImage_Buffer *temp = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = temp;
        }
#endif
        
#if ENABLE_SATURATION_ADJUSTMENT
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            // These values appear in the W3C Filter Effects spec:
            // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/index.html#grayscaleEquivalent
            //
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,                    1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            vImageMatrixMultiply_ARGB8888(inputBuffer, outputBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            
            vImage_Buffer *temp = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = temp;
        }
#endif
        
        CGImageRef effectCGImage;
        if ( (effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, &__cleanupBuffer, NULL, kvImageNoAllocate, NULL)) == NULL ) {
            effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, NULL, NULL, kvImageNoFlags, NULL);
            free(inputBuffer->data);
        }
        
        if (maskImage) {
            // Only need to draw the base image if the effect image will be masked.
            CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
        }
        
        // draw effect image
        CGContextSaveGState(outputContext);
        if (maskImage)
            CGContextClipToMask(outputContext, outputImageRectInPoints, maskImage.CGImage);
        CGContextDrawImage(outputContext, outputImageRectInPoints, effectCGImage);
        CGContextRestoreGState(outputContext);
        
        // Cleanup
        CGImageRelease(effectCGImage);
        free(outputBuffer->data);
    } else {
        // draw base image
        CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
    }
    
#if ENABLE_TINT
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, outputImageRectInPoints);
        CGContextRestoreGState(outputContext);
    }
#endif
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
#undef ENABLE_BLUR
#undef ENABLE_SATURATION_ADJUSTMENT
#undef ENABLE_TINT
}


// A description of how to compute the box kernel width from the Gaussian
// radius (aka standard deviation) appears in the SVG spec:
// http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
//
// For larger values of 's' (s >= 2.0), an approximation can be used: Three
// successive box-blurs build a piece-wise quadratic convolution kernel, which
// approximates the Gaussian kernel to within roughly 3%.
//
// let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
//
// ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
//
- (CGFloat)gaussianBlurRadiusWithBlurRadius:(CGFloat)blurRadius {
    if (blurRadius - 2. < __FLT_EPSILON__) {
        blurRadius = 2.;
    }
    uint32_t radius = floor((blurRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);
    radius |= 1; // force radius to be odd so that the three box-blur methodology works.
    return radius;
}


//| ----------------------------------------------------------------------------
//  Helper function to handle deferred cleanup of a buffer.
//
void __cleanupBuffer(void *userData, void *buf_data) { free(buf_data); }

#pragma mark -

- (UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    //    if (blur < 0.f || blur > 1.f) {
    //        blur = 0.5f;
    //    }
    //    int boxSize = (int)(blur * 40);
    //    boxSize = boxSize - (boxSize % 2) + 1;
    //
    //    CGImageRef img = self.CGImage;
    //    vImage_Buffer inBuffer, outBuffer;
    //    vImage_Error error;
    //
    //    void *pixelBuffer;
    //
    //    //create vImage_Buffer with data from CGImageRef
    //    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    //    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //
    //    inBuffer.width = CGImageGetWidth(img);
    //    inBuffer.height = CGImageGetHeight(img);
    //    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    //
    //    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    //
    //    //create vImage_Buffer for output
    //
    //    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    //
    //    if(pixelBuffer == NULL)
    //        NSLog(@"No pixelbuffer");
    //
    //    outBuffer.data = pixelBuffer;
    //    outBuffer.width = CGImageGetWidth(img);
    //    outBuffer.height = CGImageGetHeight(img);
    //    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    //
    //    // Create a third buffer for intermediate processing
    //    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    //    vImage_Buffer outBuffer2;
    //    outBuffer2.data = pixelBuffer2;
    //    outBuffer2.width = CGImageGetWidth(img);
    //    outBuffer2.height = CGImageGetHeight(img);
    //    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    //
    //    //perform convolution
    //    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    //    if (error) {
    //        NSLog(@"error from convolution %ld", error);
    //    }
    //    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    //    if (error) {
    //        NSLog(@"error from convolution %ld", error);
    //    }
    //    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    //    if (error) {
    //        NSLog(@"error from convolution %ld", error);
    //    }
    //
    //#pragma clang diagnostic push
    //#pragma clang diagnostic ignored "-Wgnu"
    //    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
    //                                             outBuffer.width,
    //                                             outBuffer.height,
    //                                             8,
    //                                             outBuffer.rowBytes,
    //                                             colorSpace,
    //                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    //#pragma clang diagnostic pop
    //    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    //    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //
    //    //clean up
    //    CGContextRelease(ctx);
    //    CGColorSpaceRelease(colorSpace);
    //    free(pixelBuffer2);
    //    free(pixelBuffer);
    //    CFRelease(inBitmapData);
    //
    //    CGImageRelease(imageRef);
    //
    //    return returnImage;
    
    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end

@implementation UIImage (Filter)

- (void)applyFilter:(CIFilter *)filter completion:(void (^)(UIImage *filteredImage))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIContext *context   = [CIContext contextWithOptions:nil];
        CIImage *outputImage = filter.outputImage;
        CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[outputImage extent]];
        UIImage *newImg      = [UIImage imageWithCGImage:cgimg];
        CGImageRelease(cgimg);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(newImg);
        });
    });
    
}

+ (UIImage *)imageWithFilter:(CIFilter *)filter {
    CIContext *context   = [CIContext contextWithOptions:nil];
    CIImage *outputImage = filter.outputImage;
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg      = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return newImg;
}

- (CIFilter *)filterWithPreset:(ImageFilterPreset)preset {
    CIImage *image = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = nil;
    
    switch (preset) {
            case ImageFilterPresetBlackAndWhite: {
                filter = [CIFilter filterWithName:@"CIColorControls"
                                    keysAndValues:kCIInputImageKey, image,
                          @"inputBrightness", @0.0,
                          @"inputContrast", @1.1,
                          @"inputSaturation", @0.0, nil];
                break;
            }
            case ImageFilterPresetSepiaTone: {
                filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, image, nil];
                break;
            }
            case ImageFilterPresetPixelate: {
                CIFilter *posterize = [CIFilter filterWithName:@"CIColorPosterize"];
                [posterize setDefaults];
                [posterize setValue:@64 forKey:@"inputLevels"];
                [posterize setValue:image forKey:@"inputImage"];
                
                filter = [CIFilter filterWithName:@"CIPixellate"];
                [filter setDefaults];
                
                [filter setValue:@64 forKey:@"inputScale"];
                [filter setValue:[posterize valueForKey:@"outputImage"] forKey:@"inputImage"];
                break;
            }
    }
    
    return filter;
}

@end

@implementation UIImage ( Color )

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = (CGRect){{0.0f,0.0f}, size};
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor {
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (UIColor *)colorAtPoint:(CGPoint )point {
    if (point.x < 0 || point.y < 0) return nil;
    
    CGImageRef imageRef = self.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    if (point.x >= width || point.y >= height) return nil;
    
    unsigned char *rawData = malloc(height * width * 4);
    if (!rawData) return nil;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast
                                                 | kCGBitmapByteOrder32Big);
    if (!context) {
        free(rawData);
        return nil;
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int byteIndex = (bytesPerRow * point.y) + point.x * bytesPerPixel;
    CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
    CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
    CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
    
    UIColor *result = nil;
    result = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    free(rawData);
    return result;
}

- (UIColor *)colorAtPixel:(CGPoint)point {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (BOOL)hasAlphaChannel {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

+ (UIImage*)covertToGrayImageFromImage:(UIImage*)sourceImage {
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    CGImageRef contextRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:contextRef];
    CGContextRelease(context);
    CGImageRelease(contextRef);
    
    return grayImage;
}

#pragma mark -

- (UIImage *) imageWithBackgroundColor:(UIColor *)bgColor
                           shadeAlpha1:(CGFloat)alpha1
                           shadeAlpha2:(CGFloat)alpha2
                           shadeAlpha3:(CGFloat)alpha3
                           shadowColor:(UIColor *)shadowColor
                          shadowOffset:(CGSize)shadowOffset
                            shadowBlur:(CGFloat)shadowBlur {
    UIImage *image = self;
    CGColorRef cgColor = [bgColor CGColor];
    CGColorRef cgShadowColor = [shadowColor CGColor];
    CGFloat components[16] = {1,1,1,alpha1,1,1,1,alpha1,1,1,1,alpha2,1,1,1,alpha3};
    CGFloat locations[4] = {0,0.5,0.6,1};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, (size_t)4);
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = [image size];
    //contextRect.size = CGSizeMake([image size].width+5,[image size].height+5);
    // Retrieve source image and begin image context
    UIImage *itemImage = image;
    CGSize itemImageSize = [itemImage size];
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) / 2);
    UIGraphicsBeginImageContext(contextRect.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    // Setup shadow
    CGContextSetShadowWithColor(c, shadowOffset, shadowBlur, cgShadowColor);
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [itemImage CGImage]);
    // Fill and end the transparency layer
    CGContextSetFillColorWithColor(c, cgColor);
    contextRect.size.height = -contextRect.size.height;
    CGContextFillRect(c, contextRect);
    CGContextDrawLinearGradient(c, colorGradient,CGPointZero,CGPointMake(contextRect.size.width*1.0/4.0,contextRect.size.height),0);
    CGContextEndTransparencyLayer(c);
    //CGPointMake(contextRect.size.width*3.0/4.0, 0)
    // Set selected image and end context
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(colorGradient);
    return resultImage;
}

- (UIImage *)imageWithShadowColor:(UIColor *)shadowColor
                     shadowOffset:(CGSize)shadowOffset
                       shadowBlur:(CGFloat)shadowBlur {
    CGColorRef cgShadowColor = [shadowColor CGColor];
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                                       CGImageGetBitsPerComponent(self.CGImage), 0,
                                                       colourSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // Setup shadow
    CGContextSetShadowWithColor(shadowContext, shadowOffset, shadowBlur, cgShadowColor);
    CGRect drawRect = CGRectMake(-shadowBlur, -shadowBlur, self.size.width + shadowBlur, self.size.height + shadowBlur);
    CGContextDrawImage(shadowContext, drawRect, self.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}

- (UIImage *)image:(UIImage *)image withColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width + 3, image.size.height + 3 );
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [image drawInRect:CGRectInset(rect, 3, 3)];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextFillRect(context, rect);
    
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)scaleImage2:(UIImage *)image widthScale:(float)widthScale heightScale:(float)heightScale{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * widthScale, image.size.height * heightScale));
    [image drawInRect:CGRectMake(0, 0, image.size.width * widthScale, image.size.height * heightScale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end

#define offsetMargin 10.0f

@implementation UIImage (Merge)
/**
 *  @brief  合并两个图片
 *
 *  @param firstImage  一个图片
 *  @param secondImage 二个图片
 *  以第一个图片为支点
 *  @return 合并后图片
 */

+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage mergeType:(MergeType)mergeType{
    
    CGImageRef firstImageRef = firstImage.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    CGImageRef secondImageRef = secondImage.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    CGSize mergedSize = CGSizeMake((firstWidth + secondWidth), (firstHeight + secondHeight));
    CGRect xx = CGRectNull, yy = CGRectNull ;
    if (mergeType == diagonal) {
        xx = CGRectMake(0, 0, firstWidth, firstHeight);
        yy = CGRectMake(xx.size.width/2, xx.size.height/2, secondWidth, secondHeight);
    }else if(mergeType == leftMarginTopAlignment) {
        xx = CGRectMake(0, 0, firstWidth, firstHeight);
        yy = CGRectMake(xx.size.width/2, xx.size.height, secondWidth, secondHeight);
    }else if(mergeType == leftMarginTopAlignment2) {
        xx = CGRectMake(0, 0, firstWidth, firstHeight);
        yy = CGRectMake(0 + offsetMargin, xx.size.height, secondWidth, secondHeight);
    }else if(mergeType == leftMarginBottomAlignment) {
        xx = CGRectMake(0, secondHeight, firstWidth, firstHeight);
        yy = CGRectMake(xx.size.width/2, 0, secondWidth, secondHeight);
        
    }else if(mergeType == rightMarginTopAlignment) {
        xx = CGRectMake(mergedSize.width - firstWidth, 0, firstWidth, firstHeight);
        yy = CGRectMake(xx.origin.x +firstWidth/2 - secondWidth + offsetMargin, xx.size.height, secondWidth, secondHeight);
    }else if(mergeType == verticalAlignment) {
        xx = CGRectMake(mergedSize.width/2 - firstWidth/2, 0, firstWidth, firstHeight);
        yy = CGRectMake(mergedSize.width/2 - secondWidth/2 + offsetMargin, xx.size.height, secondWidth, secondHeight);
    }else if(mergeType == horizontalAlignment) {
        xx = CGRectMake(mergedSize.width - firstWidth, 0, firstWidth, firstHeight);
        yy = CGRectMake(0, 0, secondWidth, secondHeight);
    }
    
    UIGraphicsBeginImageContext(mergedSize);
    [firstImage drawInRect:xx];
    [secondImage drawInRect:yy];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end


