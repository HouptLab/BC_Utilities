//
//  MFFlipController.m
//  Lemur Flip
//
//  Created by Mike Lee on 1/4/08.
//  Based on research by Lucas Newman.
//  Released in the public domain.
//

#import <QuartzCore/QuartzCore.h>
#import "MFFlipController.h"
#import "MFFlipDebugger.h"

#define MFCFAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]
#define WINDOW_PADDING (50)


@interface MFFlipController ()
- (void)_swapViews;
- (void)_prepareViewIsFront:(BOOL)isFront;
- (void)_hideShadow:(BOOL)hidden;
- (CAAnimationGroup *)_flipAnimationWithDuration:(CGFloat)duration isFront:(BOOL)isFront;
@end


@implementation MFFlipController

#pragma mark NSObject (NSApplicationNotifications)

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    // In order to simulate a floating panel, we create an over-large, borderless, invisible window.
    window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, NSWidth(frontView.frame) + 2 * WINDOW_PADDING, NSHeight(frontView.frame) + 2 * WINDOW_PADDING) styleMask:NSBorderlessWindowMask backing:NSBackingStoreRetained defer:NO];
    [window setMovableByWindowBackground:YES];
    [window setOpaque:NO];
    [window.contentView setWantsLayer:YES];
    window.backgroundColor = [NSColor clearColor];
    [window.contentView layer].backgroundColor = CGColorGetConstantColor(kCGColorClear);
    
    self.distortion = 0;
    self.scale = 1.0;
    
    // Helper functions because I hate writing the same code twice.
    [self _prepareViewIsFront:YES];
    [self _prepareViewIsFront:NO];
    [self _hideShadow:NO];

    [window center];
    [window makeKeyAndOrderFront:nil];

    debugger = [[MFFlipDebugger alloc] initWithWindowNumber:window.windowNumber];
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
    [debugger release];
    debugger = nil;
    [window release];
    window = nil;
}


