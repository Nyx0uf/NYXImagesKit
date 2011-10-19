//
//  UIImage+Rotation.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "NYXImagesHelper.h"


@interface UIImage (NYX_Rotating)

-(UIImage*)rotateInDegrees:(CGFloat)degrees;

-(UIImage*)rotateInRadians:(CGFloat)radians;

-(UIImage*)verticalFlip;

-(UIImage*)horizontalFlip;

@end
