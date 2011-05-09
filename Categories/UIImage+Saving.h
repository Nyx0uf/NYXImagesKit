//
//  UIImage+Saving.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/5/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "NYXImagesUtilities.h"


typedef enum
{
	NYXImageTypePNG,
	NYXImageTypeJPEG,
	NYXImageTypeGIF,
	NYXImageTypeBMP,
	NYXImageTypeTIFF
} NYXImageType;


@interface UIImage (NYX_Saving)

-(BOOL)saveToURL:(NSURL*)url type:(NYXImageType)type backgroundFillColor:(UIColor*)fillColor;

-(BOOL)saveToURL:(NSURL*)url;

-(BOOL)saveToPath:(NSString*)path type:(NYXImageType)type backgroundFillColor:(UIColor*)fillColor;

-(BOOL)saveToPath:(NSString*)path;

@end
