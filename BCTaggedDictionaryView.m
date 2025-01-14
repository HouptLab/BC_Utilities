//
//  BCTaggedDictionaryView.m
//  Caravan
//
//  Created by Tom Houpt on 15/4/3.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCTaggedDictionaryView.h"

@implementation BCTaggedDictionaryView

@synthesize myDictionary;
@synthesize tagDictionary;

-(void)populateFromDictionary:(NSMutableDictionary *)d; {
    
    myDictionary = d;
    
    if (nil != tagDictionary) {
        
 
        
        
        for (NSString *key in [myDictionary allKeys]) {
            
            NSNumber *tag = [tagDictionary objectForKey:key];
            
            if (nil != tag) {
                NSTextField *textField = [self viewWithTag:[tag integerValue]];
                
                if (nil != textField) {
                    
                    [textField setStringValue:[myDictionary objectForKey:key]];
                }
            }
            
        }
    }
}

-(IBAction)viewEdited:(id)sender; {
    
    if (nil == myDictionary)  { return; }
    
    for (NSString *key in [myDictionary allKeys]) {
        
        NSNumber *tag = [tagDictionary objectForKey:key];
        
        if ([sender tag] == [tag integerValue]) {
            
            NSString *oldValue =  (NSString *)[myDictionary valueForKey:key];
            NSString *newValue = [[sender stringValue] copy] ;
            if (![oldValue isEqualToString:newValue ]) {
                
                [myDictionary setValue:[sender stringValue] forKey:key];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kBCTaggedDictionaryViewEditedNotification
                                                                    object:self
                                                                  userInfo:
                 @{
                 @"key":key,
                 @"oldValue":oldValue,
                 @"newValue":newValue
                 }
                ];
           
                return;
            }
        }
        
    }
    

}



@end
