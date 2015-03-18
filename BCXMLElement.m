//
//  BCXMLElement.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/17.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCXMLElement.h"

@implementation BCXMLElement

-(BCXMLElementType) type; {
    
    BCXMLElementType type = kBCXMLElementOther;
    
    if ([_value isKindOfClass:[NSArray class]]) {
        
        type = kBCXMLElementArray;
        
    }
    else     if ([_value isKindOfClass:[NSDictionary class]]) {
        
        type = kBCXMLElementDictionary;
        
    }
    else     if ([_value isKindOfClass:[NSString class]]) {
        
        type = kBCXMLElementString;
        
    }
    
    return type;
}

@end
