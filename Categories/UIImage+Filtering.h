//
//  UIImage+Filters.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "NYXImagesHelper.h"


@interface UIImage (NYX_Filtering)

#ifdef kNYXReturnRetainedObjects

-(UIImage*)sepia NS_RETURNS_RETAINED;

-(UIImage*)grayscale NS_RETURNS_RETAINED;

-(UIImage*)opacity:(CGFloat)value NS_RETURNS_RETAINED;

#else

-(UIImage*)sepia;

-(UIImage*)grayscale;

-(UIImage*)opacity:(CGFloat)value;

#endif

@end
