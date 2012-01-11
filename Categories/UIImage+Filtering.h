//
//  UIImage+Filters.h
//  NYXImagesKit
//
//  Created by @Nyx0uf on 02/05/11.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


#import "NYXImagesHelper.h"


@interface UIImage (NYX_Filtering)

-(UIImage*)brightenWithValue:(float)factor;

-(UIImage*)contrastAdjustmentWithValue:(float)value;

-(UIImage*)edgeDetectionWithBias:(NSInteger)bias;

-(UIImage*)embossWithBias:(NSInteger)bias;

-(UIImage*)gammaCorrectionWithValue:(float)value;

-(UIImage*)grayscale;

-(UIImage*)invert;

-(UIImage*)opacity:(float)value;

-(UIImage*)sepia;

-(UIImage*)sharpenWithBias:(NSInteger)bias;

-(UIImage*)unsharpenWithBias:(NSInteger)bias;

@end
