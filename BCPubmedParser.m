//
//  BCPubmedParser.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/17.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCPubmedParser.h"
#import "BCCitation.h"
#import "BCAlert.h"

#import "BCXMLElement.h"

@interface BCPubmedParser (Private)

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

@implementation BCPubmedParser

@synthesize pmid;
@synthesize currentStringValue;
@synthesize containerStack;

@synthesize xmlParser;
@synthesize parseCompleted;

-(id)initWithPMID:(NSInteger)p;
{
    
    self = [super init];
    if (self) {
        
        containerStack = [NSMutableArray array];

        parseCompleted  = NO;
        
        pmid = p;
        
        // get url to make connection with pubmed
        NSString *requestURLString = [NSString stringWithFormat:@"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=%ld&retmode=xml",pmid];
        
        NSURL *pubmedURL = [NSURL URLWithString:requestURLString];
        
        // send request for xml using pmid
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        
        [[delegateFreeSession dataTaskWithURL: pubmedURL
                            completionHandler:^(NSData *xml, NSURLResponse *response,
                                                NSError *error) {
                                NSLog(@"Got response %@ with error %@.\n", response, error);
                                NSLog(@"DATA:\n%@\nEND DATA\n",
                                      [[NSString alloc] initWithData: xml
                                                            encoding: NSUTF8StringEncoding]);
                                xmlParser = [[NSXMLParser alloc] initWithData:xml];
                                [xmlParser setDelegate:self];
                                [xmlParser setShouldResolveExternalEntities:YES];
                                [xmlParser parse];
                            }]
         resume];

        
        
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

//-(NSMutableDictionary *)topDictionary; {
//    return (NSMutableDictionary *)[containerStack lastObject];
//}
//-(NSMutableArray *)topArray; {
//    return (NSMutableArray *)[containerStack lastObject];
//}
-(BCXMLElement *)topElement; {
    return (BCXMLElement *)[containerStack lastObject];
}


//-(BOOL)topContainerIsXMLElement; {
//    return [[containerStack lastObject] isKindOfClass:[BCXMLElement class]];
//}
//-(BOOL)topContainerIsDictionary; {
//    
//    return [[containerStack lastObject] isKindOfClass:[NSMutableDictionary class]];
//    
//}
//-(BOOL)topContainerIsArray; {
//    
//    return [[containerStack lastObject] isKindOfClass:[NSMutableArray class]];
//
//}
-(void)addElementToTopContainer:(BCXMLElement *)element;
{
    
    if (nil != [self topElement]) {
        [[self topElement] addSubElement:element];
    }
    else {
        [containerStack addObject:element];
    }
    
    
//    else if ([self topContainerIsDictionary]) {
//        [[self topDictionary] setObject:element.value forKey:element.name];
//    }
//    else if ([self topContainerIsArray]) {
//        [[self topArray] addObject:element];
//    }
    
}

-(BOOL)isNameOfDictionaryElement:(NSString *)elementName; {
    
     NSArray *dictionaryElements = @[
                                     @"Abstract",
                                     @"AffiliationInfo",
                                     @"Article",
                                     @"Author",
                                     @"Chemical",
                                     @"CommentsCorrections",
                                     @"DateCompleted",
                                     @"DateCreated",
                                     @"DateRevised",
                                     @"Investigator",
                                     @"Journal",
                                     @"JournalIssue",
                                     @"MedlineCitation",
                                     @"OtherAbstract",
                                     @"Pagination",
                                     @"PersonalNameSubject",
                                     @"PubDate",
                                     @"History",
                                     @"MedlineJournalInfo",
                                     @"PubmedArticle",
                                     @"PubmedArticleSet",
                                     @"PubmedData",
                                     @"PubMedPubDate"
                                     ];

    for (NSString *eachElement in dictionaryElements ) {
        if ([elementName isEqualToString:eachElement]) {
            return YES;
        }
    }
    
    return NO;
    
}

-(BOOL)isNameOfArrayElement:(NSString *)elementName; {
    
    NSArray *arrayElements = @[
                               @"AccessionNumberList",
                               @"AuthorList",
                               @"ChemicalList",
                               @"CollectiveName",
                               @"DataBankList",
                               @"GeneSymbolList",
                               @"GrantList",
                               @"InvestigatorList",
                               @"KeywordList",
                               @"MeshHeadingList",
                               @"PersonalNameSubjectList",
                               @"PublicationTypeList",
                               @"SupplMeshList",
                               @"ArticleIdList",
                               @"CommentsCorrectionsList",
                              ];

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
    // add the root dictionary to the stack
    [containerStack removeAllObjects];
   // [containerStack addObject:[NSMutableDictionary dictionary]];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
    
    parseCompleted = YES;
    // NOTE: post notification that parse was completed?
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBCPubmedParserCompletionNotification
                                                             object:self
                                                           userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInteger:pmid],nil]
                                                                                                forKeys:[NSArray arrayWithObjects:@"pmid",nil]]];
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
