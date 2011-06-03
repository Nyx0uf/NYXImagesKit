//
//  UIImage+Reflection.m
//  NYXImagesUtilities
//
//  Created by Matthias Tretter (@myell0w) on 02.06.11.

//  This was taken from the increadibly awesome HockeyKit:
//  Originally Created by Peter Steinberger on 10.01.11.
//  Copyright 2011 Peter Steinberger. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "UIImage+Reflection.h"


@implementation UIImage (Reflection)

- (UIImage *)reflectedImageWithHeight:(NSUInteger)height fromAlpha:(float)fromAlpha toAlpha:(float)toAlpha {
    if(height == 0) {
		return nil;
    }
    
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = NYXCreateBitmapContext(self.size.width, height);
    
	// create a 2 bit CGImage containing a gradient that will be used for masking the
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = NYXCreateGradientImage(1, height, fromAlpha, toAlpha);
    
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, self.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);
    
	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    
	// convert the finished reflection image to a UIImage
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
#if kNYXReturnRetainedObjects
    [theImage retain];
#endif
    
	return theImage;
}

@end
