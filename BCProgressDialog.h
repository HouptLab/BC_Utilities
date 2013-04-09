//
//  BCProgressDialog.h
//
//  Created by Tom Houpt on 11/4/30.
//  Copyright 2011 "Voyages". All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BCProgressDialog.h"

// timer periods
#define kProgressCheckInterval      0.05

/* 
 
 Displays a dialog box with 2 progress bars and a cancel button
 a title label, e.g. "Cell Counting Across Images"
 a top label, e.g. "Processing Image 7 of 20"
 top progress bar with value from 0.0 to 100.0, e.g. 100 * (7/20)
 a sublabel, e.g. "Scanning line 300 of 640"
 sub progress bar with value from 0.0 to 100.0, e.g. 100* (300/640)
 
 
 USAGE:
 
 // make sure "BCProgressDialog.nib" is part of the project
 
 progress = [[BCProgressDialog alloc] init];
 
 NSString *progressTitle = @"Cell Counting Across Images";
 
 [progress setTitleLabel:progressTitle];
 
 [progress startDisplayForWindow:[myNSDocument windowForSheet]];

 // if you only want 1 progress bar, call:
 // [progress hideSubLabelAndIndicator];
 
 for (image = 1; image <=20; image++) {
    // top indicator
 
    NSString *topLabel = [NSString stringWithFormat:@"Processing image %d of 20", image];
 
    [progress setTopLabel:topLabel andTopIndicator:100*image/20;

    for (line = 1; line <= 640; line++) {
        // subindicator
 
        NSString *subLabel = [NSString stringWithFormat:@"Scanning line %d of 640", line];
 
        [progress subLabel andSubIndicator:100*line/640;
 
        // was cancel button pressed?
 
        if ([progress cancelWasPressed]) {
 
            [progress endDisplay];
            // process cancelation
        }
 
    } // next line (subindicator)
 
 } next image (topindicator)
 
 [progress endDisplay];


*/


@interface BCProgressDialog : NSObject {
	
	
	IBOutlet NSPanel *dialog;
	
	IBOutlet NSTextField *title;
	IBOutlet NSTextField *topLabel;
	IBOutlet NSTextField *subLabel;
	
	IBOutlet NSProgressIndicator *topIndicator;
	IBOutlet NSProgressIndicator *subIndicator;
	
	IBOutlet NSButton *cancelButton;
	
	BOOL cancelWasPressed;
	
//	NSTimer *  _progressTimer;        // timer for updating the progress dialog box
	
	
}

-(id)init;
-(void)startDisplayForWindow:(NSWindow *)ownerWindow;
-(void)endDisplay; 
-(void)setTitleLabel:(NSString *)text;
-(void)setTopLabel:(NSString *)top andTopIndicator:(double)value;
-(void)setSubLabel:(NSString *)sub andSubIndicator:(double)value;
-(void)hideSubLabelAndIndicator;
-(IBAction)cancelButtonPressed:(id)sender;
-(BOOL)cancelWasPressed;


@end
