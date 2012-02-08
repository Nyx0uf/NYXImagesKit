//
//  UIImageView+ProgressiveDisplay.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 13/01/12.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//  Caching stuff by raphaelp
//


#import "NYXProgressiveImageView.h"
#import "NYXImagesHelper.h"
#import "UIImage+Saving.h"
#import <ImageIO/ImageIO.h>
#import <CommonCrypto/CommonDigest.h>


#define kNyxDefaultCacheTime 604800.0f // 7 days


@interface NYXProgressiveImageView()
-(void)initializeAttributes;
-(CGImageRef)createTransitoryImage:(CGImageRef)partialImage CF_RETURNS_RETAINED;
+(NSString*)cacheDirectoryAddress;
-(NSString*)cachedImageSystemName;
-(void)resetCache;
@end


@implementation NYXProgressiveImageView
{
	/// Image download connection
	NSURLConnection* _connection;
	/// Downloaded data
	NSMutableData* _dataTemp;
	/// Image source for progressive display
	CGImageSourceRef _imageSource;
	/// Width of the downloaded image
	int _imageWidth;
	/// Height of the downloaded image
	int _imageHeight;
	/// Expected image size
	long long _expectedSize;
	/// Connection queue
	dispatch_queue_t _queue;
	/// Url
	NSURL * _url;   
}

@synthesize delegate = _delegate;
@synthesize caching = _caching;
@synthesize cacheTime = _cacheTime;

#pragma mark - Allocations
-(id)init
{
	if ((self = [super init]))
	{
		[self initializeAttributes];
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializeAttributes];
	}
	return self;
}

-(id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initializeAttributes];
	}
	return self;
}

-(id)initWithImage:(UIImage*)image
{
	if ((self = [super initWithImage:image]))
	{
		[self initializeAttributes];
	}
	return self;
}

-(id)initWithImage:(UIImage*)image highlightedImage:(UIImage*)highlightedImage
{
	if ((self = [super initWithImage:image highlightedImage:highlightedImage]))
	{
		[self initializeAttributes];
	}
	return self;
}

#pragma mark - Public
-(void)loadImageAtURL:(NSURL*)url
{
    _url = url;

	if (_caching)
	{
        NSFileManager* fileManager = [[NSFileManager alloc] init];

		// check if file exists on cache
		NSString* cacheDir = [NYXProgressiveImageView cacheDirectoryAddress];
		NSString* cachedImagePath = [cacheDir stringByAppendingPathComponent:[self cachedImageSystemName]];
		if ([fileManager fileExistsAtPath:cachedImagePath])
		{
			NSDate* mofificationDate = [[fileManager attributesOfItemAtPath:cachedImagePath error:nil] objectForKey:NSFileModificationDate];
            
			// check modification date
			if (-[mofificationDate timeIntervalSinceNow] > _cacheTime)
			{
				// Removes old cache file...
				[self resetCache];
			}
			else
			{
				// Loads image from cache without networking
				UIImage* localImage = [[UIImage alloc] initWithContentsOfFile:cachedImagePath];
				self.image = localImage;
				return;
			}
		}
	}

	_queue = dispatch_queue_create("com.cocoabyss.pdlqueue", DISPATCH_QUEUE_SERIAL);
	dispatch_async(_queue, ^{
		NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0f];
		_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
		[_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		[_connection start];
		CFRunLoopRun();
	});
}

