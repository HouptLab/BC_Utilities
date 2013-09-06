/*
 *  BCImageUtilities.h
 *  MindsEye
 *
 *  Created by Tom Houpt on 12/8/15.
 *  Copyright 2012 BehavioralCybernetics. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

unsigned char *bitmapDataFromImage(CGImageRef sourceImage, unsigned long *bufferSize);
// given a CGImageRef, return the bitmap as RGBA in a newly allocated buffer of returned size
// you're responsible for freeing the buffer
// note that bitmap contains pixel data premultiplied by alpha values


CGContextRef createRGBABitmapContextFromImage(CGImageRef sourceImage, unsigned char *sourceBitmapData);

// return a CGContext 

CGImageRef makeImageFromBitmap(CGContextRef cgctx);

// return an image with the given text right next to it
// suitable for use as a drag image
NSImage *DragImageWithText(NSImage *theImage, NSString *theText);

