//
//  MFFlipDebugger.h
//  Lemur Flip
//
//  Created by Mike Lee on 1/4/08.
//  Released in the public domain.
//

#import <Cocoa/Cocoa.h>

@interface MFFlipDebugger : NSWindowController {
    IBOutlet NSView *view;
    IBOutlet NSSlider *frameSlider;
    IBOutlet NSTextField *positiveY, *negativeY;

    @private
    NSMutableArray *cornerPoints;
    CALayer *pathLayer;
    CGFloat bottomEdge;
    NSInteger windowNumber;
    NSUInteger currentFrame;
    NSSize layerContentSize;
}

@property NSUInteger currentFrame;

- (id)initWithWindowNumber:(NSInteger)theNumber;
- (void)reset;
- (void)sample;

@end