+(void)resetImageCache
{
	[[NSFileManager defaultManager] removeItemAtPath:[NYXProgressiveImageView cacheDirectoryAddress] error:nil];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
#pragma unused(connection)
	_imageSource = CGImageSourceCreateIncremental(NULL);
	_imageWidth = _imageHeight = -1;
	_expectedSize = [response expectedContentLength];
	_dataTemp = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
#pragma unused(connection)
	[_dataTemp appendData:data];

	const NSUInteger len = [_dataTemp length];
	CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef)_dataTemp, (len == _expectedSize) ? true : false);

	if (_imageHeight > 0 && _imageWidth > 0)
	{
		CGImageRef cgImage = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
		if (cgImage)
		{
			if (NYX_IOS_VERSION_LESS_THAN(@"5.0"))
			{
				/// iOS 4.x fix to correctly handle JPEG images ( http://www.cocoabyss.com/mac-os-x/progressive-image-download-imageio/ )
				CGImageRef imgTmp = [self createTransitoryImage:cgImage];
				if (imgTmp)
				{
					__block UIImage* img = [[UIImage alloc] initWithCGImage:imgTmp];
					CGImageRelease(imgTmp);
					
					dispatch_async(dispatch_get_main_queue(), ^{
						self.image = img;
					});
				}
			}
			else
			{
				__block UIImage* img = [[UIImage alloc] initWithCGImage:cgImage];
				dispatch_async(dispatch_get_main_queue(), ^{
					self.image = img;
				});
			}
			CGImageRelease(cgImage);
		}
	}
	else
	{
		CFDictionaryRef dic = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
		if (dic)
		{
			CFTypeRef val = CFDictionaryGetValue(dic, kCGImagePropertyPixelHeight);
			if (val)
				CFNumberGetValue(val, kCFNumberIntType, &_imageHeight);
			val = CFDictionaryGetValue(dic, kCGImagePropertyPixelWidth);
			if (val)
				CFNumberGetValue(val, kCFNumberIntType, &_imageWidth);
			CFRelease(dic);
		}
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
#pragma unused(connection)
	if (_dataTemp)
	{
		UIImage* img = [[UIImage alloc] initWithData:_dataTemp];
		dispatch_sync(dispatch_get_main_queue(), ^{
			self.image = img;
		});
		if ([_delegate respondsToSelector:@selector(imageDownloadCompletedWithImage:)])
			[_delegate imageDownloadCompletedWithImage:img];

		if (_caching)
		{
			// Create cache directory if it doesn't exist
			BOOL isDir = YES;
			
			NSFileManager* fileManager = [[NSFileManager alloc] init];

			NSString* cacheDir = [NYXProgressiveImageView cacheDirectoryAddress];
			if (![fileManager fileExistsAtPath:cacheDir isDirectory:&isDir])
				[fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:nil];

			NSString* path = [cacheDir stringByAppendingPathComponent:[self cachedImageSystemName]];
			[img saveToPath:path uti:CGImageSourceGetType(_imageSource) backgroundFillColor:nil];
		}
		
		_dataTemp = nil;
	}
    
	if (_imageSource)
		CFRelease(_imageSource);
	_connection = nil;
	_url = nil;
	dispatch_release(_queue);
	CFRunLoopStop(CFRunLoopGetCurrent());
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
#pragma unused(connection)
#pragma unused(error)
	if ([_delegate respondsToSelector:@selector(imageDownloadFailedWithData:)])
		[_delegate imageDownloadFailedWithData:_dataTemp];
    
	_dataTemp = nil;
	if (_imageSource)
		CFRelease(_imageSource);
	_connection = nil;
	_url = nil;
	dispatch_release(_queue);
	CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma mark - Private
-(void)initializeAttributes
{
	_cacheTime = kNyxDefaultCacheTime;
	_caching = NO;
}

-(CGImageRef)createTransitoryImage:(CGImageRef)partialImage
{
	const size_t partialHeight = CGImageGetHeight(partialImage);
	CGContextRef bmContext = NYXCreateARGBBitmapContext((size_t)_imageWidth, (size_t)_imageHeight, (size_t)_imageWidth * 4);
	if (!bmContext)
		return NULL;
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = _imageWidth, .size.height = partialHeight}, partialImage);
	CGImageRef goodImageRef = CGBitmapContextCreateImage(bmContext);
	CGContextRelease(bmContext);
	return goodImageRef;
}

+(NSString*)cacheDirectoryAddress
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectoryPath = [paths objectAtIndex:0];
	return [documentsDirectoryPath stringByAppendingPathComponent:@"NYXProgressiveImageViewCache"];
}

-(NSString*)cachedImageSystemName
{
	const char* concat_str = [[_url absoluteString] UTF8String];
	if (!concat_str)
		return @"";
	
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);

    NSMutableString* hash = [[NSMutableString alloc] init];
    for (unsigned int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];

    return [hash lowercaseString];
}

-(void)resetCache
{
    [[[NSFileManager alloc] init] removeItemAtPath:[[NYXProgressiveImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]] error:nil];
}

@end
