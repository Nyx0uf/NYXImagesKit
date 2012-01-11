//
//  UIImage+Rotation.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 02/05/11.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


#import "UIImage+Rotating.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>


@implementation UIImage (NYX_Rotating)

-(UIImage*)rotateInRadians:(float)radians
{
	const size_t width = self.size.width;
	const size_t height = self.size.height;

	CGRect imgRect = (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height};
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, CGAffineTransformMakeRotation(radians));

	/// Create an ARGB bitmap context
	CGContextRef bmContext = NYXCreateARGBBitmapContext(rotatedRect.size.width, rotatedRect.size.height, 0);
	if (!bmContext)
		return nil;
	
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	/// Rotation happen here (around the center)
	CGContextTranslateCTM(bmContext, +(rotatedRect.size.width * 0.5f), +(rotatedRect.size.height * 0.5f));
	CGContextRotateCTM(bmContext, radians);

	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = -(width * 0.5f), .origin.y = -(height * 0.5f), .size.width = width, .size.height = height}, self.CGImage);

	/// Create an image object from the context
	CGImageRef rotatedImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* rotated = [UIImage imageWithCGImage:rotatedImageRef];

	/// Cleanup
	CGImageRelease(rotatedImageRef);
	CGContextRelease(bmContext);

	return rotated;
}

-(UIImage*)rotateInDegrees:(float)degrees
{
	return [self rotateInRadians:NYX_DEGREES_TO_RADIANS(degrees)];
}

-(UIImage*)rotateImagePixelsInRadians:(float)radians
{
	if (!(&vImageRotate_ARGB8888))
		return nil;

	/// Create an ARGB bitmap context
	const size_t width = self.size.width;
	const size_t height = self.size.height;
	const size_t bytesPerRow = width * kNyxNumberOfComponentsPerARBGPixel;
	CGContextRef bmContext = NYXCreateARGBBitmapContext(width, height, bytesPerRow);
	if (!bmContext) 
		return nil;
	
	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, self.CGImage); 
	
	/// Grab the image raw data
	UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
	if (!data)
	{
		CGContextRelease(bmContext);
		return nil;
	}
	
	vImage_Buffer src = {data, height, width, bytesPerRow};
	vImage_Buffer dest = {data, height, width, bytesPerRow};
	Pixel_8888 bgColor = {0, 0, 0, 0};
	vImageRotate_ARGB8888(&src, &dest, NULL, radians, bgColor, kvImageBackgroundColorFill);
	
	CGImageRef rotatedImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* rotated = [UIImage imageWithCGImage:rotatedImageRef];
	
	/// Cleanup
	CGImageRelease(rotatedImageRef);
	CGContextRelease(bmContext);
	
	return rotated;
}

-(UIImage*)rotateImagePixelsInDegrees:(float)degrees
{
	return [self rotateImagePixelsInRadians:NYX_DEGREES_TO_RADIANS(degrees)];
}

-(UIImage*)verticalFlip
{
	/// Create an ARGB bitmap context
	const size_t originalWidth = self.size.width;
	const size_t originalHeight = self.size.height;
	CGContextRef bmContext = NYXCreateARGBBitmapContext(originalWidth, originalHeight, originalWidth * kNyxNumberOfComponentsPerARBGPixel);
	if (!bmContext)
		return nil;

	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	CGContextTranslateCTM(bmContext, 0.0f, originalHeight);
	CGContextScaleCTM(bmContext, 1.0f, -1.0f);
	
	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0, .size.width = originalWidth, .size.height = originalHeight}, self.CGImage);
	
	/// Create an image object from the context
	CGImageRef flippedImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* flipped = [UIImage imageWithCGImage:flippedImageRef];
	
	/// Cleanup
	CGImageRelease(flippedImageRef);
	CGContextRelease(bmContext);
	
	return flipped;
}

-(UIImage*)horizontalFlip
{
	/// Create an ARGB bitmap context
	const size_t originalWidth = self.size.width;
	const size_t originalHeight = self.size.height;
	CGContextRef bmContext = NYXCreateARGBBitmapContext(originalWidth, originalHeight, originalWidth * kNyxNumberOfComponentsPerARBGPixel);
	if (!bmContext)
		return nil;
	
	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	CGContextTranslateCTM(bmContext, originalWidth, 0.0f);
	CGContextScaleCTM(bmContext, -1.0f, 1.0f);
	
	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight}, self.CGImage);
	
	/// Create an image object from the context
	CGImageRef flippedImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* flipped = [UIImage imageWithCGImage:flippedImageRef];
	
	/// Cleanup
	CGImageRelease(flippedImageRef);
	CGContextRelease(bmContext);
	
	return flipped;
}

@end
