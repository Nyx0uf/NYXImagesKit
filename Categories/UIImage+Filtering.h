//
//  UIImage+Filters.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "NYXImagesHelper.h"


@interface UIImage (NYX_Filtering)

-(UIImage*)sepia;

-(UIImage*)grayscale;

-(UIImage*)opacity:(CGFloat)value;

@end
