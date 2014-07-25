//
//  ProgressDialog.m
//
//  Created by Tom Houpt on 11/4/30.
//  Copyright 2011 "Voyages". All rights reserved.
//

#import "BCProgressDialog.h"

@implementation BCProgressDialog 

-(id)init; {
	self = [super init];
    if (self) {
		if (!dialog) {
            
      //  [[NSBundle mainBundle ]loadNibNamed:@"BCProgressDialog" owner:self topLevelObjects:NULL];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [NSBundle  loadNibNamed:@"BCProgressDialog" owner:self];
#pragma clang diagnostic pop
        }
				  
	}
	return self;
	
}

-(void)startDisplayForWindow:(NSWindow *)ownerWindow; {
	
	[NSApp beginSheet: dialog
	   modalForWindow: ownerWindow
		modalDelegate: nil
	   didEndSelector: nil
		  contextInfo: nil];
	
	// See NSApplication Class Reference/runModalSession
	
}


-(void)endDisplay; {
	[dialog close];

	[NSApp endSheet: dialog];
	[dialog orderOut: self];
	
}

-(void)setIconImage:(NSImage *)theImage; {
    
    [iconImageView setImage:theImage];
    
}

-(void)setTitleLabel:(NSString *)text; {
	[title setStringValue:text];
}

-(void)setTopLabel:(NSString *)top andTopIndicator:(double)value; {
	[topLabel setStringValue:top];
	[topIndicator setDoubleValue:value];
    [dialog display];
}

-(void)setSubLabel:(NSString *)sub andSubIndicator:(double)value; {
	
	[subLabel setStringValue:sub];
	[subIndicator setDoubleValue:value];
    [dialog display];
}

-(void)hideSubLabelAndIndicator; {

	[subLabel setHidden:YES];
	[subIndicator setHidden:YES];
    [dialog setViewsNeedDisplay:YES];

}

-(IBAction)cancelButtonPressed:(id)sender; {
	
//	
//	// user cancelled
//    if (_threadData) {
//		cancelWorkerRequest(_threadData->request);
//    }
//	
//    // stop the timer
//    [self setProgressTimer:nil];
//    
//    [exportProgressPanel close];
//    [NSApp endSheet:exportProgressPanel];
	
	
}

-(BOOL)cancelWasPressed; { return cancelWasPressed; }


@end
