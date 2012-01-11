//
//  UIImage+Rotation.h
//  NYXImagesKit
//
//  Created by @Nyx0uf on 02/05/11.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


#import "NYXImagesHelper.h"


@interface UIImage (NYX_Rotating)

-(UIImage*)rotateInRadians:(float)radians;

-(UIImage*)rotateInDegrees:(float)degrees;

-(UIImage*)rotateImagePixelsInRadians:(float)radians;

-(UIImage*)rotateImagePixelsInDegrees:(float)degrees;

-(UIImage*)verticalFlip;

-(UIImage*)horizontalFlip;

@end
