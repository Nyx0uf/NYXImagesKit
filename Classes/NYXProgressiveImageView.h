//
//  UIImageView+ProgressiveDisplay.h
//  NYXImagesKit
//
//  Created by @Nyx0uf on 13/01/12.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


@protocol NYXProgressiveImageViewDelegate <NSObject>
@optional
-(void)imageDownloadCompletedWithImage:(UIImage*)img;
-(void)imageDownloadFailedWithData:(NSData*)data;
@end


@interface NYXProgressiveImageView : UIImageView

#pragma mark - Public messages
/// Launch the image download
-(void)loadImageAtURL:(NSURL*)url;

#pragma mark - Public properties
/// Delegate (use weak if you target only iOS 5)
@property (nonatomic, assign) id <NYXProgressiveImageViewDelegate> delegate;

@end
