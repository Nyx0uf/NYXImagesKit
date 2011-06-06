//
//  UIImage+Blurring.m
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 6/3/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//

//
// The following method was written by Jeff Lamarche (@jeff_lamarche), I am using it with his consent.
// His original blog post for this code (2010-08) : http://iphonedevelopment.blogspot.com/2010/08/uiimage-blur.html
//


#import "UIImage+Blurring.h"


@implementation UIImage (NYX_Blurring)

-(UIImage*)blurredCopyUsingGaussFactor:(NSUInteger)gaussFactor andPixelRadius:(NSUInteger)pixelRadius
{
	CGImageRef cgImage = self.CGImage;
	const size_t originalWidth = CGImageGetWidth(cgImage);
	const size_t originalHeight = CGImageGetHeight(cgImage);
	const size_t bytesPerRow = originalWidth * 4;
	CGContextRef context = NYXImageCreateARGBBitmapContext(originalWidth, originalHeight, bytesPerRow);
    if (!context) 
        return nil;

	unsigned char *srcData, *destData, *finalData;
	
    size_t width = CGBitmapContextGetWidth(context);
    size_t height = CGBitmapContextGetHeight(context);
    size_t bpr = CGBitmapContextGetBytesPerRow(context);
	size_t bpp = CGBitmapContextGetBitsPerPixel(context) / 8;
	CGRect rect = {{0.0f, 0.0f}, {width, height}}; 
	
    CGContextDrawImage(context, rect, cgImage); 
	
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    srcData = (unsigned char*)CGBitmapContextGetData(context);
    if (srcData != NULL)
    {
		size_t dataSize = bpr * height;
		finalData = malloc(dataSize);
		destData = malloc(dataSize);
		memcpy(finalData, srcData, dataSize);
		memcpy(destData, srcData, dataSize);
		
		int sums[gaussFactor];
		size_t i, /*x, y,*/ k;
		int gauss_sum = 0;
		size_t radius = pixelRadius * 2 + 1;
		int *gauss_fact = malloc(radius * sizeof(int));
		
		for (i = 0; i < pixelRadius; i++)
		{
			gauss_fact[i] = 1 + (gaussFactor * i);
			gauss_fact[radius - (i + 1)] = 1 + (gaussFactor * i);
			gauss_sum += (gauss_fact[i] + gauss_fact[radius - (i + 1)]);
		}
		gauss_fact[(radius - 1) / 2] = 1 + (gaussFactor*pixelRadius);
		gauss_sum += gauss_fact[(radius - 1) / 2];
		
		unsigned char *p1, *p2, *p3;
		
		for (size_t y = 0; y < height; y++) 
		{
			for (size_t x = 0; x < width; x++) 
			{
				p1 = srcData + bpp * (y * width + x); 
				p2 = destData + bpp * (y * width + x);
				
				for (i = 0; i < gaussFactor; i++)
					sums[i] = 0;
				
				for (k = 0; k < radius ; k++)
				{
					if ((y - ((radius - 1) >> 1) + k) < height)
						p1 = srcData + bpp * ((y - ((radius - 1) >> 1) + k) * width + x); 
					else
						p1 = srcData + bpp * (y * width + x);
					
					for (i = 0; i < bpp; i++)
						sums[i] += p1[i] * gauss_fact[k];
					
				}
				for (i = 0; i < bpp; i++)
					p2[i] = sums[i] / gauss_sum;
			}
		}
		for (size_t y = 0; y < height; y++) 
		{
			for (size_t x = 0; x < width; x++) 
			{
				p2 = destData + bpp * (y * width + x);
				p3 = finalData + bpp * (y * width + x);

				for (i = 0; i < gaussFactor; i++)
					sums[i] = 0;
				
				for(k = 0; k < radius ; k++)
				{
					if ((x - ((radius - 1) >> 1) + k) < width)
						p1 = srcData + bpp * ( y * width + (x - ((radius - 1) >> 1) + k)); 
					else
						p1 = srcData + bpp * (y * width + x);
					
					for (i = 0; i < bpp; i++)
						sums[i] += p2[i] * gauss_fact[k];
					
				}
				for (i = 0; i < bpp; i++)
				{
					p3[i] = sums[i] / gauss_sum;
				}
			}
		}
    }

	size_t bitmapByteCount = bpr * height;

	///////Here was the problem.. you had given srcData instead of destData.. Rest all 
	//were perfect...
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, destData, bitmapByteCount, NULL);

    CGImageRef blurredImageRef = CGImageCreate(width, height, CGBitmapContextGetBitsPerComponent(context), CGBitmapContextGetBitsPerPixel(context), CGBitmapContextGetBytesPerRow(context), CGBitmapContextGetColorSpace(context), CGBitmapContextGetBitmapInfo(context), dataProvider, NULL, true, kCGRenderingIntentDefault);

    CGDataProviderRelease(dataProvider);
    CGContextRelease(context); 
	if (destData)
		free(destData);
    if (finalData)
        free(finalData);
	
#ifdef kNYXReturnRetainedObjects 
	UIImage* retUIImage = [[UIImage alloc] initWithCGImage:blurredImageRef];
#else
	UIImage* retUIImage = [UIImage imageWithCGImage:blurredImageRef];
#endif

	CGImageRelease(blurredImageRef);

	return retUIImage;
}

@end
