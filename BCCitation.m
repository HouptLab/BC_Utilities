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
#define kCitationStartPageKey	@"startPage"
#define kCitationEndPageKey	@"endPage"
#define kCitationBookTitleKey	@"bookTitle"
#define kCitationBookLengthKey	@"bookLength"
#define kCitationEditorsKey	@"editors"
#define kCitationPublisherKey	@"publisher"
#define kCitationPublicationPlaceKey	@"publicationPlace"
#define kCitationPublicationDateKey	@"publicationDate"
#define kCitationDatabaseIDsKey	@"databaseIDs"


@implementation BCCitation

@synthesize correspondingAuthor;
@synthesize citationType;
@synthesize authors;
@synthesize journal;
@synthesize journalAbbreviation;
@synthesize volume;
@synthesize number;
@synthesize startPage;
@synthesize endPage;

@synthesize bookTitle;
@synthesize bookLength;
@synthesize editors;
@synthesize publisher;
@synthesize publicationPlace;

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
        
        for (NSString *key in @[
                                kCitationJournalKey,
                                kCitationJournalAbbreviationKey,
                                kCitationVolumeKey,
                                kCitationNumberKey,
                                kCitationStartPageKey,
                                kCitationEndPageKey,
                                kCitationBookTitleKey,
                                kCitationBookLengthKey,
                                kCitationPublisherKey,
                                kCitationPublicationPlaceKey,
                                kCitationPublicationDateKey,
                                ]) {
            
            [self setValue:[NSString string] forKey:key];
            
        }
        
    }
 
    return self;
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
                                                           startPage,
                                                           endPage,
                                                           bookTitle,
                                                           bookLength,
                                                           publisher,
                                                           publicationPlace,
                                                           publicationDate,
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
                                             kCitationStartPageKey,
                                             kCitationEndPageKey,
                                             kCitationBookTitleKey,
                                             kCitationBookLengthKey,
                                             kCitationPublisherKey,
                                             kCitationPublicationPlaceKey,
                                             kCitationPublicationDateKey,
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
                            kCitationStartPageKey,
                            kCitationEndPageKey,
                            kCitationBookTitleKey,
                            kCitationBookLengthKey,
                            kCitationPublisherKey,
                            kCitationPublicationPlaceKey,
                            kCitationPublicationDateKey,
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
