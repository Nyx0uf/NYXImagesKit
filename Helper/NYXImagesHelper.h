//
//  NYXImagesHelper.h
//  NYXImagesUtilities
//
//  Created by Matthias Tretter on 02.06.11.
//  Originally Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


/* Represents an ARGB pixel */
typedef struct 
{
	/// Alpha component
	UInt8 _a;
	/// Red component
	UInt8 _r;
	/// Green component
	UInt8 _g;
	/// Blue component
	UInt8 _b;
} ARGBPixel;


static inline CGFloat NYXDegreesToRadians(const CGFloat degrees)
{
	return degrees * 0.017453293; // (M_PI / 180.0f)
}

static inline CGFloat NYXRadiansToDegrees(const CGFloat radians)
{
	return radians * 57.295779513; // (180.0f / M_PI)
}

CGContextRef NYXImageCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow);
CGContextRef NYXGetBitmapContext(const int pixelsWide, const int pixelsHigh);
CGImageRef NYXCreateGradientImage(const size_t pixelsWide, const size_t pixelsHigh, const CGFloat fromAlpha, const CGFloat toAlpha);
