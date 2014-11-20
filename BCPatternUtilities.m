//
//  BCPatternUtilities.m
//  Xynk
//
//  Created by Tom Houpt on 14/11/19.
//
//

#import <Foundation/Foundation.h>
#import "BCPatternUtilities.h"


NSImage *HatchPatternImage(CGFloat lineSpacing, CGFloat strokeWidth, NSColor *strokeColor, NSColor *fillColor, NSInteger patternMask) {
    
    // tl2br top left to bottom right
    // tr2bl top right to bottom left
    // t2b top to bottom
    // l2r left to right
    
    NSImage *theImage =  [[NSImage alloc] initWithSize:NSMakeSize(lineSpacing,lineSpacing)];
    [theImage lockFocus];
    
    NSBezierPath *path;
    // NOTE: need to handle case of strokeColor == nil, fillColor != nil
    
    if (nil != fillColor) { [fillColor setFill]; }
    else { [[NSColor clearColor] setFill]; }
    NSRectFill(NSMakeRect(0,0,lineSpacing,lineSpacing));
    
    path = [NSBezierPath bezierPath];
    //   [path setLineCapStyle:NSSquareLineCapStyle];
    
    //    NSGraphicsContext *theContext = [NSGraphicsContext currentContext];
    //    [theContext setShouldAntialias:NO];
    
#define offset 2
    
    if (patternMask & kFillPatternLinesTopLeft2BottomRight) {
        
        
        //        [path moveToPoint:NSMakePoint(0,0)];
        //        [path lineToPoint:NSMakePoint(lineSpacing,lineSpacing)];
        //
        //        [path moveToPoint:NSMakePoint(-lineSpacing,0)];
        //        [path lineToPoint:NSMakePoint(0,lineSpacing)];
        //
        //
        //        [path moveToPoint:NSMakePoint(lineSpacing,0)];
        //        [path lineToPoint:NSMakePoint(2 * (lineSpacing),lineSpacing)];
        
        
        
        
        [path moveToPoint:NSMakePoint(lineSpacing/2-1,0-1)];
        [path lineToPoint:NSMakePoint(lineSpacing+1,lineSpacing/2+1)];
        
        [path moveToPoint:NSMakePoint(0-1,lineSpacing/2-1)];
        [path lineToPoint:NSMakePoint(lineSpacing/2+1,lineSpacing+1)];
        
        
        //        [path moveToPoint:NSMakePoint(lineSpacing,0)];
        //        [path lineToPoint:NSMakePoint(lineSpacing+lineSpacing,lineSpacing)];
        //
        
    }
    if (patternMask & kFillPatternLinesTopRight2BottomLeft) {
        
        
        [path moveToPoint:NSMakePoint(0-1,lineSpacing/2+1)];
        [path lineToPoint:NSMakePoint(lineSpacing/2+1,0-1)];
        
        [path moveToPoint:NSMakePoint(lineSpacing/2-1,lineSpacing+1)];
        [path lineToPoint:NSMakePoint(lineSpacing+1,lineSpacing/2-1)];
        
        
        
        //        CGFloat x = lineSpacing/2;
        //
        //        [path moveToPoint:NSMakePoint(x-lineSpacing,0)];
        //        [path lineToPoint:NSMakePoint(x-lineSpacing-lineSpacing,lineSpacing)];
        //
        //        [path moveToPoint:NSMakePoint(x,0)];
        //        [path lineToPoint:NSMakePoint(x-lineSpacing,lineSpacing)];
        //
        //        [path moveToPoint:NSMakePoint(x+lineSpacing,0)];
        //        [path lineToPoint:NSMakePoint(x,lineSpacing)];
        //
        
    }
    
    if (patternMask & kFillPatternLinesVertical) {
        [path moveToPoint:NSMakePoint(lineSpacing/2,-0)];
        [path lineToPoint:NSMakePoint(lineSpacing/2,lineSpacing)];
    }
    if (patternMask & kFillPatternLinesHorizontal) {
        [path moveToPoint:NSMakePoint(0,lineSpacing/2)];
        [path lineToPoint:NSMakePoint(lineSpacing,lineSpacing/2)];
    }
    
    [strokeColor setStroke];
    [path setLineWidth:strokeWidth];
    [path stroke];
    
    
    //    // grab the subimage from the center of the superimage
    //    NSBitmapImageRep *subImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:
    //                             NSMakeRect(lineSpacing/2,lineSpacing/2,lineSpacing,lineSpacing)];
    //
    //    [theSuperImage unlockFocus];
    //
    //   NSImage *theImage =  [[NSImage alloc] initWithCGImage:[subImageRep CGImage] size:NSMakeSize(lineSpacing,lineSpacing)];
    
    [theImage unlockFocus];
    
    return theImage;
}

