/*
 *  BCAlert.h
 *  Bartender
 *
 *  Created by Tom Houpt on 12/7/30.
 *  Copyright 2012 Behavioral Cybernetics. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

// returns button pressed

// e.g, NSAlertFirstButtonReturn, NSAlertSecondButtonReturn

// int style, e.g., NSWarningAlertStyle, NSInformationAlertStyle


void BCOneButtonAlert(unsigned long style, NSString *message, NSString *information, NSString *button1);
NSInteger BCTwoButtonAlert(unsigned long style, NSString *message, NSString *information, NSString *button1, NSString *button2);
NSInteger BCThreeButtonAlert(unsigned long style, NSString *message, NSString *information, NSString *button1, NSString *button2, NSString *button3);


//An alert’s return values for buttons are position dependent; buttons numbered RIGHT to LEFT. 
// The following constants describe the return values for the first three buttons on an alert 
// (assuming a language that reads left to right).
//
//enum {
//	NSAlertFirstButtonReturn  = 1000, // rightmost button on the dialog or sheet.
//	NSAlertSecondButtonReturn  = 1001,
//	NSAlertThirdButtonReturn  = 1002
//};


