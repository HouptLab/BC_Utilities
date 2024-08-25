//
//  QRCodeMaker.h
//  BarLabeler
//
//  Created by Tom Houpt on 10/27/19.
//  Copyright © 2019 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRCodeMaker : NSObject {
    NSString *qrString;
    NSUInteger pixels_side;
    NSString *base64;
    NSImage *nsimage;
    CGImageRef cgimage;
    CIImage *ciimage;
}

-(id)initWithString:(NSString *)string andSideInPixels:(NSUInteger)side;

-(NSString *)base64PNGString;
-(NSImage *)nsimage;
-(CGImageRef)cgimage;
-(CIImage *)ciimage;
@end
