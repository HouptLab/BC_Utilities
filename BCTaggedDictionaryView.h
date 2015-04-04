//
//  BCTaggedDictionaryView.h
//  Caravan
//
//  Created by Tom Houpt on 15/4/3.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BCTaggedDictionaryView : NSView

@property NSMutableDictionary *myDictionary;

@property NSDictionary *tagDictionary;

-(void)populateFromDictionary:(NSMutableDictionary *)d;

-(IBAction)viewEdited:(id)sender;


@end
