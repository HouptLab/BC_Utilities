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
@property NSMutableDictionary *attributes;
@property NSObject *value;

-(id)initWithName:(NSString *)n andAttributes:(NSDictionary *)a;

-(BOOL)isEmpty;

-(BOOL)hasAttributes;
-(NSString *)attributeForKey:(NSString *)k;

-(BCXMLElementType) type;
/// value can be of class NSMutableArray, NSMutableDictionary, or NSString

-(void)setElementType:(BCXMLElementType)type;

-(NSArray *)array;
-(NSDictionary *)dictionary;
-(NSString *)string;

-(void)addSubElement:(BCXMLElement *)e;
-(BCXMLElement *)elementForKey:(NSString *)n;
-(BCXMLElement *)elementAtIndex:(NSUInteger)i;
-(NSInteger)count; /// length if kBCXMLElementString; -1 if no count value?
-(NSInteger)length; /// same as count; -1 if no count value?

/** return object at bottom of given path of dictionary keys
 
 i.e given path @"dict1/dict2/key"
 
 return [[[self objectForKey:dict1] objectForKey:dict2] objectForKey:key]
 
 return nil if any path keys are not found or are not dictionaries
 
 */

-(BCXMLElement *) elementAtKeyPath:(NSString *)path;

@end
