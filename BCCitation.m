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

@synthesize bookTitle;
@synthesize bookLength;
@synthesize editors;
@synthesize publisher;
@synthesize publicationPlace;
@synthesize ePubDate;

@synthesize publicationDate;
@synthesize databaseIDs;

-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d; {
    
    self = [super initWithAuthor:a title:t year:y doi:d];
    
    if (self) {
        
        authors = [NSMutableArray array];
        editors = [NSMutableArray array];
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
    
//    NSInteger currentYear = [[[NSCalendar currentCalendar]
//      components:NSCalendarUnitYear fromDate:[NSDate date]]
//     year];
//    self = [super initWithAuthor:nil title:nil year:currentYear doi:nil];
    
    self = [super init];

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

-(void)setFieldsFromPubMedDictionary:(NSDictionary *)rootDictionary; {
    
    NSDictionary *eSummary = [rootDictionary objectForKey:@"eSummaryResult"];
    NSDictionary *docSummarySet = [eSummary objectForKey:@"DocumentSummarySet"];
    NSDictionary *docSummary =  [docSummarySet objectForKey:@"DocumentSummary"];
    
    self.firstAuthor = [docSummary objectForKey:@"SortFirstAuthor"];
    self.title = [docSummary objectForKey:@"Title"];
    NSArray *dateArray = [[docSummary objectForKey:@"PubDate"] componentsSeparatedByString:@" "];
    self.publicationYear = [[dateArray firstObject] integerValue];

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
