//
//  UIImage+Rotation.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "NYXImagesUtilities.h"


@interface UIImage (NYX_Rotating)

#ifdef kNYXReturnRetainedObjects

-(UIImage*)rotateInDegrees:(CGFloat)degrees NS_RETURNS_RETAINED;

-(UIImage*)rotateInRadians:(CGFloat)radians NS_RETURNS_RETAINED;

-(UIImage*)verticalFlip NS_RETURNS_RETAINED;

-(UIImage*)horizontalFlip NS_RETURNS_RETAINED;

#else

-(UIImage*)rotateInDegrees:(CGFloat)degrees;

-(UIImage*)rotateInRadians:(CGFloat)radians;

-(UIImage*)verticalFlip;

-(UIImage*)horizontalFlip;

#endif

@end
