//
//  BCCitation.m
//  Xynk
//
//  Created by Tom Houpt on 15/2/25.
//
//

#import "BCCitation.h"
#import "BCCitationAuthor.h"
#import "BCAuthor.h"
#import "BCPubmedParser.h"
#import "BCDictionaryExtensions.h"

#define kCitationFirstAuthorKey	@"firstAuthor"
#define kCitationTitleKey	@"title"
#define kCitationDOIKey	@"doi"
#define kCitationUUIDKey @"uuid"
#define kCitationPublicationYearKey	@"publicationYear"
#define kCitationCorrespondingAuthorKey	@"correspondingAuthor"
#define kCitationCitationTypeKey	@"citationType"
#define kCitationAuthorsKey	@"authors"
#define kCitationJournalKey	@"journal"
#define kCitationJournalAbbreviationKey	@"journalAbbreviation"
#define kCitationVolumeKey	@"volume"
#define kCitationNumberKey	@"number"
#define kCitationPagesKey	@"pages"

#define kCitationAbstractKey	@"abstract"
#define kCitationWebsiteKey	@"website"
#define kCitationISSNKey	@"issn"
#define kCitationKeywordsKey	@"keywords"



#define kCitationBookTitleKey	@"bookTitle"
#define kCitationBookLengthKey	@"bookLength"
#define kCitationEditorsKey	@"editors"
#define kCitationPublisherKey	@"publisher"
#define kCitationPublicationPlaceKey	@"publicationPlace"
#define kCitationPublicationDateKey	@"publicationDate"
#define kCitationEPubDateKey	@"ePubDate"

#define kCitationDatabaseIDsKey	@"databaseIDs"


@implementation BCCitation

@synthesize pmidToParse;
@synthesize correspondingAuthor;
@synthesize citationType;
@synthesize authors;
@synthesize journal;
@synthesize journalAbbreviation;
@synthesize volume;
@synthesize number;
@synthesize pages;
@synthesize abstract;
@synthesize website;
@synthesize issn;
@synthesize keywords;

@synthesize bookTitle;
@synthesize bookLength;
@synthesize editors;
@synthesize publisher;
@synthesize publicationPlace;
@synthesize ePubDate;

@synthesize publicationDate;
@synthesize databaseIDs;

-(id)init; {
    
    return [self initWithAuthor:nil title:nil year:-1 doi:nil];
    
}

-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d; {
    
    self = [super initWithAuthor:a title:t year:y doi:d];
    
    if (self) {
        
        authors = [NSMutableArray array];
        editors = [NSMutableArray array];
        keywords = [NSMutableArray array];
        databaseIDs = [NSMutableDictionary dictionary];
        correspondingAuthor = [[BCAuthor alloc] init];
        citationType = kJournalArticle;
        publicationDate = [NSDate date];
        ePubDate = [NSDate date];
        
        for (NSString *key in @[
                                kCitationJournalKey,
                                kCitationJournalAbbreviationKey,
                                kCitationVolumeKey,
                                kCitationNumberKey,
                                kCitationPagesKey,
                                kCitationAbstractKey,
                                kCitationWebsiteKey,
                                kCitationISSNKey,
                                
                                kCitationBookTitleKey,
                                kCitationBookLengthKey,
                                kCitationPublisherKey,
                                kCitationPublicationPlaceKey,
                                ]) {
            
            [self setValue:[NSString string] forKey:key];
            
        }
        
    }
 
    return self;
}

-(id)initWithPMID:(NSInteger)pmid; {
    
    self = [self init];

    if (self) {
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                          selector:@selector(pmidParsed:)
                              name:kBCPubmedParserCompletionNotification object:nil];
        
        pmidToParse = pmid;

        // parse the xml to fill our fields...

        BCPubmedParser *parser = [[BCPubmedParser alloc] initWithPMID:pmidToParse];
        
    }
    
    return self;
    
}

