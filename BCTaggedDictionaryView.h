//
//  BCTaggedDictionaryView.h
//  Caravan
//
//  Created by Tom Houpt on 15/4/3.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

// NOTE: implement a response to notification that view or first responder changed,
// so we can retrieve values  when focus changes to another window


#import <Cocoa/Cocoa.h>

#define kBCTaggedDictionaryViewEditedNotification @"BCTaggedDictionaryViewEdited"

@interface BCTaggedDictionaryView : NSView

@property NSMutableDictionary *myDictionary;

@property NSDictionary *tagDictionary;

-(void)populateFromDictionary:(NSMutableDictionary *)d;

-(IBAction)viewEdited:(id)sender;

@end
