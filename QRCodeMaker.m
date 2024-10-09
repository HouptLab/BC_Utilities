//
//  QRCodeMaker.m
//  BarLabeler
//
//  Created by Tom Houpt on 10/27/19.
//  Copyright © 2019 Tom Houpt. All rights reserved.
//

#import "QRCodeMaker.h"
#import "CoreImage/CoreImage.h"

#import "CreateBitMap.h"

@implementation QRCodeMaker

-(id)initWithString:(NSString *)string andSideInPixels:(NSUInteger)side; {
    
    self = [super init];
    
    if (self) {
        qrString = [string copy];
        pixels_side = side;
        ciimage = nil;
        base64 = nil;
        nsimage = nil;
        cgimage = nil;
        
    }
    return self;
    
}

- (CIImage *)ciimage;
{
    
    if (nil != ciimage) { return ciimage; }
    // take string, convert to NSDAta, run through CIQRCodeGenerator CIFilter,
    // and return qr code in a CIImage
    
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // Send the image back
    ciimage = qrFilter.outputImage;
    return ciimage;
}

- (CGImageRef)cgimage;
{
    if (nil != cgimage) { return cgimage; }
    
    CIImage *theCIimage = [self ciimage];
    
    // Render the CIImage into a CGImage in a non-interpolated fashion so that pixels stay crisp
    // fist mage CIImage into a CGImage,  then re-render CGImage into scaled up version
    
    CGFloat scale = (CGFloat)pixels_side / theCIimage.extent.size.width;
    CGImageRef cgImage1 = [[CIContext contextWithOptions:nil] createCGImage:theCIimage fromRect:theCIimage.extent];
    
    // return cgImage;
    
    CGContextRef cgContext = MyCreateBitmapContext((NSUInteger)(theCIimage.extent.size.width * scale), (NSUInteger)(theCIimage.extent.size.width * scale));
    CGContextSetInterpolationQuality(cgContext, kCGInterpolationNone);
    CGContextDrawImage(cgContext, CGContextGetClipBoundingBox(cgContext), cgImage1);
    cgimage = CGBitmapContextCreateImage(cgContext);
    
    CGContextRelease(cgContext);
    CGImageRelease(cgImage1);
    
    
    return cgimage;
    
}

-(NSImage *)nsimage {
    if (nil != nsimage) { return nsimage; }
    CGImageRef theCGImage = [self cgimage];
    nsimage = [[NSImage alloc] initWithCGImage:theCGImage size:NSZeroSize];
    return nsimage;
}

-(NSString *)base64PNGString; {
    
    // plaec CGImage into a CFData imageDestination, then convert CFData into base64 encoded string
    
    if (nil != base64) { return base64; }
    
    CGImageRef theCGImage = [self cgimage];
    CFMutableDataRef pngData = CFDataCreateMutable(NULL,0);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(pngData, kUTTypePNG, 1, NULL);
    float compression = 1.0; // Lossless compression if available.
    int orientation = 4; // Origin is at bottom, left.
    CFStringRef myKeys[3];
    CFTypeRef   myValues[3];
    CFDictionaryRef myOptions = NULL;
    myKeys[0] = kCGImagePropertyOrientation;
    myValues[0] = CFNumberCreate(NULL, kCFNumberIntType, &orientation);
    myKeys[1] = kCGImagePropertyHasAlpha;
    myValues[1] = kCFBooleanTrue;
    myKeys[2] = kCGImageDestinationLossyCompressionQuality;
    myValues[2] = CFNumberCreate(NULL, kCFNumberFloatType, &compression);
    myOptions = CFDictionaryCreate( NULL, (const void **)myKeys, (const void **)myValues, 3,
                                   &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    
    CGImageDestinationAddImage(destination, theCGImage, myOptions);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    // Release the CFNumber and CFDictionary objects when you no longer need them.
    CFRelease(myValues[0]);
    CFRelease(myValues[2]);
    CFRelease(myOptions);
    
    NSString *pngBase64 = [(NSMutableData *)CFBridgingRelease(pngData) base64EncodedStringWithOptions: 0];
    return pngBase64;
}



@end
