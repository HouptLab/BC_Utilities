/*
 *  BCImageUtilities.c
 *  MindsEye
 *
 *  Created by Tom Houpt on 12/8/15.
 *  Copyright 2012 BehavioralCybernetics. All rights reserved.
 *
 */

#include "BCImageUtilities.h"

unsigned char *bitmapDataFromImage(CGImageRef sourceImage, unsigned long *bufferSize) {
	
	// 1. get the size info from the sourceImage
	// 2. set bytesPerPixel and bitmap buffer count based on 4-byte RGBA
	// 3. Create a buffer for the bitmap and an RGBA CGContext
	// 4. Draw the sourceImage into the context
	// 5. get a pointer to the bitmap data of the context
	
	CGSize size;
	size_t bytesPerPixel;
	size_t bytesPerRow; 
	size_t bitmapByteCount;
	size_t bitsPerComponent;

	// 1. get the size info from the sourceImage
	
	size.height = CGImageGetHeight(sourceImage);
	size.width = CGImageGetWidth(sourceImage);
	
	// 2. set bytesPerPixel and bitmap buffer count based on 4-byte RGBA
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
	
	bytesPerPixel = 4; // RGBA
	bytesPerRow = (size_t)size.width * bytesPerPixel;
	bitmapByteCount = (size_t)size.height * bytesPerRow;
	bitsPerComponent = 8;
	
	
	// see Technical Q&A QA1509: Getting the pixel data from a CGImage object
	
	// either use a data provider, or draw into a bitmap context
	
	// the data provider method leaves the image in the internal CGImage format, which may be weird, 
	// e.g, jpeg or kept as 1-byte grayscale....
	
	// the bitmap context will be in specified format, e.g. RGBA 8 bit, 
	// "with the caveat that alpha information from the image will be multiplied into the color components."
		
	// 3. Create a buffer for the bitmap and an RGBA CGContext
	
	// Create the bitmap context
	
	unsigned char *sourceBitmapData = malloc(bitmapByteCount);		
	
	CGContextRef cgctx = createRGBABitmapContextFromImage(sourceImage, sourceBitmapData);
	
	if (cgctx == NULL)  { 
		// error creating context
		return NO; 
	}
	
	// Get image width, height. We'll use the entire image.
	
	CGRect rect = {{0,0},{size.width,size.height}}; 
	
	// 4. Draw the sourceImage into the context
	
	// Draw the image to the bitmap context. Once we draw, the memory 
	// allocated for the context for rendering will then contain the 
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, sourceImage); 
	
	// 5. get a pointer to the bitmap data of the context
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	// this should be the same thing as sourceBitmapData allocated above....
	sourceBitmapData = CGBitmapContextGetData (cgctx);
	
	if (NULL != sourceBitmapData) {
		
		(*bufferSize) = bitmapByteCount;
		return sourceBitmapData;
		
	}
	
	return NULL;
	
	
}

CGContextRef createRGBABitmapContextFromImage(CGImageRef sourceImage, unsigned char *sourceBitmapData) {
	
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
	CGSize size;
	size_t bytesPerPixel;
	size_t bytesPerRow; 
	size_t bitmapByteCount;
	size_t bitsPerComponent;
	
	
	// 1. get the size info from the sourceImage
	
	size.height = CGImageGetHeight(sourceImage);
	size.width = CGImageGetWidth(sourceImage);
	
	// 2. set bytesPerPixel and bitmap buffer count based on 4-byte RGBA
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
	
	bytesPerPixel = 4; // RGBA
	bytesPerRow = (size_t)size.width * bytesPerPixel; 
	bitmapByteCount = (size_t)size.height * bytesPerRow;
	bitsPerComponent = 8;
	
 	
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); 
	
    if (colorSpace == NULL) {
        NSLog(@"CreateRGBABitmapContext: Error allocating color space\n");
        return NULL;
    }
	
	
    // Create the bitmap context. We want pre-multiplied RGBA, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (sourceBitmapData,
									 (size_t)size.width,
									 (size_t)size.height,
									 bitsPerComponent,
									 bytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	
    if (context == NULL)  {
        NSLog(@"Context not created!");
    }
	
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
	
    return context;
}


CGImageRef makeImageFromBitmap(CGContextRef cgctx) {
	
	// get a CGImage from the CGContext
	
	CGImageRef destinationImage = CGBitmapContextCreateImage(cgctx);
	
	return destinationImage;
	
}

NSImage *DragImageWithText(NSImage *theImage, NSString *theText) {
    
    NSSize size = [theText sizeWithAttributes:nil];
    size.width += [theImage size].width + 6;
    if (size.height < [theImage size].height) {
        size.height = [theImage size].height;
    }
    
    NSImage *theDragImage =  [[NSImage alloc] initWithSize:size];
    [theDragImage lockFocus];
    
    [theImage drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0,0,[theImage size].width,[theImage size].height)  operation:NSCompositeSourceOver fraction:1.0];
    [theText drawAtPoint:NSMakePoint([theImage size].width + 6,4) withAttributes:nil];
    [theDragImage unlockFocus];

    return theDragImage;
}

