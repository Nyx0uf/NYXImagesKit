//
//  UIImage+Resize.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 02/05/11.
//  Copyright 2012 Nyx0uf. All rights reserved.
//  www.cocoaintheshell.com
//


#import "UIImage+Resizing.h"


@implementation UIImage (NYX_Resizing)

-(UIImage*)cropToSize:(CGSize)newSize usingMode:(NYXCropMode)cropMode
{
	const CGSize size = self.size;
	CGFloat x, y;
	switch (cropMode)
	{
		case NYXCropModeTopLeft:
			x = y = 0.0f;
			break;
		case NYXCropModeTopCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = 0.0f;
			break;
		case NYXCropModeTopRight:
			x = size.width - newSize.width;
			y = 0.0f;
			break;
		case NYXCropModeBottomLeft:
			x = 0.0f;
			y = size.height - newSize.height;
			break;
		case NYXCropModeBottomCenter:
			x = newSize.width * 0.5f;
			y = size.height - newSize.height;
			break;
		case NYXCropModeBottomRight:
			x = size.width - newSize.width;
			y = size.height - newSize.height;
			break;
		case NYXCropModeLeftCenter:
			x = 0.0f;
			y = (size.height - newSize.height) * 0.5f;
			break;
		case NYXCropModeRightCenter:
			x = size.width - newSize.width;
			y = (size.height - newSize.height) * 0.5f;
			break;
		case NYXCropModeCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = (size.height - newSize.height) * 0.5f;
			break;
		default: // Default to top left
			x = y = 0.0f;
			break;
	}

    CGRect cropRect = CGRectMake(x * self.scale, y * self.scale, newSize.width * self.scale, newSize.height * self.scale);

	/// Create the cropped image
	CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
	UIImage* cropped = [UIImage imageWithCGImage:croppedImageRef scale:self.scale orientation:self.imageOrientation];

	/// Cleanup
	CGImageRelease(croppedImageRef);

	return cropped;
}

/* Convenience method to crop the image from the top left corner */
-(UIImage*)cropToSize:(CGSize)newSize
{
	return [self cropToSize:newSize usingMode:NYXCropModeTopLeft];
}

-(UIImage*)scaleByFactor:(float)scaleFactor
{
	const size_t originalWidth = (size_t)(self.size.width * scaleFactor);
	const size_t originalHeight = (size_t)(self.size.height * scaleFactor);
	/// Number of bytes per row, each pixel in the bitmap will be represented by 4 bytes (ARGB), 8 bits of alpha/red/green/blue
	const size_t bytesPerRow = originalWidth * kNyxNumberOfComponentsPerARBGPixel;

	/// Create an ARGB bitmap context
	CGContextRef bmContext = NYXCreateARGBBitmapContext(originalWidth, originalHeight, bytesPerRow);
	if (!bmContext) 
		return nil;
	
	/// Handle orientation
	if (UIImageOrientationLeft == self.imageOrientation)
	{
		CGContextRotateCTM(bmContext, (CGFloat)M_PI_2);
		CGContextTranslateCTM(bmContext, 0, -originalHeight);
	}
	else if (UIImageOrientationRight == self.imageOrientation)
	{
		CGContextRotateCTM(bmContext, (CGFloat)-M_PI_2);
		CGContextTranslateCTM(bmContext, -originalWidth, 0);
	}
	else if (UIImageOrientationDown == self.imageOrientation)
	{
		CGContextTranslateCTM(bmContext, originalWidth, originalHeight);
		CGContextRotateCTM(bmContext, (CGFloat)-M_PI);
	}

	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight}, self.CGImage);

	/// Create an image object from the context
	CGImageRef scaledImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* scaled = [UIImage imageWithCGImage:scaledImageRef];

	/// Cleanup
	CGImageRelease(scaledImageRef);
	CGContextRelease(bmContext);

	return scaled;
}

-(UIImage*)scaleToFitSize:(CGSize)newSize
{
	const size_t originalWidth = (size_t)self.size.width;
	const size_t originalHeight = (size_t)self.size.height;

	/// Keep aspect ratio
	size_t destWidth, destHeight;
	if (originalWidth > originalHeight)
	{
		destWidth = (size_t)newSize.width;
		destHeight = (size_t)(originalHeight * newSize.width / originalWidth);
	}
	else
	{
		destHeight = (size_t)newSize.height;
		destWidth = (size_t)(originalWidth * newSize.height / originalHeight);
	}
	if (destWidth > newSize.width)
	{ 
		destWidth = (size_t)newSize.width; 
		destHeight = (size_t)(originalHeight * newSize.width / originalWidth);
	} 
	if (destHeight > newSize.height)
	{ 
		destHeight = (size_t)newSize.height; 
		destWidth = (size_t)(originalWidth * newSize.height / originalHeight);
	}

	/// Create an ARGB bitmap context
	CGContextRef bmContext = NYXCreateARGBBitmapContext(destWidth, destHeight, destWidth * kNyxNumberOfComponentsPerARBGPixel);
	if (!bmContext)
		return nil;

	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	/// Draw the image in the bitmap context

    UIGraphicsPushContext(bmContext);
    CGContextTranslateCTM(bmContext, 0.0f, destHeight);
    CGContextScaleCTM(bmContext, 1.0f, -1.0f);
    [self drawInRect:(CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = destWidth, .size.height = destHeight}];    
    UIGraphicsPopContext();

	/// Create an image object from the context
	CGImageRef scaledImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* scaled = [UIImage imageWithCGImage:scaledImageRef];

	/// Cleanup
	CGImageRelease(scaledImageRef);
	CGContextRelease(bmContext);

	return scaled;	
}

@end
