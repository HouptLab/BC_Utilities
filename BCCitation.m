//
//  BCCitation.m
//  Xynk
//
//  Created by Tom Houpt on 15/2/25.
//
//


#import <AppKit/AppKit.h>
#import "BCCitation.h"
#import "BCCitationAuthor.h"
#import "BCAuthor.h"
#import "BCPubmedParser.h"
#import "BCDictionaryExtensions.h"
#import "BCXMLElement.h"
#import "FMDB.h"


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
        
        pmidToParse = -1;
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
    
    pmidToParse = -1; // use as flag to indicate we have real citation...

    [self setFieldsFromPubMedXMLDictionary:[parser xmlDictionary]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBCCitationEditedNotification
                                                        object:self
                                                      userInfo:@{@"sender":self}
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
        if (nil == [self valueForKey:key]) {
            if ([key isEqualToString:kCitationEPubDateKey] || [key isEqualToString:kCitationPublicationDateKey]) {
                 [self setValue:[NSDate date] forKey:key];
            }
            else {
                [self setValue:[NSString string] forKey:key];
            }
        }
        
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
    
    [self bibtex_yaml];
}

-(NSString *)citeKey; {
    
    if (pmidToParse == -1){
        return [super citeKey];
    }
    
    NSString *ck = [NSString stringWithFormat:@"PMID: %ld",pmidToParse];
    return ck;
}

-(BOOL)citekeyReverseLookup:(NSString *)theCitekey fromLibraryFolder:(NSString *)libraryPath; {

//  NOTE: need to pass database path into method, instead of hardcoding
//  NOTE: need to add error parameter, to indicate db not opened vs. citekey not found
// NOTE: need to make sure this works with either papers2 or papers3
    
    // use sqlitebrowser to look at papers database
    
    NSString *databasePath = [NSString stringWithFormat:@"%@/Library.papers2/Database.papersdb",libraryPath ];
    FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
    
    if (![db open]) {
        return NO;
    }
    
    // citekey = @"author:YYYYzz"
    
    NSArray *keyComponents = [theCitekey componentsSeparatedByString:@":"];
    NSString *citekeyAuthor = [keyComponents firstObject];
    NSInteger citekeyYear = [[[keyComponents lastObject] substringWithRange:NSMakeRange(0,4)] integerValue];
    NSString *citekeyHash = [[keyComponents lastObject] substringFromIndex:4];
    
// PAPERS_DATE_FIELD 99YYYYMMDD0000 0000 0000 0000

#define PAPERS_YEAR_FIELD_FORMAT @"99\%lu"
    
    NSString *citekeyYearField = [NSString stringWithFormat:PAPERS_YEAR_FIELD_FORMAT,citekeyYear];

    // retrieve all citations from Papers database that have matching author and year
    NSString *queryString;

    queryString = [NSString stringWithFormat:@"SELECT title, doi, uuid FROM Publication WHERE citekey_base = '%@' AND publication_date LIKE '%@%%'", citekeyAuthor,citekeyYearField];

    FMResultSet *candidates = [db executeQuery:queryString];
    
    NSString *citekeyUUID = nil;
    NSString *doi = nil;
    NSString *title = nil;
    
    while ([candidates next]) {
        
        citekeyUUID = [candidates stringForColumnIndex:2];
        doi = [candidates stringForColumnIndex:1];

        if (nil != doi) {
            NSString *doiHash = [self doiHash:doi];
            if ([citekeyHash isEqualToString:doiHash]) {
                break;
            }
        }
        
        title = [candidates stringForColumnIndex:0];
        if (nil != title) {
            NSString *titleHash = [self titleHash:title];
            if ([citekeyHash isEqualToString:titleHash]) {
                break;
            }
        }
    }
    
    if (nil == citekeyUUID) { return NO;} // failed to find matching paper
    
    
    NSString *bundle;
    
    //retrieve the matching publication
    queryString = [NSString stringWithFormat:@"SELECT * FROM Publication WHERE uuid = '%@'", citekeyUUID];
    
    FMResultSet *citekeyPaper = [db executeQuery:queryString];
    
     while ([citekeyPaper next]) {
         
         // NOTE: need to add fields for book and book chapter
         
         self.firstAuthor = [citekeyPaper stringForColumn:@"citekey_base"];
         if (nil == self.firstAuthor) {
             self.firstAuthor = [NSString stringWithFormat:@"Anonymous%ld",globalAnonCitationCount ];
             globalAnonCitationCount++;
         }

         self.title = [citekeyPaper stringForColumn:@"title" ];
         if (nil == self.title) { self.title = @"Untitled"; }

         self.publicationYear = [[[citekeyPaper stringForColumn:@"publication_date"] substringWithRange:NSMakeRange(2,4)] integerValue];
         
         self.doi = [citekeyPaper stringForColumn:@"doi" ];
         if (nil == self.doi) { self.doi = [NSString string]; }
         
         NSString   *full_authors = [citekeyPaper stringForColumn:@"full_author_string" ];
         // NOTE: need to split this up into individual authors & parse
         
         /* example author strings */
         /*
         S Hu, L M Willoughby, J J Lagomarsino, and H A Jaeger
         C Del Seppia, P Luschi, S Ghione, E Crosio, E Choleris, and F Papi
         Mita Patel, Robert A Williamsom, Samuel Dorevitch, and Susan Buchanan
         Ian C Atkinson, Laura Renteria, Holly Burd, Neil H Pliskin, and Keith R Thulborn
         B J Gao, M D Bird, S Bole, Y M Eyssa, and H-J Scheider-Muntau
         Belen Hurle, Elena Ignatova, Silvia M Massironi, Tomoji Mashimo, Xavier Rios, Isolde Thalmann, Ruediger Thalmann, and David M Ornitz
         M I Miranda, A M Löpez-Colomé, and F Bermúdez-Rattoni
         M E Saladin, W N Ten Have, Z L Saper, J S Labinsky, and R W Tait
         */
         
         NSString   *full_editors = [citekeyPaper stringForColumn:@"full_editor_string" ];

         
         // need to look up journal based on row with ROWID bundle
         bundle = [citekeyPaper stringForColumn:@"bundle" ];
         
         self.volume = [citekeyPaper stringForColumn:@"volume" ];
         if (nil == self.volume) { self.volume = [NSString string]; }

         self.number = [citekeyPaper stringForColumn:@"number" ];
         if (nil == self.number) { self.number = [NSString string]; }

         
         NSString   *startPage = [citekeyPaper stringForColumn:@"startpage" ];
         if (nil == startPage) { startPage = [NSString string]; }

         NSString   *endPage = [citekeyPaper stringForColumn:@"endpage" ];
         if (nil == endPage) { endPage = [NSString string]; }
         
         if (nil == startPage && nil == endPage) { self.pages = [NSString string]; }
         else {self.pages = [NSString stringWithFormat:@"%@-%@",startPage,endPage ];}
         
         NSString *bundleString = [citekeyPaper stringForColumn:@"bundle-string" ];
         if (nil == bundleString) { bundleString = [NSString string]; }

         
     }
    
    //retrieve the matching publication
    queryString = [NSString stringWithFormat:@"SELECT * FROM Publication WHERE rowid = '%@'", bundle];
    
    FMResultSet *citekeyPublication = [db executeQuery:queryString];
    
    while ([citekeyPublication next]) {
        

    self.journal = [citekeyPublication stringForColumn:@"attributed_title" ];
    if (nil == self.journal) { self.journal = [NSString string]; }
    
    self.journalAbbreviation = [citekeyPublication stringForColumn:@"abbreviation" ];
    if (nil == self.journalAbbreviation) { self.journalAbbreviation = [NSString string]; }
    }


    [db close];
    
    return YES;

}

