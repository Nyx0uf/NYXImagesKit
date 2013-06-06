//
//  UIScrollView+Screenshot.h
//  NYXImagesKit
//
//  Created by @Nyx0uf on 29/03/13.
//  Copyright 2013 Nyx0uf. All rights reserved.
//  www.cocoaintheshell.com
//


#import "UIScrollView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIScrollView (NYX_Screenshot)

-(UIImage*)imageByRenderingCurrentVisibleRect
{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, -self.contentOffset.y);
	[self.layer renderInContext:context];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end
