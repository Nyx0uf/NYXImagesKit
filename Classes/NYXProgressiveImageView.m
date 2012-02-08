//
//  UIImageView+ProgressiveDisplay.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 13/01/12.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


#import "NYXProgressiveImageView.h"
#import "NYXImagesHelper.h"
#import <ImageIO/ImageIO.h>
#import <CommonCrypto/CommonDigest.h>

@interface NYXProgressiveImageView()
- (CGImageRef)createTransitoryImage:(CGImageRef)partialImage CF_RETURNS_RETAINED;
- (void) initializeAttributes;
+ (NSString*)cacheDirectoryAddress;
- (NSString*)cachedImageSystemName;
- (void)resetCache;

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
    // Url
    NSURL * _url;   
}

@synthesize delegate = _delegate;
@synthesize caching = _caching;
@synthesize cacheTime = _cacheTime;

#pragma mark - Init
-(id)init {
    self = [super init];
    if (self) {
        [self initializeAttributes];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeAttributes];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeAttributes];
    }
    return self;
}
-(id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self initializeAttributes];
    }
    return self;
}
-(id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self initializeAttributes];
    }
    return self;
}

#pragma mark - Public

-(void)loadImageAtURL:(NSURL*)url
{
    
    _url = url;
    
    if (_caching) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // check if file exists on cache
        if ([fileManager fileExistsAtPath:[[NYXProgressiveImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]]])
        {
            NSDate *mofificationDate = [[fileManager attributesOfItemAtPath:[[NYXProgressiveImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]] error:nil] objectForKey:NSFileModificationDate];
            
            // check modification date
            if (-[mofificationDate timeIntervalSinceNow] > self.cacheTime) {
                // Removes old cache file...
                [self resetCache];
            } else {
                
                // Loads image from cache without networking
                NSData *localImageData = [NSData dataWithContentsOfFile:[[NYXProgressiveImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]]];
				UIImage *localImage = [UIImage imageWithData:localImageData];
				
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

+ (void)resetImageCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[NYXProgressiveImageView cacheDirectoryAddress] error:nil];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	_imageSource = CGImageSourceCreateIncremental(NULL);
	_imageWidth = _imageHeight = -1;
	_expectedSize = [response expectedContentLength];
	_dataTemp = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
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
	if (_dataTemp)
	{
		UIImage* img = [[UIImage alloc] initWithData:_dataTemp];
		dispatch_sync(dispatch_get_main_queue(), ^{
			self.image = img;
		});
		if ([_delegate respondsToSelector:@selector(imageDownloadCompletedWithImage:)])
			[_delegate imageDownloadCompletedWithImage:img];
		_dataTemp = nil;
	}
    
    if (self.caching)
    {
        // Create cache directory if it doesn't exist
        BOOL isDir = YES;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:[NYXProgressiveImageView cacheDirectoryAddress] isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:[NYXProgressiveImageView cacheDirectoryAddress] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        // Write image cache file
        NSError *error;
        
        NSData *cachedImage;
        
        // Is it PNG or JPG/JPEG?
        if([[_url absoluteString] rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            cachedImage = UIImagePNGRepresentation(self.image);
        }
        else 
        {
            cachedImage = UIImageJPEGRepresentation(self.image, 1.0);
        }
        
		@try {
			[cachedImage writeToFile:[[NYXProgressiveImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]] options:NSDataWritingAtomic error:&error];
		}
		@catch (NSException * e) {
			// TODO: error handling
		}
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
	if ([_delegate respondsToSelector:@selector(imageDownloadFailedWithData:)])
		[_delegate imageDownloadFailedWithData:_dataTemp];
    
	_dataTemp = nil;
	if (_imageSource)
		CFRelease(_imageSource);
	_connection = nil;
	dispatch_release(_queue);
	CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma mark - Private
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

-(void) initializeAttributes {
    _cacheTime = (double)NYX_DEFAULT_CACHE_TIME;
    _caching = NO;
}

// caching methods

+ (NSString*)cacheDirectoryAddress
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return [documentsDirectoryPath stringByAppendingPathComponent:@"NYXProgressiveImageViewCache"];
}

- (void)resetCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[[NYXProgressiveImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]] error:nil];
}

- (NSString*)cachedImageSystemName
{
    const char *concat_str = [[_url absoluteString] UTF8String];
	if (concat_str == nil)
	{
		return @"";
	}
	
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
	
    return [hash lowercaseString];
}
@end