-(NSString *)pmid; {
    
    NSString *pmid = [self ascensionForDatabase:@"pubmed"];
    if (nil == pmid) {
        return @"--";
    }
    return pmid;
}

-(NSString *)bibtex_yaml; {
    
    NSMutableString *yaml = [NSMutableString string];
    
    [yaml appendString:[self yamlStringAtLevel: 2 withKey:@"id" andValue:[self citeKey] asArrayObject:YES]];

    
    if  (0 < [authors count]) {
        
        [yaml appendString:[self yamlStringAtLevel: 2 withKey:@"author" andValue:nil asArrayObject:NO]];

        for ( BCAuthor *anAuthor in authors) {
            
            [yaml appendString:[self yamlStringAtLevel: 3 withKey:@"family" andValue:[anAuthor indexName] asArrayObject:YES]];
            [yaml appendString:[self yamlStringAtLevel: 3 withKey:@"given" andValue:[anAuthor initials] asArrayObject:NO]];
            
            if ( [anAuthor orcid] && 0 != [(NSString *)[anAuthor orcid] length]) {
                [yaml appendString:[self yamlStringAtLevel: 3 withKey:@"orcid" andValue:[anAuthor orcid] asArrayObject:NO]];
            }
        }
    }
    
    [yaml appendString:[self yamlStringAtLevel: 2 withKey:@"title" andValue:self.title asArrayObject:NO]];
 

    [yaml appendString:[self yamlStringAtLevel: 2 withKey:@"issued" andValue:nil asArrayObject:NO]];
        [yaml appendString:[self yamlStringAtLevel: 3 withKey:@"year" andValue:[self publicationYearString] asArrayObject:NO]];


     [yaml appendString:[self yamlStringAtLevel: 2 withKey:@"type" andValue:@"article-journal" asArrayObject:NO]];
    
     [yaml appendString:[self yamlStringAtLevel: 2 withKey:@"container-title" andValue:self.title asArrayObject:NO]];
    
    [yaml appendString:[self yamlStringAtLevel: 2 withKey:@"volume" andValue:volume asArrayObject:NO]];

    [yaml appendString:[self yamlStringAtLevel: 2 withKey:@"pages" andValue:pages asArrayObject:NO]];

    
    
    return yaml;
}

-(NSString *)publicationYearString; {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    return [dateFormatter stringFromDate:publicationDate];
}


#define kIndentSpaces 6

-(NSString *)yamlStringAtLevel:(NSInteger)level withKey:(NSString *)key andValue:(NSString *)value asArrayObject:(BOOL)flag; {
    
    
    NSInteger spaces = level * kIndentSpaces;
    
    NSString *prefix = @"";
    if (flag) {
        prefix = @"- "; 
        spaces -=2;
    }
    
    
    NSString *indent = [[NSString string] stringByPaddingToLength:spaces withString:@" " startingAtIndex:0];
    
    NSString *yaml;
    if (nil != value && 0 != [value length]  ) {
     yaml = [NSString stringWithFormat:@"%@%@%@: \"%@\"\n",indent,prefix,key,value];
    }
    else {
         yaml = [NSString stringWithFormat:@"%@%@%@:\n",indent,prefix,key];
        
    }
    
    
    return yaml;

    
}

@end