-(void)pmidParsed:(NSNotification*) note; {
    
    BCPubmedParser  *parser = [note object];
    
    if ([[[note userInfo] valueForKey:@"pmid"] integerValue] != pmidToParse) { return; }

    [self setFieldsFromPubMedDictionary:[parser dictionary]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBCCitationEditedNotification
                                                        object:self
                                                      userInfo:nil
                                                                                           ];
    
}

#define kJournalISSNPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/ISSN"
#define kJournalVolumePath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/Volume"
#define kJournalIssuePath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/Issue"
#define kPublicationYearPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/PubDate/Year"
#define kJournalTitlePath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/Title"
#define kJournalAbbreviationPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/ISOAbbreviation"
#define kTitlePath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/ArticleTitle"
#define kPagesPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Pagination/MedlinePgn"
#define kWebsitePath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/ELocationID"
#define kAbstractPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Abstract/AbstractText"
#define kAuthorListPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/AuthorList"
#define kKeywordListPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/KeywordList"
#define kArticleIDPath @"PubmedArticleSet/PubmedArticle/PubmedData/ArticleIdList"

-(void)setFieldsFromPubMedDictionary:(NSDictionary *)rootDictionary; {
    
    // NOTE: check for nil returns...
    
    self.title = (NSString *)[rootDictionary objectAtKeyPath:kTitlePath];
    self.publicationYear = [(NSString *)[rootDictionary objectAtKeyPath:kPublicationYearPath] integerValue];
    self.journal  = (NSString *)[rootDictionary objectAtKeyPath:kJournalTitlePath];
    self.journalAbbreviation  = (NSString *)[rootDictionary objectAtKeyPath:kJournalAbbreviationPath];
    self.volume  = (NSString *)[rootDictionary objectAtKeyPath:kJournalVolumePath];
    self.number  = (NSString *)[rootDictionary objectAtKeyPath:kJournalIssuePath];
    self.issn  = (NSString *)[rootDictionary objectAtKeyPath:kJournalISSNPath];
    self.pages  = (NSString *)[rootDictionary objectAtKeyPath:kPagesPath];
    self.abstract  = (NSString *)[rootDictionary objectAtKeyPath:kAbstractPath];
    self.website  = (NSString *)[rootDictionary objectAtKeyPath:kWebsitePath];
    
    // NOTE: extract publicationDate and ePubDate
    
    // NOTE: try to find DOI from articleIDList
    
    
    NSArray *authorList = (NSArray *)[rootDictionary objectAtKeyPath:kAuthorListPath];
    NSArray *keywordList = (NSArray *)[rootDictionary objectAtKeyPath:kKeywordListPath];
    NSArray *articleIDList = (NSArray *)[rootDictionary objectAtKeyPath:kArticleIDPath];
    


}

-(NSString *) citation; {
    
    return [NSString stringWithFormat:@"%@ (%ld) %@.",self.firstAuthor, self.publicationYear, self.title];
}


-(NSString *)ascensionForDatabase:(NSString *)database; {
    
    if (nil == database) { return nil; }
    return [databaseIDs valueForKey:database];
}

-(void)setAscension:(NSString *)ascension forDatabase:(NSString *)database; {
    
    if (nil != ascension && nil != database) {
        [databaseIDs setValue:ascension forKey:database];
    }
    
}

