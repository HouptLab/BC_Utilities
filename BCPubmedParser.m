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



@implementation BCPubmedParser

@synthesize pmid;


-(id)initWithPMID:(NSInteger)p;
{
    
    self = [super init];
    if (self) {
        
        self.containerStack = [NSMutableArray array];

        self.parseCompleted  = NO;
        
        pmid = p;
        
        // get url to make connection with pubmed
        NSString *requestURLString = [NSString stringWithFormat:kBCPubmedQueryFormatString,pmid];
        
        NSURL *pubmedURL = [NSURL URLWithString:requestURLString];
        
        // send request for xml using pmid
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        
        [[delegateFreeSession dataTaskWithURL: pubmedURL
                            completionHandler:^(NSData *xml, NSURLResponse *response,
                                                NSError *error) {
                               NSLog(@"Got response %@ with error %@.\n", response, error);
//                             NSLog(@"DATA:\n%@\nEND DATA\n",
//                                      [[NSString alloc] initWithData: xml
//                                                            encoding: NSUTF8StringEncoding]);

                                 [[NSNotificationCenter defaultCenter] postNotificationName:kBCPubmedXMLRetrievedNotification
                                                             object:self
                                                           userInfo:@{@"sender":self} ];
                                
                                self.xmlParser = [[NSXMLParser alloc] initWithData:xml];
                                [self.xmlParser setDelegate:self];
                                [self.xmlParser setShouldResolveExternalEntities:YES];
                                [self.xmlParser parse];
                            }]
         resume];

        
        
    }
    
    return self;
    
    
}

-(BOOL)isNameOfDictionaryElement:(NSString *)elementName; {

    // override base class
    
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
    
   // NSLog(@"Unknown element: %@", elementName);
    return NO;
    
}

-(BOOL)isNameOfArrayElement:(NSString *)elementName; {

    // override base class

    
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

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
    
    [super parserDidEndDocument:parser];
    
   // BCXMLElement *parsedXML = [self xmlDictionary];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBCPubmedParserCompletionNotification
                                                             object:self
                                                           userInfo:@{@"sender":self,@"pmid":[NSNumber numberWithInteger:pmid]} ];
}

@end
