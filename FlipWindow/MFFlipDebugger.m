//
//  MFFlipDebugger.m
//  Lemur Flip
//
//  Created by Mike Lee on 1/4/08.
//  Released in the public domain.
//

#import <QuartzCore/QuartzCore.h>
#import "MFFlipDebugger.h"

#define MFCFAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]

@interface MFFlipDebugger ()
- (NSPoint)_lowerLeftCornerOfBitmap:(NSBitmapImageRep *)bitmap;
@end

@implementation MFFlipDebugger

#pragma mark NSObject

- (id)initWithWindowNumber:(NSInteger)theNumber;
{
    if (![super initWithWindowNibName:NSStringFromClass([self class])])
        return nil;

    windowNumber = theNumber;
    cornerPoints = [[NSMutableArray alloc] init];

    self.window; // Force XIB loading
    
    view.wantsLayer = YES;
    view.layer.needsDisplayOnBoundsChange = YES;
    view.layer.autoresizingMask = kCALayerWidthSizable|kCALayerHeightSizable;
    pathLayer = [CALayer layer];
    pathLayer.autoresizingMask = kCALayerMinXMargin|kCALayerMaxXMargin|kCALayerMinYMargin|kCALayerMaxYMargin;
    pathLayer.frame = CGRectMake(0.0, 0.0, NSWidth(view.frame), NSHeight(view.frame));
    pathLayer.delegate = self;    
    
    [self reset]; // This will finish member initialization
    
    return self;
}

- (void)dealloc;
{
    [cornerPoints release];
    cornerPoints = nil;
    pathLayer = nil;
    [super dealloc];
}


#pragma mark NSObject (CALayerDelegate)

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
{
    if (layer != pathLayer)
         { return; }
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO]];
    [[NSColor greenColor] setFill];
    
    NSBezierPath *bezierPath = nil;
    NSArray *pointValues = [cornerPoints subarrayWithRange:NSMakeRange(0, currentFrame + 1)];
    for (NSValue *pointValue in pointValues) {
        NSPoint point = [pointValue pointValue];
        if (NSEqualPoints(point, NSZeroPoint))
            continue;
        
        // Bring point inline with actual bitmap content
        point.x += (layer.frame.size.width - layerContentSize.width) / 2.0;
        point.y += (layer.frame.size.height - layerContentSize.height) / 2.0;

        // Draw the point
        NSRectFill(NSMakeRect(point.x - 1, point.y - 1, 3, 3));
        
        // Build the trend line
        if (!bezierPath) {
            bezierPath = [NSBezierPath bezierPath];
            [bezierPath moveToPoint:point];
        } else
            [bezierPath lineToPoint:point];
    }

    [positiveY setFloatValue:NSMaxY(bezierPath.bounds) - bottomEdge];
    [negativeY setFloatValue:bottomEdge - NSMinY(bezierPath.bounds)];
    
    // Draw the trend line
    [[NSColor blueColor] setStroke];
    [bezierPath stroke];
    [NSGraphicsContext restoreGraphicsState];
}


#pragma mark API

@synthesize currentFrame;

- (void)setCurrentFrame:(NSUInteger)frameNumber;
{
    [CATransaction begin]; {
        [[view.layer.sublayers subarrayWithRange:NSMakeRange(0, frameNumber + 1)] makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
        [[view.layer.sublayers subarrayWithRange:NSMakeRange(frameNumber + 1, view.layer.sublayers.count - frameNumber - 2)] makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:NO]];
     } [CATransaction commit];

    [self willChangeValueForKey:@"currentFrame"];
    currentFrame = frameNumber;
    [self didChangeValueForKey:@"currentFrame"];

    // Refresh Bezier path overlay
    [pathLayer setNeedsDisplay];
}

- (void)reset;
{
    [cornerPoints removeAllObjects];
    layerContentSize = NSZeroSize;
    bottomEdge = 0;
    currentFrame = 0;
    
    // Reset UI
    view.layer.sublayers = [NSArray arrayWithObject:pathLayer];
    frameSlider.maxValue = 0;
    frameSlider.numberOfTickMarks = 0;
    [positiveY setStringValue:@""];
    [negativeY setStringValue:@""];
}

- (void)sample;
{   
    if (!(windowNumber > 0))
         { return; }
    
        CGImageRef windowSample = MFCFAutorelease(CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, windowNumber, kCGWindowImageBoundsIgnoreFraming));

         // Create new layer with image and add to rendering tree
         CALayer *newLayer = [CALayer layer];
         newLayer.autoresizingMask = kCALayerMinXMargin|kCALayerMaxXMargin|kCALayerMinYMargin|kCALayerMaxYMargin;
         newLayer.contentsGravity = kCAGravityCenter;
         newLayer.contents = (id)windowSample;
         newLayer.frame = CGRectMake(0.0, 0.0, NSWidth(view.frame), NSHeight(view.frame));
         [view.layer insertSublayer:newLayer below:[view.layer.sublayers lastObject]];
        
        // Analyze image to find corner point
        [cornerPoints addObject:[NSValue valueWithPoint:[self _lowerLeftCornerOfBitmap:[[[NSBitmapImageRep alloc] initWithCGImage:windowSample] autorelease]]]];
        
        frameSlider.maxValue = cornerPoints.count - 1;
        frameSlider.numberOfTickMarks = cornerPoints.count;
        self.currentFrame = frameSlider.maxValue;
}


#pragma mark Private

- (NSPoint)_lowerLeftCornerOfBitmap:(NSBitmapImageRep *)bitmap;
{
    // This algorithm depends on the fact the left edge remains straight
    NSInteger minX = 0, maxX = bitmap.pixelsWide / 2, minY = 0, maxY = bitmap.pixelsHigh / 2;
    if ([[bitmap colorAtX:maxX y:maxY] isEqual:[bitmap colorAtX:minX y:minY]])
        return NSZeroPoint; // Blank or Full-view image
    
    NSColor *testColor = [bitmap colorAtX:minX y:maxY]; // Doesn't matter what the color is, as long as it's not the same color as the panel
    
    // Get within 5 pixels of the left edge without entering the panel
    while (minX + 5 < maxX) {
        NSInteger midPoint = (maxX - minX) / 2 + minX; 
        if ([[bitmap colorAtX:midPoint y:maxY] isEqual:testColor])
            minX = midPoint;
        else
            maxX = midPoint;
    }
    
    // Step to the left edge one pixel at a time
    while (maxX > minX && ![[bitmap colorAtX:maxX - 1 y:maxY] isEqual:testColor])
        maxX--;
    
    // At this point maxX is the edge
    
    // Get within 5 pixels of the bottom edge without entering the panel
    while (minY + 5 < maxY) {
        NSInteger midPoint = (maxY - minY) / 2 + minY;
        if ([[bitmap colorAtX:maxX y:midPoint] isEqual:testColor])
            minY = midPoint;
        else
            maxY = midPoint;
    }
    
    // Step to the bottom edge one pixel at a time
    while (maxY > 0 && ![[bitmap colorAtX:maxX y:maxY - 1] isEqual:testColor])
        maxY--;
    
    // Establish baseline data for first frame
    if (NSEqualSizes(layerContentSize, NSZeroSize)) {
        layerContentSize = bitmap.size;
        bottomEdge = bitmap.pixelsHigh / bitmap.size.height * maxY;
        bottomEdge += (pathLayer.frame.size.height - layerContentSize.height) / 2.0;
    }
    
    return NSMakePoint(bitmap.pixelsWide / bitmap.size.width  * maxX,  bitmap.pixelsHigh / bitmap.size.height * maxY);
}

@end