NSImage *DotPatternImage(CGFloat dotSpacing, CGFloat dotDiameter, NSColor *dotColor, NSColor *fillColor, BOOL staggered) {
    
    NSBezierPath *path;
    NSRect dot;
    NSImage *theImage;
    
    // NOTE: need to handle case of strokeColor == nil, fillColor != nil

    
    if (staggered == REGULAR_DOTS) {
        
        theImage =  [[NSImage alloc] initWithSize:NSMakeSize(dotSpacing,dotSpacing)];
        [theImage lockFocus];
        
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(0,0,dotSpacing,dotSpacing)];
        if (nil != fillColor) { [fillColor setFill]; }
        else { [[NSColor clearColor] setFill]; }
        [path fill];
        
        dot = NSMakeRect((dotSpacing - dotDiameter)/2,(dotSpacing - dotDiameter)/2,dotDiameter,dotDiameter);
        [dotColor setFill];
        path = [NSBezierPath bezierPathWithOvalInRect:dot];
        [path fill];
        
        
    }
    else { // staggered
        
        CGFloat imageWidth = dotSpacing * 2.0;
        
        theImage =  [[NSImage alloc] initWithSize:NSMakeSize(imageWidth,imageWidth)];
        [theImage lockFocus];
        
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(0,0,imageWidth,imageWidth)];
        if (nil != fillColor) { [fillColor setFill]; }
        else { [[NSColor clearColor] setFill]; }
        [path fill];
        
        dot = NSMakeRect(0,0,dotDiameter,dotDiameter);
        path = [NSBezierPath bezierPathWithOvalInRect:dot];
        
        dot = NSMakeRect(dotSpacing,dotSpacing,dotDiameter,dotDiameter);
        [path appendBezierPathWithOvalInRect:dot];
        
        [dotColor setFill];
        [path fill];
        
        
    }
    
    [theImage unlockFocus];
    return theImage;
    
}

#define LINE_THIN_WIDTH 1.0
#define LINE_REGULAR_WIDTH 2.0
#define LINE_THICK_WIDTH 4.0

#define LINE_SPARSE_SPACING 20.0
#define LINE_REGULAR_SPACING 10.0
#define LINE_DENSE_SPACING 8.0

#define DOT_SMALL_WIDTH 2.0
#define DOT_REGULAR_WIDTH 4.0
#define DOT_LARGE_WIDTH 6.0

#define DOT_SPARSE_SPACING 10.0
#define DOT_REGULAR_SPACING 8.0
#define DOT_DENSE_SPACING 4.0


