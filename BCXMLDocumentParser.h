//
//  BCXMLDocumentParser.h
//  Caravan
//
//  Created by Tom Houpt on 16/6/2.
//  Copyright © 2016 Tom Houpt. All rights reserved.
//


/** BCXMLDocumentParser

Usage: need to define a list of expected Element keys and Array Element keys
in the private methods

-(BOOL)isNameOfDictionaryElement:(NSString *)elementName;
-(BOOL)isNameOfArrayElement:(NSString *)elementName;

 kBCXMLDocumentParserCompletionNotification will be posted when NSXML parser is done parsing

 the XML document is placed in  a dictionary accessed via [BCXMLDocumentParser xmlDictionary]


for example:

 -(void)startParser:(NSData *)xmlData {
    BCXMLDocumentParser *parser = [BCXMLDocumentParser alloc] initWithData:(NSData *)xmlData];
    [defaultCenter addObserver:self
                      selector:@selector(parserCompleted:)
                          name:kBCXMLDocumentParserCompletionNotification object:nil];
 }

-(void)parserCompleted:(NSNotification *)note; {
    BCXMLDocumentParser * parser= note.object;
    BCXMLElement *keggPathway = [parser xmlDictionary];
 }


 
*/

#import <Foundation/Foundation.h>

#define kBCXMLDocumentParserCompletionNotification @"BCXMLDocumentParserCompletionNotification"

@class BCXMLElement;

@interface BCXMLDocumentParser : NSObject <NSXMLParserDelegate>

@property NSMutableArray *containerStack;
@property NSMutableString *currentStringValue;


@property NSXMLParser *xmlParser;
@property BOOL parseCompleted;

-(id)initWithData:(NSData *)xmlData;


/** dictionary compiled from xml
 
 */
-(BCXMLElement *)xmlDictionary;

@end
