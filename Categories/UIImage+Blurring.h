//
//  UIImage+Blurring.h
//  NYXImagesKit
//
//  Created by @Nyx0uf on 03/06/11.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


#import "NYXImagesHelper.h"


@interface UIImage (NYX_Blurring)

-(UIImage*)gaussianBlurWithBias:(NSInteger)bias;

@end
