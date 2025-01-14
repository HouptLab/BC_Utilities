/*
 *  BCImageUtilities.h
 *  MindsEye
 *
 *  Created by Tom Houpt on 12/8/15.
 *  Copyright 2012 BehavioralCybernetics LLC. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

CGContextRef CreateBitmapContext (NSInteger pixelsWide,
                                  NSInteger pixelsHigh);

unsigned char *bitmapDataFromImage(CGImageRef sourceImage, unsigned long *bufferSize);
// given a CGImageRef, return the bitmap as RGBA in a newly allocated buffer of returned size
// you're responsible for freeing the buffer
// note that bitmap contains pixel data premultiplied by alpha values


CGContextRef createRGBABitmapContextFromImage(CGImageRef sourceImage, unsigned char *sourceBitmapData);

// return a CGContext 

CGImageRef makeImageFromBitmap(CGContextRef cgctx);

/** save the given CGImage to a TIFF file at the given path
    can pass in a mutable dictionary of TIFF properties; if tiffProperties == nil, then a default set of properties is generated and used to save the file.
 
 */

void SaveImageToTIFF(CGImageRef imageRef, NSString *path,CFMutableDictionaryRef tiffProperties);


/** return an image with the given text right next to it
 suitable for use as a drag image
*/
NSImage *DragImageWithText(NSImage *theImage, NSString *theText);


/** determine if the file at the given path is an image file
    This utility method indicates if the file located at 'filePath'
    is an image file based on the UTI. It relies on the ImageIO framework
    for the supported type identifiers.

    Taken from image-browser-appearance sample code

*/
BOOL IsImageFile(NSString*filePath);

CGImageRef CreatePNGImageRefFromBundle (const char *imageName);

/* return a number which is maximal when image is in focus 
 currently uses size of JPEG at 25% compressionquality

*/
double calcFocusMetric(CGImageRef theCGImage);

NSData *JPEGDataFromCGImage(CGImageRef image, CGFloat compressionQuality);
