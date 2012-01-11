//
//  UIImage+Blurring.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 03/06/11.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


#import "UIImage+Blurring.h"
#import <Accelerate/Accelerate.h>


static float __f_gaussianblur_kernel_5x5[25] = { 
	1.0f/256.0f,  4.0f/256.0f,  6.0f/256.0f,  4.0f/256.0f, 1.0f/256.0f,
	4.0f/256.0f, 16.0f/256.0f, 24.0f/256.0f, 16.0f/256.0f, 4.0f/256.0f,
	6.0f/256.0f, 24.0f/256.0f, 36.0f/256.0f, 24.0f/256.0f, 6.0f/256.0f,
	4.0f/256.0f, 16.0f/256.0f, 24.0f/256.0f, 16.0f/256.0f, 4.0f/256.0f,
	1.0f/256.0f,  4.0f/256.0f,  6.0f/256.0f,  4.0f/256.0f, 1.0f/256.0f
};

static int16_t __s_gaussianblur_kernel_5x5[25] = {
	1, 4, 6, 4, 1, 
	4, 16, 24, 16, 4,
	6, 24, 36, 24, 6,
	4, 16, 24, 16, 4,
	1, 4, 6, 4, 1
};


@implementation UIImage (NYX_Blurring)

-(UIImage*)gaussianBlurWithBias:(NSInteger)bias
{
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

	/// vImage (iOS 5)
	if ((&vImageConvolveWithBias_ARGB8888))
	{
		const size_t n = sizeof(UInt8) * width * height * 4;
		void* outt = malloc(n);
		vImage_Buffer src = {data, height, width, bytesPerRow};
		vImage_Buffer dest = {outt, height, width, bytesPerRow};
		vImageConvolveWithBias_ARGB8888(&src, &dest, NULL, 0, 0, __s_gaussianblur_kernel_5x5, 5, 5, 256/*divisor*/, bias, NULL, kvImageCopyInPlace);
		memcpy(data, outt, n);
		free(outt);
	}
	else
	{
		const size_t pixelsCount = width * height;
		const size_t n = sizeof(float) * pixelsCount;
		float* dataAsFloat = malloc(n);
		float* resultAsFloat = malloc(n);

		/// Red components
		vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
		vDSP_f5x5(dataAsFloat, height, width, __f_gaussianblur_kernel_5x5, resultAsFloat);
		vDSP_vfixu8(resultAsFloat, 1, data + 1, 4, pixelsCount);

		/// Green components
		vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
		vDSP_f5x5(dataAsFloat, height, width, __f_gaussianblur_kernel_5x5, resultAsFloat);
		vDSP_vfixu8(resultAsFloat, 1, data + 2, 4, pixelsCount);

		/// Blue components
		vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
		vDSP_f5x5(dataAsFloat, height, width, __f_gaussianblur_kernel_5x5, resultAsFloat);
		vDSP_vfixu8(resultAsFloat, 1, data + 3, 4, pixelsCount);

		free(resultAsFloat);
		free(dataAsFloat);
	}

	CGImageRef blurredImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* blurred = [UIImage imageWithCGImage:blurredImageRef];

	/// Cleanup
	CGImageRelease(blurredImageRef);
	CGContextRelease(bmContext);

	return blurred;
}

@end
