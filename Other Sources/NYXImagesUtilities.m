//
//  NYXImagesUtilities.m
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#include "NYXImagesUtilities.h"


CGContextRef NYXImageCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow)
{
	/// Use the generic RGB color space
	/// We avoid the NULL check because CGColorSpaceRelease() NULL check the value anyway, and worst case scenario = fail to create context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	/// Create the bitmap context, we want pre-multiplied ARGB, 8-bits per component
	CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);

	CGColorSpaceRelease(colorSpace);

	return bmContext;
}
