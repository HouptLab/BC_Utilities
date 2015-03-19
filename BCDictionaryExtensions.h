//
//  BCDictionaryExtensions.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/18.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BCExtensions)

/** return object at bottom of given path of dictionary keyes
 
    i.e given path @"dict1/dict2/key"
 
    return [[[self objectForKey:dict1] objectForKey:dict2] objectForKey:key]
 
    return nil if any path keys are not found or are not dictionaries
 
*/
-(NSObject *) objectAtKeyPath:(NSString *)path;

@end
