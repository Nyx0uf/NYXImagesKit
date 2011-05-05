//
//  UIImage+Filters.m
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "UIImage+Filtering.h"


@implementation UIImage (NYX_Filtering)

-(UIImage*)sepia
{
	CGImageRef cgImage = self.CGImage;
	const size_t originalWidth = CGImageGetWidth(cgImage);
	const size_t originalHeight = CGImageGetHeight(cgImage);
	/// Number of bytes per row, each pixel in the bitmap will be represented by 4 bytes (ARGB), 8 bits of alpha/red/green/blue
	const size_t bytesPerRow = originalWidth * 4;

	/// Create an ARGB bitmap context
	CGContextRef bmContext = NYXImageCreateARGBBitmapContext(originalWidth, originalHeight, bytesPerRow);
	if (!bmContext) 
		return nil;

	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight}, cgImage);

	/// Grab the image raw data
	UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
	if (!data)
	{
		CGContextRelease(bmContext);
		return nil;
	}
	const size_t bitmapByteCount = bytesPerRow * originalHeight;
	for (size_t i = 0; i < bitmapByteCount; i += 4)
	{
		UInt8 r = data[i + 1];
		UInt8 g = data[i + 2];
		UInt8 b = data[i + 3];

		NSInteger newRed = (r * .393) + (g * .769) + (b * .189);
		NSInteger newGreen = (r * .349) + (g * .686) + (b * .168);
		NSInteger newBlue = (r * .272) + (g * .534) + (b * .131);

		if (newRed > 255) newRed = 255;
		if (newGreen > 255) newGreen = 255;
		if (newBlue > 255) newBlue = 255;

		data[i + 1] = (UInt8)newRed;
		data[i + 2] = (UInt8)newGreen;
		data[i + 3] = (UInt8)newBlue;
	}

	/// Create an image object from the context
	CGImageRef sepiaImageRef = CGBitmapContextCreateImage(bmContext);
#ifdef kNYXReturnRetainedObjects 
	UIImage* sepia = [[UIImage alloc] initWithCGImage:sepiaImageRef];
#else
	UIImage* sepia = [UIImage imageWithCGImage:sepiaImageRef];
#endif

	/// Cleanup
	CGImageRelease(sepiaImageRef);
	CGContextRelease(bmContext);

	return sepia;
}

-(UIImage*)grayscale
{
	CGImageRef cgImage = self.CGImage;
	const CGFloat originalWidth = CGImageGetWidth(cgImage);
	const CGFloat originalHeight = CGImageGetHeight(cgImage);

	/// Create a gray bitmap context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef bmContext = CGBitmapContextCreate(NULL, originalWidth, originalHeight, 8/*Bits per component*/, /*CGImageGetBytesPerRow(cgImage)*/ 3 * originalWidth, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	if (!bmContext)
		return nil;

	/// Image quality
	CGContextSetShouldAntialias(bmContext, false);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight}, cgImage);

	/// Create an image object from the context
	CGImageRef grayscaledImageRef = CGBitmapContextCreateImage(bmContext);
#ifdef kNYXReturnRetainedObjects 
	UIImage* grayscaled = [[UIImage alloc] initWithCGImage:grayscaledImageRef];
#else
	UIImage* grayscaled = [UIImage imageWithCGImage:grayscaledImageRef];
#endif

	/// Cleanup
	CGImageRelease(grayscaledImageRef);
	CGContextRelease(bmContext);

	return grayscaled;
}

-(UIImage*)opacity:(CGFloat)value
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

	/// Draw the image in the bitmap context
	CGContextSetAlpha(bmContext, value);
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight}, cgImage);

	/// Create an image object from the context
	CGImageRef transparentImageRef = CGBitmapContextCreateImage(bmContext);
#ifdef kNYXReturnRetainedObjects 
	UIImage* transparent = [[UIImage alloc] initWithCGImage:transparentImageRef];
#else
	UIImage* transparent = [UIImage imageWithCGImage:transparentImageRef];
#endif

	/// Cleanup
	CGImageRelease(transparentImageRef);
	CGContextRelease(bmContext);

	return transparent;
}

@end