NSImage *FillPatternImage(BCFillPatternFlags patternMask, NSColor *patternColor, NSColor *backgroundColor) {
    
    CGFloat lineWidth = LINE_REGULAR_WIDTH;
    CGFloat lineSpacing = LINE_REGULAR_SPACING;
    CGFloat dotDiameter = DOT_REGULAR_WIDTH;
    CGFloat dotSpacing = DOT_REGULAR_SPACING;
    
    NSColor *strokeColor, *fillColor;
    NSImage *patternImage;
    
    if (kFillPatternSolid == patternMask) { return nil; }
    
    if (kFillPatternInvert & patternMask) {
        // invert the image colors
       fillColor = patternColor;
       strokeColor = backgroundColor;
    }
    else {
        strokeColor = patternColor;
        fillColor = backgroundColor;
    }


    if (kFillPatternLineHatch & patternMask) {
        // hatched...
        
        if ( kFillPatternThinElements & patternMask) {
            lineWidth = LINE_THIN_WIDTH;
        }
        if ( kFillPatternThickElements & patternMask) {
            lineWidth = LINE_THICK_WIDTH;
        }
        if ( kFillPatternSparse & patternMask) {
            lineSpacing = LINE_SPARSE_SPACING;
        }
        if ( kFillPatternDense & patternMask) {
            lineSpacing = LINE_DENSE_SPACING;
        }
    
    
        patternImage =  HatchPatternImage(lineSpacing, lineWidth, strokeColor, fillColor, patternMask);
    
    }
    else {
        // stippled...
        if ( kFillPatternThinElements & patternMask) {
            dotDiameter = DOT_SMALL_WIDTH;
        }
        if ( kFillPatternThickElements & patternMask) {
            dotDiameter = DOT_LARGE_WIDTH;
        }
        if ( kFillPatternSparse & patternMask) {
            dotSpacing = DOT_SPARSE_SPACING;
        }
        if ( kFillPatternDense & patternMask) {
            dotSpacing = DOT_DENSE_SPACING;
        }

        
        patternImage = DotPatternImage(dotSpacing,dotDiameter, strokeColor, fillColor, (1 == (kFillPatternStaggeredDots & patternMask)) );

    }
    
    return patternImage;
    
}



NSColor *FillColorWithPattern(BCFillPatternFlags patternMask, NSColor *patternColor, NSColor *backgroundColor) {
    

    if (patternMask != kFillPatternSolid) {
        NSImage *patternImage = FillPatternImage(patternMask, patternColor, backgroundColor);
        
        return [NSColor colorWithPatternImage:patternImage];
    }
    
    return patternColor;

}



// --------------------------------------------------------------------------------
// STROKE DASH OR DOT PATTERNS


#define kDotLength 1
#define kDotSpace 2
#define kDashShortLength 5
#define kDashShortSpace 2
#define kDashLongLength 10
#define kDashLongSpace 3
#define kMaxDashElements 6

