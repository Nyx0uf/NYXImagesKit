//
//  NYXImagesUtilities.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


/* If defined, categories methods will return object with a +1 retain count, so you have to release them manually */
//#define kNYXReturnRetainedObjects

/* Source : http://clang-analyzer.llvm.org/annotations 
   Better place it in your Prefix.pch file
 */
#ifndef __has_feature      // Optional.
	#define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif

#ifndef NS_RETURNS_RETAINED
	#if __has_feature(attribute_ns_returns_retained)
		#define NS_RETURNS_RETAINED __attribute__((ns_returns_retained))
	#else
		#define NS_RETURNS_RETAINED
	#endif
#endif

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

static inline CGFloat degrees_to_radians(const CGFloat degrees)
{
	return degrees * 0.017453293; // (M_PI / 180.0f)
}

static inline CGFloat radians_to_degrees(const CGFloat radians)
{
	return radians * 57.295779513; // (180.0f / M_PI)
}

CGContextRef NYXImageCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow);
