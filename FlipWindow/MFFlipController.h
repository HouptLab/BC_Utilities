//
//  MFFlipController.m
//  Lemur Flip
//
//  Created by Mike Lee on 1/4/08.
//  Based on research by Lucas Newman.
//  Released in the public domain.
//

#import <Cocoa/Cocoa.h>

@class MFFlipDebugger;

@interface MFFlipController : NSObject {
    IBOutlet NSView *frontView, *backView;

    BOOL isDebugging;
    CGFloat scale;
    NSInteger distortion;
    
    NSWindow *window;
    MFFlipDebugger *debugger;
}

@property BOOL isDebugging;
@property CGFloat scale;
@property NSInteger distortion;

- (IBAction)flip:(id)sender;
- (IBAction)showDebugger:(id)sender;

@end
