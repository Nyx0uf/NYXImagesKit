//
//  AppDelegate.m
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


#import "AppDelegate.h"
#import "NYXRootViewController.h"


@implementation AppDelegate

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	_rootVC = [[NYXRootViewController alloc] init];

	[_window addSubview:_rootVC.view];
	[_window makeKeyAndVisible];

	return YES;
}

-(void)dealloc
{
	SAFE_RELEASE(_rootVC);
	SAFE_RELEASE(_window);
	[super dealloc];
}

@end
