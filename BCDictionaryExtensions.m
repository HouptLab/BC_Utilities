//
//  BCDictionaryExtensions.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/18.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCDictionaryExtensions.h"

@implementation NSDictionary  (BCExtensions)

-(NSObject *) objectAtKeyPath:(NSString *)path;{
    
    NSDictionary *currentDictionary = self;
    NSArray *keys = [path componentsSeparatedByString:@"/"];
    
    for (NSString *eachKey in keys) {
        
        NSObject *nextObject = [currentDictionary objectForKey:eachKey];
        
        
        if (eachKey == [keys lastObject]) {
            
            return nextObject;
        }
        
        if (nextObject == nil) {
            
            return nextObject;
        }

        else if (![nextObject isKindOfClass:[NSDictionary class]]) {
            
            return nil;
            
        }
        
        currentDictionary = (NSDictionary *)nextObject;
    }
    
    return nil;
    
}

@end