void SetPathStrokePattern(NSBezierPath *thePath, BCStrokePatternType dashPattern, CGFloat strokeWidth) {
    
    CGFloat pattern[kMaxDashElements];
    
    switch (dashPattern) {
            
        case kSolidStroke:
            // clear the line dash
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            [thePath setLineDash:nil count:0 phase:0.0];
            break;
            
        case kDotted:
            // ••••••
            [thePath setLineCapStyle:NSRoundLineCapStyle];
            pattern[0] = kDotLength;
            pattern[1] = kDotSpace*strokeWidth;
            [thePath setLineDash:pattern count:2 phase:0.0];
            break;
            
        case kDottedSpaced:
            // • • • •
            [thePath setLineCapStyle:NSRoundLineCapStyle];
            pattern[0] = kDotLength;
            pattern[1] = kDotSpace * 2*strokeWidth;
            [thePath setLineDash:pattern count:2 phase:0.0];
            break;
            
        case kDottedTriple:
            // ••• ••• •••
            [thePath setLineCapStyle:NSRoundLineCapStyle];
            pattern[0] = kDotLength;
            pattern[1] = kDotSpace*strokeWidth;
            pattern[2] = kDotLength;
            pattern[3] = kDotSpace*strokeWidth;
            pattern[4] = kDotLength;
            pattern[5] = kDotSpace * 2*strokeWidth;
            [thePath setLineDash:pattern count:6 phase:0.0];
            break;
            
            
        case kDashedShort:
            // -----
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            pattern[0] = kDashShortLength;
            pattern[1] = kDashShortSpace*strokeWidth;
            [thePath setLineDash:pattern count:2 phase:0.0];
            break;
            
        case kDashedLong:
            // — — — —
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            pattern[0] = kDashLongLength;
            pattern[1] = kDashLongSpace*strokeWidth;
            [thePath setLineDash:pattern count:2 phase:0.0];
            break;
            
        case kDashedShortSpaced:
            // - - - - -
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            pattern[0] = kDashShortLength;
            pattern[1] = kDashShortSpace * 2*strokeWidth;
            [thePath setLineDash:pattern count:2 phase:0.0];
            break;
            
        case kDashedLongSpaced:
            // —  —  —  —
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            pattern[0] = kDashLongLength;
            pattern[1] = kDashLongSpace * 2 *strokeWidth;
            [thePath setLineDash:pattern count:2 phase:0.0];
            break;
            
        case kDashedShortLong:
            // -—-—-—-—
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            pattern[0] = kDashShortLength;
            pattern[1] = kDashShortSpace*strokeWidth;
            pattern[2] = kDashLongLength;
            pattern[3] = kDashShortSpace*strokeWidth;
            [thePath setLineDash:pattern count:4 phase:0.0];
            break;
            
            
        case kDotDashShort:
            // •-•-•-•-
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            pattern[0] = kDotLength;
            pattern[1] = kDashShortSpace*strokeWidth;
            pattern[2] = kDashShortLength;
            pattern[3] = kDashShortSpace*strokeWidth;
            [thePath setLineDash:pattern count:4 phase:0.0];
            break;
            
        case kDotDashLong:
            // •—•—•—•—
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            pattern[0] = kDotLength;
            pattern[1] = kDotSpace*strokeWidth;
            pattern[2] = kDashLongLength;
            pattern[3] = kDotSpace*strokeWidth;
            [thePath setLineDash:pattern count:4 phase:0.0];
            break;
            
        case kDotDotDashDashLong:
            // ••——••——••——
            [thePath setLineCapStyle:NSSquareLineCapStyle];
            pattern[0] = kDotLength;
            pattern[1] = kDotSpace*strokeWidth;
            pattern[2] = kDotLength;
            pattern[3] = kDotSpace*strokeWidth;
            pattern[4] = kDashLongLength;
            pattern[5] = kDotSpace*strokeWidth;
            [thePath setLineDash:pattern count:6 phase:0.0];
            break;
            
    };
    
    
}

#define DASH_BOX_WIDTH 72
#define DASH_BOX_HEIGHT 16
#define DASH_SAMPLE_STROKE_WIDTH 3

NSMenu *SetUpDashPickerMenu(CGFloat strokeWidth, NSColor *strokeColor, NSColor *backgroundColor) {
    
    // make a pop-up menu of the dash lines
    
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"dashes"];
    
    NSMenuItem *item;
    NSRect dashBox = NSMakeRect(0.5,0.5,DASH_BOX_WIDTH,DASH_BOX_HEIGHT);
    
    for (NSUInteger i= 0; i < kNumDashPatterns; i++) {
        
        // [theMenu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
        
        item=  [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" action:NULL keyEquivalent:@""];
        
        //  item = [theMenu itemAtIndex:i];
        
        // draw the pallete color  onto theme background, attach image to menu item
        
        NSImage* menuImage = [[NSImage alloc] initWithSize:dashBox.size] ;
        [menuImage lockFocus];
        
        [backgroundColor setFill];
        NSRectFill(dashBox);
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [strokeColor setStroke];
        [path setLineWidth:strokeWidth]; // or use DASH_SAMPLE_STROKE_WIDTH?
        SetPathStrokePattern(path, i, strokeWidth);
        
        [path moveToPoint:NSMakePoint(0,DASH_BOX_HEIGHT/2)];
        [path lineToPoint:NSMakePoint(DASH_BOX_WIDTH,DASH_BOX_HEIGHT/2)];
        [path stroke];
        
        
        
        [menuImage unlockFocus];
        [item setImage:menuImage];
        [item setOnStateImage:nil];
        [item setMixedStateImage:nil];
        [theMenu addItem:item];
        
    }
    return theMenu;
}


