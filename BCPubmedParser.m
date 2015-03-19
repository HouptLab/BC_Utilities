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

-(void)pushContainerStack:(NSObject *)d;
-(NSObject *)popContainerStack;
-(BOOL)topContainerIsDictionary;
-(BOOL)topContainerIsArray;
-(NSMutableDictionary *)topDictionary;
-(NSMutableArray *)topArray;
-(void)addTopContainerElement:(BCXMLElement *)element;


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

-(void)pushContainerStack:(NSObject *)d; {
    
    [containerStack addObject:d];
    
}
-(NSObject *)popContainerStack; {
    NSObject *top = [containerStack lastObject];
    [containerStack removeLastObject];
    return top;
}

-(NSMutableDictionary *)topDictionary; {
    
    return (NSMutableDictionary *)[containerStack lastObject];
    
}
-(NSMutableArray *)topArray; {
    return (NSMutableArray *)[containerStack lastObject];
}

-(BOOL)topContainerIsDictionary; {
    
    return [[containerStack lastObject] isKindOfClass:[NSMutableDictionary class]];
    
}
-(BOOL)topContainerIsArray; {
    
    return [[containerStack lastObject] isKindOfClass:[NSMutableArray class]];

}
-(void)addTopContainerElement:(BCXMLElement *)element;
{
    
    if ([self topContainerIsDictionary]) {
        [[self topDictionary] setObject:element.value forKey:element.name];
    }
    else if ([self topContainerIsArray]) {
        [[self topArray] addObject:element];
    }
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
                               @"KeyWordList",
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

-(NSDictionary *)dictionary; {
    
    return [containerStack firstObject];
    
}


- (void)parserDidStartDocument:(NSXMLParser *)parser;
{
    // add the root dictionary to the stack
    [containerStack removeAllObjects];
    [containerStack addObject:[NSMutableDictionary dictionary]];
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
    
    if ([self isNameOfArrayElement:elementName]) {
        
        NSMutableArray *newArray = [NSMutableArray array];
        [self pushContainerStack:newArray];
        
    }
    else if ([self isNameOfDictionaryElement:elementName]) {
        
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
        [self pushContainerStack:newDictionary];
        
    }
    
    currentStringValue = nil;
    
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
    BCXMLElement *newElement = [[BCXMLElement alloc] init];
    newElement.name = elementName;
    
    NSLog(@"Parsed endElement: %@", elementName);
    
    if ([self isNameOfArrayElement:elementName]) {
        newElement.value = [self popContainerStack];
        if ( 0 == [(NSArray *)(newElement.value) count]) {
            newElement.value = nil;
        }
    }
    else if ( [self isNameOfDictionaryElement:elementName]) {
        newElement.value = [self popContainerStack];
        if ( 0 == [(NSDictionary *)(newElement.value) count]) {
            newElement.value = nil;
        }
    }
    else {
        if (nil != currentStringValue ) {
            newElement.value = [currentStringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (0 == [((NSString *)newElement.value) length]) {
                newElement.value = nil;
            }
        }
        else {
            newElement.value = nil;
        }
        
        currentStringValue = nil;
        
    }
    
    if (newElement.value != nil) {
        [self addTopContainerElement:newElement];
    }
    
    
}

//
//// NOTE: ignore first 3 layers of eSummary, and dbBuild
//if ([elementName isEqualToString:@"eSummaryResult" ] ) {
//    // root DICTIONARY
//}
//else if ([elementName isEqualToString:@"DocumentSummarySet" ] ) {
//    // root2 DICTIONARY
//    
//    // attribute: status="OK"
//}
//else if ([elementName isEqualToString:@"DbBuild" ] ) {
//}
//
//else if ([elementName isEqualToString:@"DocumentSummary" ] ) {
//    // root3 DICTIONARY
//    // attribute:uid="25745168"
//}
//
//else if ([elementName isEqualToString:@"PubDate" ] ) {
//    // <Year>
//    // <Month>...
//}
//else if ([elementName isEqualToString:@"EPubDate" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"Source" ] ) {
//    // ABBREVIATED JOURNAL
//    
//}
//else if ([elementName isEqualToString:@"Authors" ] ) {
//    
//    // ARRAY of Author
//    
//}
//else if ([elementName isEqualToString:@"Author" ] ) {
//    // DICTIONARY
//    /*
//     <Author>
//     <Name>
//     </Name>
//     </Author>
//     
//     or
//     <Author>
//     <CollectiveName>
//     </CollectiveName>
//     </Author>
//     
//     or
//     <Author>
//     <FirstName EmptyYN="Y"></FirstName>
//     <MiddleName></MiddleName>
//     <LastNameMatiullah</LastName>
//     </Author>
//     */
//    
//}
//
//else if ([elementName isEqualToString:@"Name" ] ) {
//    
//    // LASTNAME INITIALS
//    
//}
//else if ([elementName isEqualToString:@"AuthType" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"ClusterID" ] ) {
//    
//}
//
//
//// see also GroupList of Group with individual names
//
//else if ([elementName isEqualToString:@"Title" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"Volume" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"Issue" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"Pages" ] ) {
//    
//}
//
//
//else if ([elementName isEqualToString:@"NlmUniqueID" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"ISSN" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"ESSN" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"PubType" ] ) {
//    // DICTIONARY of <flag>
//}
//else if ([elementName isEqualToString:@"flag" ] ) {
//    // @"Journal Article"
//    
//}
//
//
//
//else if ([elementName isEqualToString:@"ArticleIds" ] ) {
//    // ARRAY of ArticleID
//    
//}
//else if ([elementName isEqualToString:@"ArticleId" ] ) {
//    // DICTIONARY of
//    //IdType
//    //IdTypeN
//    //Value
//}
//else if ([elementName isEqualToString:@"IdType" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"IdTypeN" ] ) {
//    
//}
//else if ([elementName isEqualToString:@"Value" ] ) {
//    
//    
//    
//    else if ([elementName isEqualToString:@"History" ] ) {
//        // ARRAY of PubMedPubDate
//        //
//        
//    }
//    else if ([elementName isEqualToString:@"PubMedPubDate" ] ) {
//        // DICTIONARY of
//        // PubStatus
//        // Date
//        
//        
//    }
//    else if ([elementName isEqualToString:@"PubStatus" ] ) {
//        
//    }
//    else if ([elementName isEqualToString:@"Date" ] ) {
//        
//    }
//    
//    
//    else if ([elementName isEqualToString:@"FullJournalName" ] ) {
//        
//    }
//    else if ([elementName isEqualToString:@"ELocationID" ] ) {
//        
//    }
//    
//    else if ([elementName isEqualToString:@"BookTitle/" ] ) {
//        
//    }
//    
//    else if ([elementName isEqualToString:@"PublisherLocation/" ] ) {
//        
//    }
//    else if ([elementName isEqualToString:@"PublisherName/" ] ) {
//        
//    }
//    
//    else if ([elementName isEqualToString:@"LocationLabel/" ] ) {
//        
//    }
//    
//    else if ([elementName isEqualToString:@"BookName/" ] ) {
//        
//    }
//    else if ([elementName isEqualToString:@"Chapter/" ] ) {
//        
//    }
//    
//    else if ([elementName isEqualToString:@"SortFirstAuthor" ] ) {
//        
//    }
//    

@end
