/*
 *  BCAlert.c
 *  Bartender
 *
 *  Created by Tom Houpt on 12/7/30.
 *  Copyright 2012 Behavioral Cybernetics. All rights reserved.
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
	if (nil != button1) [alert addButtonWithTitle:button1];
	if (nil != button2) [alert addButtonWithTitle:button2];
	if (nil != button3) [alert addButtonWithTitle:button3];	
	
	NSInteger button = [alert runModal];
	
	// [alert release];
	
	return button;
	
}

