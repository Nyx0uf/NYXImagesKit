//
//  UIImage+Blurring.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 6/3/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//

//
// The following method was written by Jeff Lamarche (@jeff_lamarche), I am using it with his consent.
// His original blog post for this code (2010-08) : http://iphonedevelopment.blogspot.com/2010/08/uiimage-blur.html
//


#import "NYXImagesHelper.h"


@interface UIImage (NYX_Blurring)

-(UIImage*)blurredImageUsingGaussFactor:(NSUInteger)gaussFactor andPixelRadius:(NSUInteger)pixelRadius;

@end
