//
//  UIView+Screenshot.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 29/03/13.
//  Copyright 2013 Nyx0uf. All rights reserved.
//  www.cocoaintheshell.com
//


#import "UIView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (NYX_Screenshot)

-(UIImage*)imageByRenderingView
{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end
