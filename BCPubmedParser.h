//
//  BCPubmedParser.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/17.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBCPubmedParserCompletionNotification @"BCPubmedParserCompletionNotification"

@class BCXMLElement;

@interface BCPubmedParser : NSObject <NSXMLParserDelegate>

@property NSInteger pmid;
@property (copy) NSMutableArray *containerStack;
@property (copy) NSMutableString *currentStringValue;


@property NSXMLParser *xmlParser;
@property BOOL parseCompleted;

-(id)initWithPMID:(NSInteger)p;

/** dictionary compiled from xml
 
 */
-(BCXMLElement *)xmlDictionary;

@end