#pragma mark NSObject (CAAnimationDelegate)

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag;
{
    // This delegate method allows us to clean up our state
    if (![animation isKindOfClass:[CAAnimationGroup class]])
         { return; }

    // Our animation is one-way and has been expended, so we can remove them
    [frontView.layer removeAnimationForKey:@"flipGroup"];
    [backView.layer removeAnimationForKey:@"flipGroup"];
    
    // Although the "back" layer seemed to rotate forward, in reality it's still flipped.
    [CATransaction begin];
    // Since this is already our assumed state, do not animate this
    [CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
    // Remove all transforms by setting the identity (standard) transform
    frontView.layer.transform = CATransform3DIdentity;
    backView.layer.transform = CATransform3DIdentity;
    [CATransaction commit];

    if (self.isDebugging) // Restore shadows if necessary
        [self _hideShadow:NO];
}

@synthesize isDebugging, distortion, scale;

- (void)setDistortion:(NSInteger)distortionInNewmans;
{
    if (distortion == distortionInNewmans)
         { return; }
    
    [self willChangeValueForKey:@"distortion"];
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    if (distortionInNewmans)
        perspectiveTransform.m34 = 1.0 / distortionInNewmans;
    
    ((NSView *)window.contentView).layer.sublayerTransform = perspectiveTransform;
    [self didChangeValueForKey:@"distortion"];
}

#pragma mark Actions

- (IBAction)flip:(id)sender;
{
    #define ANIMATION_DURATION_IN_SECONDS (1.0)
    // Hold the shift key to flip the window in slo-mo. It's really cool!
    CGFloat flipDuration = ANIMATION_DURATION_IN_SECONDS * (self.isDebugging || window.currentEvent.modifierFlags & NSShiftKeyMask ? 10.0 : 1.0);

    // The hidden layer is "in the back" and will be rotating forward. The visible layer is "in the front" and will be rotating backward
    CALayer *hiddenLayer = [frontView.isHidden ? frontView : backView layer];
    CALayer *visibleLayer = [frontView.isHidden ? backView : frontView layer];
    
    // Before we can "rotate" the window, we need to make the hidden view look like it's facing backward by rotating it pi radians (180 degrees). We make this its own transaction and supress animation, because this is already the assumed state
    [CATransaction begin]; {
        [CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
        [hiddenLayer setValue:[NSNumber numberWithDouble:M_PI] forKeyPath:@"transform.rotation.y"];
        if (self.isDebugging) // Shadows screw up corner finding
            [self _hideShadow:YES];
    } [CATransaction commit];
    
    // There's no way to know when we are halfway through the animation, so we have to use a timer. On a sufficiently fast machine (like a Mac) this is close enough. On something like an iPhone, this can cause minor drawing glitches
    [self performSelector:@selector(_swapViews) withObject:nil afterDelay:flipDuration / 2.0];
    
    // For debugging, sample every half-second
    if (self.isDebugging) {
        [debugger reset];
        
        NSUInteger frameIndex;
        for (frameIndex = 0; frameIndex < flipDuration; frameIndex++)
            [debugger performSelector:@selector(sample) withObject:nil afterDelay:(CGFloat)frameIndex / 2.0];
    
        // We want a sample right before the center frame, when the panel is still barely visible
        [debugger performSelector:@selector(sample) withObject:nil afterDelay:(CGFloat)flipDuration / 2.0 - 0.05];
    }
    
    // Both layers animate the same way, but in opposite directions (front to back versus back to front)
    [CATransaction begin]; {
        [hiddenLayer addAnimation:[self _flipAnimationWithDuration:flipDuration isFront:NO] forKey:@"flipGroup"];
        [visibleLayer addAnimation:[self _flipAnimationWithDuration:flipDuration isFront:YES] forKey:@"flipGroup"];
    } [CATransaction commit];
}

- (IBAction)showDebugger:(id)sender;
{
    [debugger showWindow:sender];
}


#pragma mark Private

- (void)_swapViews;
{
    // At the point the window flips, change which view is visible, thus bringing it "to the front"
    [frontView setHidden:![frontView isHidden]];
    [backView setHidden:![backView isHidden]];
}

- (void)_prepareViewIsFront:(BOOL)isFront;
{
    NSRect frame = NSMakeRect(WINDOW_PADDING, WINDOW_PADDING, NSWidth(frontView.frame), NSHeight(frontView.frame));
    NSView *view = isFront ? frontView : backView;
    [view setHidden:!isFront];
    
    [window.contentView addSubview:view];
    [view setFrameOrigin:NSMakePoint(WINDOW_PADDING, WINDOW_PADDING)];
    view.layer.anchorPoint = CGPointMake(0.5, 0.5);
    view.layer.frame = NSRectToCGRect(frame);
    view.layer.backgroundColor = MFCFAutorelease(CGColorCreateGenericRGB(isFront ? 1.0 : 0.0, isFront ? 0.0 : 1.0, 0.0, 0.5));
}

- (void)_hideShadow:(BOOL)hidden;
{
    #define SHADOW_OPACITY (0.25)
    #define SHADOW_RADIUS (10.0)
    #define SHADOW_OFFSET CGSizeMake(0.0, -10)
    
/*
    Here's an oddity. This throws a compiler error:
    frontView.layer.shadowOffset = debugging ? CGSizeZero : SHADOW_OFFSET;
 
    But these both work:
    [frontView.layer setShadowOffset:debugging ? CGSizeZero : SHADOW_OFFSET];
    frontView.layer.shadowOffset = debugging ? CGMakeSize(0.0, 0.0) : SHADOW_OFFSET;
 */
    
    frontView.layer.shadowOpacity = hidden ? 0.0 : SHADOW_OPACITY;
    frontView.layer.shadowRadius = hidden ? 0.0 : SHADOW_RADIUS;
    frontView.layer.shadowOffset = hidden ? CGSizeMake(0.0, 0.0) : SHADOW_OFFSET;

    backView.layer.shadowOpacity = hidden ? 0.0 : SHADOW_OPACITY;
    backView.layer.shadowRadius = hidden ? 0.0 : SHADOW_RADIUS;
    backView.layer.shadowOffset = hidden ? CGSizeMake(0.0, 0.0) : SHADOW_OFFSET;
}

- (CAAnimationGroup *)_flipAnimationWithDuration:(CGFloat)duration isFront:(BOOL)isFront;
{
    // Rotating halfway (pi radians) around the Y axis gives the appearance of flipping
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];

    // The hidden view rotates from negative to make it look like it's in the back
    #define LEFT_TO_RIGHT (isFront ? -M_PI : M_PI)
    #define RIGHT_TO_LEFT (isFront ? M_PI : -M_PI)
    flipAnimation.toValue = [NSNumber numberWithDouble:[backView isHidden] ? LEFT_TO_RIGHT : RIGHT_TO_LEFT];
    
    // Shrinking the view makes it seem to move away from us, for a more natural effect
    CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];

    shrinkAnimation.toValue = [NSNumber numberWithDouble:self.scale];

    // We only have to animate the shrink in one direction, then use autoreverse to "grow"
    shrinkAnimation.duration = duration / 2.0;
    shrinkAnimation.autoreverses = YES;
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:flipAnimation, shrinkAnimation, nil];

    // As the edge gets closer to us, it appears to move faster. Simulate this in 2D with an easing function
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    // Set ourselves as the delegate so we can clean up when the animation is finished
    animationGroup.delegate = self;
    animationGroup.duration = duration;

    // Hold the view in the state reached by the animation until we can fix it, or else we get an annoying flicker
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;

    return animationGroup;
}

@end