-(NSDictionary *)packIntoDictionary; {

    NSMutableDictionary *theDictionary = [NSMutableDictionary
                                   dictionaryWithObjects:@[
                                                           self.firstAuthor,
                                                           self.title,
                                                           self.doi,
                                                           self.uuid,
                                                           [NSNumber numberWithInteger:self.publicationYear],
                                                           [correspondingAuthor packIntoDictionary],
                                                           [NSNumber numberWithInteger:citationType],
                                                           journal,
                                                           journalAbbreviation,
                                                           volume,
                                                           number,
                                                           pages,
                                                           abstract,
                                                           issn,
                                                           website,
                                                           keywords,
                                                           bookTitle,
                                                           bookLength,
                                                           publisher,
                                                           publicationPlace,
                                                           publicationDate,
                                                           ePubDate,
                                                           databaseIDs
                                                           ]
                                   forKeys:@[
                                             kCitationFirstAuthorKey,
                                             kCitationTitleKey,
                                             kCitationDOIKey,
                                             kCitationUUIDKey,
                                             kCitationPublicationYearKey,
                                             kCitationCorrespondingAuthorKey,
                                             kCitationCitationTypeKey,
                                             kCitationJournalKey,
                                             kCitationJournalAbbreviationKey,
                                             kCitationVolumeKey,
                                             kCitationNumberKey,
                                             kCitationPagesKey,
                                             kCitationAbstractKey,
                                             kCitationISSNKey,
                                             kCitationWebsiteKey,
                                             kCitationKeywordsKey,
                                             kCitationBookTitleKey,
                                             kCitationBookLengthKey,
                                             kCitationPublisherKey,
                                             kCitationPublicationPlaceKey,
                                             kCitationPublicationDateKey,
                                             kCitationEPubDateKey,
                                             kCitationDatabaseIDsKey
                                             
                                             ]
                                   
                                   ];
    
    
    // need to pack authors and editors separately
    
    NSMutableArray *authorsDictionaryArray = [NSMutableArray arrayWithCapacity:[authors count]];
    
    for (BCCitationAuthor *theAuthor in authors) {
        [authorsDictionaryArray addObject:[theAuthor packIntoDictionary]];
    }
    [theDictionary setObject:authorsDictionaryArray forKey:kCitationAuthorsKey];
    
    
    
    NSMutableArray *editorsDictionaryArray = [NSMutableArray arrayWithCapacity:[editors count]];
    for (BCCitationAuthor *theEditor in editors) {
        [editorsDictionaryArray addObject:[theEditor packIntoDictionary]];
    }
    [theDictionary setObject:editorsDictionaryArray forKey:kCitationEditorsKey];
    
    
    return theDictionary;
}

-(void)unpackFromDictionary:(NSDictionary *)theDictionary; {
    
    for (NSString *key in @[
                            kCitationFirstAuthorKey,
                            kCitationTitleKey,
                            kCitationDOIKey,
                            kCitationPublicationYearKey,
                            kCitationCitationTypeKey,
                            kCitationJournalKey,
                            kCitationJournalAbbreviationKey,
                            kCitationVolumeKey,
                            kCitationNumberKey,
                            kCitationPagesKey,
                            kCitationBookTitleKey,
                            kCitationBookLengthKey,
                            kCitationPublisherKey,
                            kCitationPublicationPlaceKey,
                            kCitationPublicationDateKey,
                            kCitationEPubDateKey,
                            kCitationDatabaseIDsKey
                            ]) {
        
        [self setValue:[theDictionary objectForKey:key] forKey:key];
        
    }
    
    // need to unpack authors and editors separately
    [correspondingAuthor unpackFromDictionary:[theDictionary objectForKey:kCitationCorrespondingAuthorKey]];


    [authors removeAllObjects];
    NSArray *authorsDictionaryArray = [theDictionary objectForKey:kCitationAuthorsKey];
    for (NSDictionary *authorDictionary in authorsDictionaryArray) {
        BCCitationAuthor *theAuthor = [[BCCitationAuthor alloc] init];
        [theAuthor unpackFromDictionary:authorDictionary];
        [authors addObject:theAuthor];
    }
    
    [editors removeAllObjects];
    NSArray *editorsDictionaryArray = [theDictionary objectForKey:kCitationEditorsKey];
    for (NSDictionary *editorDictionary in editorsDictionaryArray) {
        BCCitationAuthor *theEditor = [[BCCitationAuthor alloc] init];
        [theEditor unpackFromDictionary:editorDictionary];
        [authors addObject:theEditor];
    }
}


@end
