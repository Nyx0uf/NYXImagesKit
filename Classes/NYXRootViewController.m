//
//  NYXRootViewController.m
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "NYXRootViewController.h"
#import "UIImage+Filtering.h"
#import "UIImage+Resizing.h"
#import "UIImage+Rotating.h"
#import "UIImage+Masking.h"


@interface NYXRootViewController()
-(void)bench:(id)sender;
@end


@implementation NYXRootViewController

#pragma mark - Allocations / Deallocations / Memory
-(id)init
{
	if ((self = [super init]))
	{
		_originalImageView = nil;
		_modifiedImageView = nil;
		_resultLabel = nil;
		_image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"jpg"]];
	}
	return self;
}

-(void)dealloc
{
	SAFE_RELEASE(_image);
	SAFE_RELEASE(_originalImageView);
	SAFE_RELEASE(_modifiedImageView);
	SAFE_RELEASE(_resultLabel);
	[super dealloc];
}

#pragma mark - UIViewController events
-(void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor lightGrayColor];

	_originalImageView = [[UIImageView alloc] initWithFrame:(CGRect){.origin.x = 0.0f, .origin.y = 30.0f, .size.width = 320.0f, .size.height = 200.0f}];
	_originalImageView.backgroundColor = [UIColor grayColor];
	_originalImageView.contentMode = UIViewContentModeScaleAspectFit;
	_originalImageView.image = _image;
	[self.view addSubview:_originalImageView];
	
	_modifiedImageView = [[UIImageView alloc] initWithFrame:(CGRect){.origin.x = 0.0f, .origin.y = 230.0f, .size.width = 320.0f, .size.height = 200.0f}];
	_modifiedImageView.backgroundColor = [UIColor grayColor];
	[self.view addSubview:_modifiedImageView];

	UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = (CGRect){.origin.x = 110.0f, .origin.y = 2.0f, .size.width = 100.0f, .size.height = 18.0f};
	[btn addTarget:self action:@selector(bench:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"Transform" forState:UIControlStateNormal];
	[self.view addSubview:btn];

	_resultLabel = [[UILabel alloc] initWithFrame:(CGRect){.origin.x = 110.0f, .origin.y = 462.0f, .size.width = 100.0f, .size.height = 18.0f}];
	_resultLabel.backgroundColor = [UIColor clearColor];
	_resultLabel.textColor = [UIColor redColor];
	_resultLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:_resultLabel];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private
-(void)bench:(id)sender
{
	UIImage* final = nil;
	const NSTimeInterval t1 = [[NSDate date] timeIntervalSince1970];
	final = [[_image sepia] maskWithImage:[UIImage imageNamed:@"mask.png"]];
	const NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970];

	_resultLabel.text = [NSString stringWithFormat:@"%fs", t2 - t1];
	_modifiedImageView.contentMode = (final.size.width < _modifiedImageView.frame.size.width && final.size.height < _modifiedImageView.frame.size.height) ? UIViewContentModeCenter : UIViewContentModeScaleAspectFit;
	_modifiedImageView.image = final;

	/*CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:@"path"], CFSTR("public.png"), 1, NULL);
	 CGImageDestinationAddImage(dest, maskedImageRef, (CFDictionaryRef)[NSDictionary dictionaryWithObject:(id)[NSNumber numberWithFloat:1.0f] forKey:(id)kCGImageDestinationLossyCompressionQuality]);
	 CGImageDestinationFinalize(dest);
	 CFRelease(dest);*/
}

@end
