//
//  UIImage+Masking.m
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 6/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "UIImage+Masking.h"


@implementation UIImage (NYX_Masking)

-(UIImage*)maskWithImage:(UIImage*)maskImage
{
	CGImageRef cgImage = self.CGImage;
	const size_t originalWidth = CGImageGetWidth(cgImage);
	const size_t originalHeight = CGImageGetHeight(cgImage);

	/// Create a bitmap context with valid alpha
	CGContextRef bmContext = NYXImageCreateARGBBitmapContext(originalWidth, originalHeight, 0);
	if (!bmContext)
		return nil;

	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	/// Image mask
	CGImageRef cgMaskImage = maskImage.CGImage; 
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(cgMaskImage), CGImageGetHeight(cgMaskImage), CGImageGetBitsPerComponent(cgMaskImage), CGImageGetBitsPerPixel(cgMaskImage), CGImageGetBytesPerRow(cgMaskImage), CGImageGetDataProvider(cgMaskImage), NULL, false);

	/// Draw the original image in the bitmap context
	const CGRect r = (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight};
	CGContextClipToMask(bmContext, r, cgMaskImage);
	CGContextDrawImage(bmContext, r, cgImage);

	/// Get the CGImage object
	CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(bmContext);
	/// Apply the mask
	CGImageRef maskedImageRef = CGImageCreateWithMask(imageRefWithAlpha, mask);

	UIImage* result = [UIImage imageWithCGImage:maskedImageRef];

	/// Cleanup
	CGImageRelease(maskedImageRef);
	CGImageRelease(imageRefWithAlpha);
	CGContextRelease(bmContext);
	CGImageRelease(mask);

    return result;
}

@end
