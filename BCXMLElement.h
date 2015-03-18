//
//  BCXMLElement.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/17.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BCXMLElementType) {
    kBCXMLElementOther = 0,
    kBCXMLElementArray = 1,
    kBCXMLElementDictionary = 2,
    kBCXMLElementString = 3
};

@interface BCXMLElement : NSObject

@property (copy) NSString *name;
@property NSObject *value;

-(BCXMLElementType) type;
/// value can be of class NSMutableArray, NSMutableDictionary, or NSString
@end
