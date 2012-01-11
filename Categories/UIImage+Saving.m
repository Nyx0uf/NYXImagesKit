//
//  UIImage+Saving.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 05/05/11.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


#import "UIImage+Saving.h"
#import <ImageIO/ImageIO.h> // For CGImageDestination
#import <MobileCoreServices/MobileCoreServices.h> // For the UTI types constants
#import <AssetsLibrary/AssetsLibrary.h> // For photos album saving


@interface UIImage(NYX_Saving_private)
-(CFStringRef)utiForType:(NYXImageType)type;
@end


@implementation UIImage (NYX_Saving)

-(BOOL)saveToURL:(NSURL*)url type:(NYXImageType)type backgroundFillColor:(UIColor*)fillColor
{
	if (!url)
		return NO;

	CGImageDestinationRef dest = CGImageDestinationCreateWithURL((__bridge CFURLRef)url, [self utiForType:type], 1, NULL);
	if (!dest)
		return NO;

	/// Set the options, 1 -> lossless
	CFMutableDictionaryRef options = CFDictionaryCreateMutable(kCFAllocatorDefault, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	if (!options)
	{
		CFRelease(dest);
		return NO;
	}
	CFDictionaryAddValue(options, kCGImageDestinationLossyCompressionQuality, (__bridge CFNumberRef)[NSNumber numberWithFloat:1.0f]); // No compression
	if (fillColor)
		CFDictionaryAddValue(options, kCGImageDestinationBackgroundColor, fillColor.CGColor);

	/// Add the image
	CGImageDestinationAddImage(dest, self.CGImage, (CFDictionaryRef)options);

	/// Write it to the destination
	const bool success = CGImageDestinationFinalize(dest);

	/// Cleanup
	CFRelease(options);
	CFRelease(dest);

	return success;
}

-(BOOL)saveToURL:(NSURL*)url
{
	return [self saveToURL:url type:NYXImageTypePNG backgroundFillColor:nil];
}

-(BOOL)saveToPath:(NSString*)path type:(NYXImageType)type backgroundFillColor:(UIColor*)fillColor
{
	if (!path)
		return NO;

	NSURL* url = [[NSURL alloc] initFileURLWithPath:path];
	const BOOL ret = [self saveToURL:url type:type backgroundFillColor:fillColor];
	return ret;
}

-(BOOL)saveToPath:(NSString*)path
{
	if (!path)
		return NO;

	NSURL* url = [[NSURL alloc] initFileURLWithPath:path];
	const BOOL ret = [self saveToURL:url type:NYXImageTypePNG backgroundFillColor:nil];
	return ret;
}

-(BOOL)saveToPhotosAlbum
{
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	__block BOOL ret = YES;
	[library writeImageToSavedPhotosAlbum:self.CGImage orientation:(ALAssetOrientation)self.imageOrientation completionBlock:^(NSURL* assetURL, NSError* error) {
		if (!assetURL)
		{
			NSLog(@"%@", error);
			ret = NO;
		}
	}];
	return ret;
}

#pragma mark - Private
-(CFStringRef)utiForType:(NYXImageType)type
{
	CFStringRef uti = NULL;
	switch (type)
	{
		case NYXImageTypeBMP:
			uti = kUTTypeBMP;
			break;
		case NYXImageTypeJPEG:
			uti = kUTTypeJPEG;
			break;
		case NYXImageTypePNG:
			uti = kUTTypePNG;
			break;
		case NYXImageTypeTIFF:
			uti = kUTTypeTIFF;
			break;
		case NYXImageTypeGIF:
			uti = kUTTypeGIF;
			break;
		default:
			uti = kUTTypePNG;
			break;
	}
	return uti;
}

@end
