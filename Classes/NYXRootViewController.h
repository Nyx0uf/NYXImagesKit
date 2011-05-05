//
//  NYXRootViewController.h
//  NYXImagesUtilities
//
//  Created by Nyx0uf on 5/2/11.
//  Copyright 2011 Benjamin Godard. All rights reserved.
//


@interface NYXRootViewController : UIViewController
{
@private
	/// Original image display
	UIImageView* _originalImageView;
	/// Modified image display
	UIImageView* _modifiedImageView;
	/// Bench result label
	UILabel* _resultLabel;
	/// Test image
	UIImage* _image;
}

@end
