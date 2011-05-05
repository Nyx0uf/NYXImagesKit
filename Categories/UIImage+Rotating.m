//
//  UIImage+Rotation.m
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "UIImage+Rotating.h"

@interface UIImage (NYX_Rotating_private)
#ifdef kNYXReturnRetainedObjects
-(UIImage*)flip:(BOOL)horizontal NS_RETURNS_RETAINED;
#else
-(UIImage*)flip:(BOOL)horizontal;
#endif
@end


@implementation UIImage (NYX_Rotating)

-(UIImage*)rotateInRadians:(CGFloat)radians
{
	CGImageRef cgImage = self.CGImage;
	const CGFloat originalWidth = CGImageGetWidth(cgImage);
	const CGFloat originalHeight = CGImageGetHeight(cgImage);

	const CGRect imgRect = (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight};
	const CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, CGAffineTransformMakeRotation(radians));

	/// Create an ARGB bitmap context
	CGContextRef bmContext = NYXImageCreateARGBBitmapContext(rotatedRect.size.width, rotatedRect.size.height, 0);
	if (!bmContext)
		return nil;

	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	/// Rotation happen here
	CGContextTranslateCTM(bmContext, +(rotatedRect.size.width * 0.5f), +(rotatedRect.size.height * 0.5f));
	CGContextRotateCTM(bmContext, radians);

	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = -originalWidth * 0.5f, .origin.y = -originalHeight * 0.5f, .size.width = originalWidth, .size.height = originalHeight}, cgImage);

	/// Create an image object from the context
	CGImageRef rotatedImageRef = CGBitmapContextCreateImage(bmContext);
#ifdef kNYXReturnRetainedObjects 
	UIImage* rotated = [[UIImage alloc] initWithCGImage:rotatedImageRef];
#else
	UIImage* rotated = [UIImage imageWithCGImage:rotatedImageRef];
#endif

	/// Cleanup
	CGImageRelease(rotatedImageRef);
	CGContextRelease(bmContext);

	return rotated;
}

/* Convenience method to rotate an image which take the angle in degrees */
-(UIImage*)rotateInDegrees:(CGFloat)degrees
{
	return [self rotateInRadians:degrees_to_radians(degrees)];
}

/* Convenience method to rotate an image at 180 degrees */
-(UIImage*)verticalFlip
{
	return [self flip:NO];
}

-(UIImage*)horizontalFlip
{
	return [self flip:YES];
}

#pragma mark - Private
-(UIImage*)flip:(BOOL)horizontal
{
	CGImageRef cgImage = self.CGImage;
	const CGFloat originalWidth = CGImageGetWidth(cgImage);
	const CGFloat originalHeight = CGImageGetHeight(cgImage);
	/// Number of bytes per row, each pixel in the bitmap will be represented by 4 bytes (ARGB), 8 bits of alpha/red/green/blue
	const size_t bytesPerRow = originalWidth * 4;

	/// Create an ARGB bitmap context
	CGContextRef bmContext = NYXImageCreateARGBBitmapContext(originalWidth, originalHeight, bytesPerRow);
	if (!bmContext)
		return nil;

	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	horizontal ? CGContextScaleCTM(bmContext, -1.0f, 1.0f) : CGContextScaleCTM(bmContext, 1.0f, -1.0f);

	/// Draw the image in the bitmap context
	const CGRect r = horizontal ? (CGRect){.origin.x = -originalWidth, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight}: (CGRect){.origin.x = 0.0f, .origin.y = -originalHeight, .size.width = originalWidth, .size.height = originalHeight};
	CGContextDrawImage(bmContext, r, cgImage);

	/// Create an image object from the context
	CGImageRef flippedImageRef = CGBitmapContextCreateImage(bmContext);
#ifdef kNYXReturnRetainedObjects 
	UIImage* flipped = [[UIImage alloc] initWithCGImage:flippedImageRef];
#else
	UIImage* flipped = [UIImage imageWithCGImage:flippedImageRef];
#endif

	/// Cleanup
	CGImageRelease(flippedImageRef);
	CGContextRelease(bmContext);

	return flipped;
}

@end
