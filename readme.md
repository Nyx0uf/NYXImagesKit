# NYXImagesKit #

This is a project for iOS which regroups a collection of useful *UIImage* categories to handle operations such as filtering, blurring, enhancing, masking, reflecting, resizing, rotating, saving. There is also a subclass of *UIImageView* to load an image asynchronously from a URL and display it as it is downloaded.

It requires at least *iOS 5.1*.

***NYXImagesKit*** is designed to be very efficient, **vDSP** is used when possible, some filters use **Core Image** or **vImage** to be as fast as possible.

The project is a static library so that you don't have to import the sources in your own project and build them each time.


### ARC Support ###

***NYXImagesKit*** fully supports **ARC** out of the box, there is no configuration necessary. Also, as it is a library you can use it without problems in a **non-ARC** project.


### Installation ###

First open the **NYXImagesKit.xcodeproj** and build the library, then import the library and the headers in your project, and finally link with these frameworks :

- **Accelerate**
- **AssetsLibrary**
- **ImageIO**
- **MobileCoreServices**
- **QuartzCore**
- **CoreImage**

Or if you want, you can add the sources to your project and build them along.

### UIImage+Filtering ###

This category allows you to apply filters on a *UIImage* object, currently there are 11 filters :

1. Brighten
2. Contrast adjustment
3. Edge detection
4. Emboss
5. Gamma correction
6. Grayscale
7. Invert
8. Opacity
9. Sepia
10. Sharpen
11. Unsharpen


### UIImage+Blurring ###

This category is composed of a single method to blur an *UIImage*. Blurring is done using is done using **vImage**.

	[myImage gaussianBlurWithBias:0];


### UIImage+Masking ###

This category is composed of a single method which allow to mask an image with another image, you just have to create the mask image you desire.

	UIImage* masked = [myImage maskWithImage:[UIImage imageNamed:@"mask.png"]];


### UIImage+Resizing ###

This category can be used to crop or to scale images.


#### Cropping ####

You can crop your image by 9 different ways :

1. Top left
2. Top center
3. Top right
4. Bottom left
5. Bottom center
6. Bottom right
7. Left center
8. Right center
9. Center


	UIImage* cropped = [myImage cropToSize:(CGSize){width, height} usingMode:NYXCropModeCenter];

<code>NYXCropMode</code> is an enum type which can be found in the header file, it is used to represent the 9 modes above.


#### Scaling ####

You have the choice between two methods to scale images, the two methods will keep the aspect ratio of the original image.

	UIImage* scaled1 = [myImage scaleByFactor:0.5f];
	UIImage* scaled2 = [myImage scaleToFitSize:(CGSize){width, height}];


### UIImage+Rotating ###

With this category you can rotate or flip an *UIImage*, flipping is useful if you want to create a reflect effect.

	UIImage* rotated1 = [myImage rotateInDegrees:217.0f];
	UIImage* rotated2 = [myImage rotateInRadians:M_PI_2];
	UIImage* flipped1 = [myImage verticalFlip];
	UIImage* flipped2 = [myImage horizontalFlip];


### UIImage+Reflection ###

This category was written by Matthias Tretter (@myell0w) and is composed of a single method to create a reflected image.

	UIImage* reflected = [myImage reflectedImageWithHeight:myImage.size.height fromAlpha:0.0f toAlpha:0.5f];


### UIImage+Enhancing ###

This category works only on *iOS 5* because it uses **Core Image**, it allows to enhance an image or to perform red eye correction.

	[myImage autoEnhance];
	[myImage redEyeCorrection];


### UIImage+Saving ###

This category allows you to save an *UIImage* at a specified path or file URL or to your Photos album, there are five types supported :

1. BMP
2. GIF
3. JPG
4. PNG
5. TIFF

To use it, you must link with **ImageIO.framework**, **MobileCoreServices.framework** and **AssetsLibrary.framework**.

	[myImage saveToURL:url type:NYXImageTypeJPEG backgroundFillColor:nil];
	[myImage saveToPath:path type:NYXImageTypeTIFF backgroundFillColor:[UIColor yellowColor]];
	[myImage saveToPhotosAlbum];

There is also two other methods which take only the path or URL as parameter and save the image in PNG, because it's the preferred format for iOS.

If your image contains transparent zone and you save it in a format that doesn't support alpha, a fill color will be used, if you don't specify one, the default color will be white.


### NYXProgressiveImageView ###

This is a subclass of *UIImageView* to load asynchronously an image from an URL and display it as it is being downloaded. Image caching is supported.
For more informations see <http://www.cocoaintheshell.com/2012/01/nyximageskit-class-nyxprogressiveimageview/> and <http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/>.


### License ###

***NYXImagesKit*** is released under the *Simplified BSD license*, see **LICENSE.txt**.

I hope you will find this useful, and, feel free to contribute !

Blog : <http://www.cocoaintheshell.com/>

Twitter : @Nyx0uf
