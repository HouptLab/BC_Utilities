/*
 *  BCImageUtilities.c
 *  MindsEye
 *
 *  Created by Tom Houpt on 12/8/15.
 *  Copyright 2012 BehavioralCybernetics LLC. All rights reserved.
 *
 */

#include "BCImageUtilities.h"

/** create an RGBA bitmap context of the given dimensions
 with kCGColorSpaceGenericRGB and 8 bits per component
*/
CGContextRef CreateBitmapContext (NSInteger pixelsWide,
									NSInteger pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    size_t             bitmapByteCount;
    size_t             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = (pixelsWide * 4);// 1
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);// 2

    bitmapData = malloc( bitmapByteCount );// 3
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
    }
    else {
        context = CGBitmapContextCreate (bitmapData,// 4
                                         pixelsWide,
                                         pixelsHigh,
                                         8,      // bits per component
                                         bitmapBytesPerRow,
                                         colorSpace,
                                         (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
       // from apple docs:
       // The constants for specifying the alpha channel information are declared with the CGImageAlphaInfo type but can be passed to this parameter [as CGBitmapInfo] safely
        
    }
        CGColorSpaceRelease( colorSpace );// 6

        if (context== NULL)
        {
            free (bitmapData);// 5
            fprintf (stderr, "Context not created!");
        }
        
	
    return context;// 7
}



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
//	size_t bitsPerComponent;

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
//	bitsPerComponent = 8;
	
	
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
        free(sourceBitmapData);
		return NULL;
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
		
	}
	
	return sourceBitmapData;
	
	
}

CGContextRef createRGBABitmapContextFromImage(CGImageRef sourceImage, unsigned char *sourceBitmapData) {
	
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
	CGSize size;
	size_t bytesPerPixel;
	size_t bytesPerRow; 
//	size_t bitmapByteCount;
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
//	bitmapByteCount = (size_t)size.height * bytesPerRow;
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
									 (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    // from apple docs:
    // The constants for specifying the alpha channel information are declared with the CGImageAlphaInfo type but can be passed to this parameter [as CGBitmapInfo] safely

	
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

BOOL IsImageFile(NSString*filePath) {
	
	BOOL				isImageFile = NO;
	LSItemInfoRecord	info;
	CFStringRef			uti = NULL;
	CFArrayRef  supportedTypes = NULL;
	
	BOOL itsAFile = NO;
	
	NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
	if (fileAttribs)
	{
		// Check for packages.
		if ([NSFileTypeDirectory isEqualTo:[fileAttribs objectForKey:NSFileType]])
		{
			if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:filePath] == NO)
				itsAFile = YES;	// If it is a file, it's OK to add.
		}
		else
		{
			itsAFile = YES;	// It is a file, so it's OK to add.
		}
	}
	
	if (!itsAFile) return NO;
	
	CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (__bridge CFStringRef)filePath, kCFURLPOSIXPathStyle, FALSE);
	
	if (LSCopyItemInfoForURL(url, kLSRequestExtension | kLSRequestTypeCreator, &info) == noErr)
	{
		// Obtain the UTI using the file information.
		
		// If there is a file extension, get the UTI.
		if (info.extension != NULL)
		{
			uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, info.extension, kUTTypeData);
			CFRelease(info.extension);
		}
		
		// No UTI yet
		if (uti == NULL)
		{
			// If there is an OSType, get the UTI.
			CFStringRef typeString = UTCreateStringForOSType(info.filetype);
			if ( typeString != NULL)
			{
				uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassOSType, typeString, kUTTypeData);
				CFRelease(typeString);
			}
		}
		
		// Verify that this is a file that the ImageIO framework supports.
		if (uti != NULL)
		{
			supportedTypes = CGImageSourceCopyTypeIdentifiers();
			CFIndex		i, typeCount = CFArrayGetCount(supportedTypes);
			
			for (i = 0; i < typeCount; i++)
			{
				if (UTTypeConformsTo(uti, (CFStringRef)CFArrayGetValueAtIndex(supportedTypes, i)))
				{
					isImageFile = YES;
					break;
				}
			}
		}
	}
	
	if (uti != NULL) CFRelease(uti);
        if (url != NULL) CFRelease(url);
            if (supportedTypes != NULL) CFRelease(supportedTypes);
                
                
                return isImageFile;
}

/** save the given CGImage to a TIFF file with filename at path
 
*/

void SaveImageToTIFF(CGImageRef imageRef, NSString *path,CFMutableDictionaryRef tiffProperties) {
    
    BOOL make_default_properties_dictionary = NO;
// moved TIFF properties up to controller...
    if (nil == tiffProperties) {
        
        make_default_properties_dictionary = YES;
        
    NSInteger compression = NSTIFFCompressionLZW;  // non-lossy LZW compression
    tiffProperties = CFDictionaryCreateMutable(nil,
                                                                    0,
                                                                    &kCFTypeDictionaryKeyCallBacks,
                                                                    &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(tiffProperties,
                         kCGImagePropertyTIFFCompression,
                         CFNumberCreate(NULL, kCFNumberIntType, &compression));

}
    
    CFMutableDictionaryRef mSaveMetaAndOpts = CFDictionaryCreateMutable(nil,
                                                                        0,
                                                                        &kCFTypeDictionaryKeyCallBacks,
                                                                        &kCFTypeDictionaryValueCallBacks);
    

    
    CFDictionarySetValue(mSaveMetaAndOpts,
                         kCGImagePropertyTIFFDictionary,
                         tiffProperties);
    

    NSURL *outURL = [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL (CFBridgingRetain(outURL),
                                                                         kUTTypeTIFF,
                                                                         1,
                                                                         NULL);
    CGImageDestinationAddImage(destination,
                               imageRef,
                               mSaveMetaAndOpts);
    
    CGImageDestinationSetProperties(destination, mSaveMetaAndOpts);
    
    CGImageDestinationFinalize(destination);
    
    
    CFRelease(destination);

    if (make_default_properties_dictionary) { CFRelease(tiffProperties); }
    CFRelease(mSaveMetaAndOpts);
// NOTE: do we need to release outURL because it was cast to CFBridgingRetain
}

CGImageRef CreatePNGImageRefFromBundle (const char *imageName)
{
    CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef name;
    CFURLRef url;
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    
    // Get the URL to the bundle resource.
    name = CFStringCreateWithCString (NULL, imageName, kCFStringEncodingUTF8);
    url = CFBundleCopyResourceURL(mainBundle, name, CFSTR("png"), NULL);
    CFRelease(name);
    
    // Create the data provider object
    provider = CGDataProviderCreateWithURL (url);
    CFRelease (url);
    
    // Create the image object from that provider.
    image = CGImageCreateWithPNGDataProvider (provider, NULL, true,
                                              kCGRenderingIntentDefault);
    CGDataProviderRelease (provider);
    
    return (image);
}

