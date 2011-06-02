//
//  UIImage+Resize.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "NYXImagesHelper.h"


typedef enum
{
	NYXCropModeTopLeft,
	NYXCropModeTopCenter,
	NYXCropModeTopRight,
	NYXCropModeBottomLeft,
	NYXCropModeBottomCenter,
	NYXCropModeBottomRight,
	NYXCropModeLeftCenter,
	NYXCropModeRightCenter,
	NYXCropModeCenter
} NYXCropMode;


@interface UIImage (NYX_Resizing)

#ifdef kNYXReturnRetainedObjects

-(UIImage*)cropToSize:(CGSize)newSize usingMode:(NYXCropMode)cropMode NS_RETURNS_RETAINED;

-(UIImage*)cropToSize:(CGSize)newSize NS_RETURNS_RETAINED;

-(UIImage*)scaleByFactor:(CGFloat)scaleFactor NS_RETURNS_RETAINED;

-(UIImage*)scaleToFitSize:(CGSize)newSize NS_RETURNS_RETAINED;

#else

-(UIImage*)cropToSize:(CGSize)newSize usingMode:(NYXCropMode)cropMode;

-(UIImage*)cropToSize:(CGSize)newSize;

-(UIImage*)scaleByFactor:(CGFloat)scaleFactor;

-(UIImage*)scaleToFitSize:(CGSize)newSize;

#endif

@end
