//
//  BCXMLDocumentParser.m
//  Caravan
//
//  Created by Tom Houpt on 16/6/2.
//  Copyright © 2016 Tom Houpt. All rights reserved.
//

#import "BCXMLDocumentParser.h"

#import "BCAlert.h"

#import "BCXMLElement.h"

@interface BCXMLDocumentParser (Private)

-(void)pushContainerStack:(BCXMLElement *)d;
-(BCXMLElement *)popContainerStack;
//-(BOOL)topContainerIsDictionary;
//-(BOOL)topContainerIsArray;
//-(NSMutableDictionary *)topDictionary;
//-(BOOL)topContainerIsXMLElement;
//-(NSMutableArray *)topArray;
-(BCXMLElement *)topElement;
-(void)addElementToTopContainer:(BCXMLElement *)element;


-(BOOL)isNameOfDictionaryElement:(NSString *)elementName;
-(BOOL)isNameOfArrayElement:(NSString *)elementName;

@end

@implementation BCXMLDocumentParser

@synthesize currentStringValue;
@synthesize containerStack;

@synthesize xmlParser;
@synthesize parseCompleted;

-(id)initWithData:(NSData *)xmlData;
{
    
    self = [super init];
    if (self) {
        
        containerStack = [NSMutableArray array];

        parseCompleted  = NO;
        
        xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
                                [xmlParser setDelegate:self];
                                [xmlParser setShouldResolveExternalEntities:YES];
                                [xmlParser parse];
    }
    
    return self;
    
    
}

-(void)pushContainerStack:(BCXMLElement *)d; {
    
    [containerStack addObject:d];
    
}
-(BCXMLElement *)popContainerStack; {
    BCXMLElement *top = (BCXMLElement *)[containerStack lastObject];
    if (nil != top &&  [containerStack firstObject] != top) {
        [containerStack removeLastObject];
    }
    return top;
}


-(BCXMLElement *)topElement; {
    return (BCXMLElement *)[containerStack lastObject];
}


-(void)addElementToTopContainer:(BCXMLElement *)element;
{
    
    if (nil != [self topElement]) {
        [[self topElement] addSubElement:element];
    }
    else {
        [containerStack addObject:element];
    }
    

}

-(BOOL)isNameOfDictionaryElement:(NSString *)elementName; {
    
    NSArray *dictionaryElements = @[];


    for (NSString *eachElement in dictionaryElements ) {
        if ([elementName isEqualToString:eachElement]) {
            return YES;
        }
    }
    
    return NO;
    
}

-(BOOL)isNameOfArrayElement:(NSString *)elementName; {
    
    NSArray *arrayElements = @[];
    
    for (NSString *eachElement in arrayElements ) {
        if ([elementName isEqualToString:eachElement]) {
            return YES;
        }
    }
    
    return NO;
}

-(BCXMLElement *)xmlDictionary; {
    
    return (BCXMLElement *)[containerStack firstObject];
    
}


- (void)parserDidStartDocument:(NSXMLParser *)parser;
{
        NSLog(@"Start Document");

    // add the root dictionary to the stack
    [containerStack removeAllObjects];
   // [containerStack addObject:[NSMutableDictionary dictionary]];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
            NSLog(@"End Document");

    parseCompleted = YES;
    // NOTE: post notification that parse was completed?
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBCXMLDocumentParserCompletionNotification
                                                             object:self
                                                           userInfo:@{@"sender":self}
];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError; {
    
    
    BCOneButtonAlert(NSWarningAlertStyle,
                     @"Parsing Error!",
                     [NSString stringWithFormat:@"Error %li, Description: %@, Line: %li, Column: %li",
                      (long)[parseError code],
                      [[parser parserError] localizedDescription],
                      (long)[parser lineNumber],
                      (long)[parser columnNumber]],
                     @"OK");
    
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString;
{
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{

    NSLog(@"Parsed startElement: %@", elementName);

    
    BCXMLElement *newElement = [[BCXMLElement alloc] initWithName:elementName andAttributes:attributeDict];
    
    if ([self isNameOfArrayElement:elementName]) {
        [newElement setElementType:kBCXMLElementArray];
    }
    else if ([self isNameOfDictionaryElement:elementName]) {
        [newElement setElementType:kBCXMLElementDictionary];
    }
    else {
        currentStringValue = nil;
        [newElement setElementType:kBCXMLElementString];
    }
    
    [self pushContainerStack:newElement];

    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    if (!currentStringValue) {
        // currentStringValue is an NSMutableString instance variable
        currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    [currentStringValue appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    BCXMLElement *endingElement = (BCXMLElement *)[self popContainerStack];
    
    assert ([[endingElement name] isEqualToString:elementName]);
    
    
    NSLog(@"Parsed endElement: %@", elementName);
    
    // if ending element is an array or a dictionary, then take it off the stack
    
//    if (kBCXMLElementArray == [endingElement type]) {
//        if ( 0 == [(NSArray *)(endingElement.value) count]) {
//            endingElement.value = nil;
//        }
//    }
//    if (kBCXMLElementDictionary == [endingElement type]) {
//        if ( 0 == [(NSDictionary *)(endingElement.value) count]) {
//            endingElement.value = nil;
//        }
//    }
//    else {
//        
    
    if (kBCXMLElementString == [endingElement type]) {
        if (nil != currentStringValue ) {
            endingElement.value = [currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (0 == [((NSString *)endingElement.value) length]) {
                endingElement.value = nil;
            }
            currentStringValue = nil;
        }
        else {
            endingElement.value = nil;
        }
        
    }
    
    if (![endingElement isEmpty]) {
        [self addElementToTopContainer:endingElement];
    }
    
    
}

@end
