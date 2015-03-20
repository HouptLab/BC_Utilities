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
#import "BCXMLElement.h"

#define kCitationFirstAuthorKey	@"firstAuthor"
#define kCitationTitleKey	@"title"
#define kCitationDOIKey	@"doi"
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
    
    // remember our current citeKey
    self.oldCiteKey = [self citeKey];

    [self setFieldsFromPubMedXMLDictionary:[parser xmlDictionary]];
    
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
#define kELocationPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/ELocationID"
#define kAbstractPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Abstract/AbstractText"
#define kAuthorListPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/Article/AuthorList"
#define kKeywordListPath @"PubmedArticleSet/PubmedArticle/MedlineCitation/KeywordList"
#define kArticleIDPath @"PubmedArticleSet/PubmedArticle/PubmedData/ArticleIdList"

-(void)setFieldsFromPubMedXMLDictionary:(BCXMLElement *)rootElement; {
    
    BCXMLElement *theElement;
    
    theElement = [rootElement elementAtKeyPath:kTitlePath];
    if (nil != theElement) { self.title = theElement.string; }
    
    theElement = [rootElement elementAtKeyPath:kPublicationYearPath];
    if (nil != theElement) { self.publicationYear = [theElement.string integerValue]; }

    theElement = [rootElement elementAtKeyPath:kJournalTitlePath];
    if (nil != theElement) { self.journal = theElement.string; }
    
    theElement = [rootElement elementAtKeyPath:kJournalAbbreviationPath];
    if (nil != theElement) { self.journalAbbreviation = theElement.string; }
    
    theElement = [rootElement elementAtKeyPath:kJournalVolumePath];
    if (nil != theElement) { self.volume = theElement.string; }
    
    theElement = [rootElement elementAtKeyPath:kJournalIssuePath];
    if (nil != theElement) { self.number = theElement.string; }
    
    theElement = [rootElement elementAtKeyPath:kJournalISSNPath];
    if (nil != theElement) { self.issn = theElement.string; }
    
    theElement = [rootElement elementAtKeyPath:kPagesPath];
    if (nil != theElement) { self.pages = theElement.string; }
    
    // NOTE: currently just read (last) <AbstractText>, but really need to
    // to reconstruct from multiple <AbstractText Label = "...">
    theElement = [rootElement elementAtKeyPath:kAbstractPath];
    if (nil != theElement) { self.abstract = theElement.string; }
    
    
    theElement = [rootElement elementAtKeyPath:kELocationPath];
    if (nil != theElement) {
        NSString *eid = [theElement attributeForKey:@"EIdType"];
        if (nil != eid && [eid isEqualToString:@"doi"]) {
            self.doi = theElement.string;
        }
    }
    
    // NOTE: extract publicationDate and ePubDate
    
    
    NSArray *authorList;
    theElement = [rootElement elementAtKeyPath:kAuthorListPath];
    if (nil != theElement) { authorList = theElement.array; }
    
    if (nil != authorList) {
        for (BCXMLElement *author in authorList) {
            BCCitationAuthor *citeAuthor = [[BCCitationAuthor alloc] init];
            [citeAuthor setIndexName: [[author elementForKey:@"LastName"] string] ];
            [citeAuthor setInitials: [[author elementForKey:@"Initials"] string] ];
            [self.authors addObject:citeAuthor];
        }
        
        if (0 < [self.authors count]) {
            self.firstAuthor = [[self.authors firstObject] indexName];
        }
        
        NSString *complete = [theElement  attributeForKey:@"CompleteYN"];
        if ([complete isEqualToString:@"N"]) {
            BCCitationAuthor *citeAuthor = [[BCCitationAuthor alloc] init];
            [citeAuthor setIndexName:@"et al."];
            [self.authors addObject:citeAuthor];
        }
    }
    
    NSArray *keywordList;
    theElement = [rootElement elementAtKeyPath:kKeywordListPath];
    if (nil != theElement) { keywordList = theElement.array; }
    
    if (nil != keywordList) {
         for (BCXMLElement *keywordElement in keywordList) {
             NSString *kw = keywordElement.string;
             [self.keywords addObject:kw];
         }
    }
    
    NSArray *articleIDList;
    theElement = [rootElement elementAtKeyPath:kArticleIDPath];
    if (nil != theElement) {  articleIDList = theElement.array; }
    
    if (nil != articleIDList) {
        for (BCXMLElement *articleID in articleIDList) {
            NSString *database = [articleID attributeForKey:@"IdType"];
            NSString  *ascension = articleID.string;
            [self setAscension:ascension forDatabase:database];            
        }
        
        // check if we need to assign doi
        if (nil == self.doi || 0 == [self.doi length]) {
            NSString  *doiString = [self.databaseIDs objectForKey:@"doi"];
            if (nil != doiString) { self.doi = doiString; }
        }
        
    }


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