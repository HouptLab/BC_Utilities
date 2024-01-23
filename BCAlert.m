/*
 *  BCAlert.c
 *  Bartender
 *
 *  Created by Tom Houpt on 12/7/30.
 *  Copyright 2012 Behavioral Cybernetics LLC. All rights reserved.
 *
 */

#import "BCAlert.h"

void BCOneButtonAlert(unsigned long style, NSString *message, NSString *information,NSString *button1) {
	
	BCThreeButtonAlert(style, message, information, button1, nil, nil); 
	
	return;
	
		
}

NSInteger BCTwoButtonAlert(unsigned long style, NSString *message, NSString *information,NSString *button1, NSString *button2) {
	
	
	NSInteger button = BCThreeButtonAlert(style, message, information, button1, button2, nil); 
	
	return button;
	
}

NSInteger BCThreeButtonAlert(unsigned long style, NSString *message, NSString *information,NSString *button1, NSString *button2, NSString *button3) {
	
	NSAlert *alert = [[NSAlert alloc] init];
	
	[alert setAlertStyle:style];
	[alert setMessageText:message];
	[alert setInformativeText:information];
	if (nil != button1) {
        [alert addButtonWithTitle:button1]; 
    }
	if (nil != button2) {
        [alert addButtonWithTitle:button2];
    }
	if (nil != button3) {
        [alert addButtonWithTitle:button3];
    }
	
	NSInteger button = [alert runModal];
	
	// [alert release];
	
	return button;
	
}

void BCOneButtonAlertWithScrollingText(unsigned long style, NSString *message, NSString *information,NSString *scrollText,NSString *button1) {
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert setAlertStyle:style];
    [alert setMessageText:message];
    [alert setInformativeText:information];
    if (nil != button1) {[alert addButtonWithTitle:button1];}
    
    NSScrollView *scrollview = [[NSScrollView alloc]
                                initWithFrame:NSMakeRect(0,0,500,200)];
    NSSize contentSize = [scrollview contentSize];
    
    [scrollview setBorderType:NSNoBorder];
    [scrollview setHasVerticalScroller:YES];
    [scrollview setHasHorizontalScroller:NO];
    [scrollview setAutoresizingMask:NSViewWidthSizable |
     NSViewHeightSizable];
    
    NSTextView *theTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0,
                                                               contentSize.width, contentSize.height)];
    [theTextView setMinSize:NSMakeSize(0.0, contentSize.height)];
    [theTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [theTextView setVerticallyResizable:YES];
    [theTextView setHorizontallyResizable:NO];
    [theTextView setAutoresizingMask:NSViewWidthSizable];
    
    [[theTextView textContainer]
     setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
    [[theTextView textContainer] setWidthTracksTextView:YES];
    
    [scrollview setDocumentView:theTextView];
        
    [theTextView setString:scrollText];
    
    [alert setAccessoryView:scrollview];  // Accessory view: "my" accessed via an outlet connection
    
    
    [alert runModal];
    
        
    
}
