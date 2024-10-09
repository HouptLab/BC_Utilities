//
//  CreateBitMap.m
//  BarLabeler
//
//  Created by Tom Houpt on 10/28/19.
//  Copyright © 2019 Tom Houpt. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "CoreImage/CoreImage.h"
#import "CreateBitMap.h"

CGContextRef MyCreateBitmapContext (NSUInteger pixelsWide,
                                    NSUInteger pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    NSUInteger             bitmapByteCount;
    NSUInteger             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide * 4);// 1
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);// 2
    bitmapData = malloc( bitmapByteCount );// 3
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,// 4
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    // kCGImageAlphaPremultipliedLast?
    if (context== NULL)
    {
        free (bitmapData);// 5
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );// 6
    
    return context;// 7
}
