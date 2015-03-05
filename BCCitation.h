//
//  BCCitation.h
//  Xynk
//
//  Created by Tom Houpt on 15/2/25.
//
//

#import "BCCiteKey.h"

@interface BCCitation : BCCiteKey

/** stubs for full citation info
 we use NSStrings because even values expected to be numeric, like volume,
 might contain non-numeric values (e.g. "supplemental volume 5 b" = "S5b"
 */

@property NSMutableArray *authors; /// the author list -- we should probably have a custom author object?
@property (copy) NSString *journal;
@property (copy) NSString *volume;
@property (copy) NSString *number;
@property (copy) NSString *startPage;
@property (copy) NSString *endPage;

@property (copy) NSString *bookTitle;
@property (copy) NSString *bookLength;
@property NSMutableArray *editors;
@property (copy) NSString *publisher;
@property (copy) NSString *publicationPlace;

@property (copy) NSDate *publicationDate;
@property NSMutableDictionary *databaseIDs; /// pairs of databaseID as key  and ascension number, e.g. databaseIDs["PMID"] = 314156 ; citation can have 0 or more than one databaseID if represented in multiple databases...
//NOTE: are all ascension numbers numeric?
// e.g., DOI could be considered an ascension number but it has non-numeric characters

/** author, title , and doi can be nil or empty (white space only),
 although to generate a citekey the citation should have either a title or a doi
 
 @return newly initialized BCCitation object
 
 */
-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d;

/** given a database ID string (e.g. @"PMID") return the stored ascension number/string;
 if no ascension number available, then return -1
 
 // NOTE: should we enable the database to construct well-formed urls, e.g. http://www.ncbi.nlm.nih.gov/pubmed/25711536 for a pubmed id? perhaps maintain an application wide database of database accessors constructors...
 
 @param database a key to identify database, e.g. PMID, PMCID, JSTOR, PSYCHLIT, etc.
 @return ascension number (or link) for this citation in given database key
 */
-(NSString *)ascensionForDatabase:(NSString *)database;


/** store an ascension number/string for the given database ID
 
 No Op. if either ascension or database are nil
 
 @param database n NSString key to identify database, e.g. PMID, PMCID, JSTOR, PSYCHLIT, doi, url, etc.
 
 @param ascension an NSString  containing the ascension number (or link) within the given database
 
 */
-(void)setAscension:(NSString *)ascension forDatabase:(NSString *)database;


@end
