//
//  UIImage+Masking.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 6/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "NYXImagesUtilities.h"


@interface UIImage (NYX_Masking)

#ifdef kNYXReturnRetainedObjects

-(UIImage*)maskWithImage:(UIImage*)mask NS_RETURNS_RETAINED;

#else

-(UIImage*)maskWithImage:(UIImage*)mask;

#endif

@end
