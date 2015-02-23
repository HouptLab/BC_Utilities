//
//  BCCitation.h
//  Xynk
//
//  Created by Tom Houpt on 15/2/23.
//
//

#import <Foundation/Foundation.h>

@interface BCCitation : NSObject


/** for generating citeKey
*/
@property (nonatomic) NSString *doi; /// can be nil or empty
@property (nonatomic) NSString *firstAuthor; /// can be nil or empty (will return @"Anonymous")
@property (nonatomic) NSString *title; /// can be nil or empty
@property (nonatomic) NSInteger publicationYear;


@property NSString *titleCiteKey; /// regenerated whenever firstAuthor, title, or publication year is changed; can be nil if no title is provided
@property NSString *doiCiteKey; /// regenerated whenever firstAuthor, doi, or publication year is changed; can be nil if no doi is provided

/** stubs for full citation info
 we use NSStrings because even values expected to be numeric, like volume, 
 might contain non-numeric values (e.g. "supplemental volume 5 b" = "S5b"
*/

@property NSArray *authors;
@property NSString *journal;
@property NSString *volume;
@property NSString *number;
@property NSString *startPage;
@property NSString *endPage;
@property NSDate *publicationDate;
@property NSDictionary *databaseIDs; /// pairs of databaseID as key  and ascension number, e.g. databaseIDs["PMID"] = 314156 ; citation can have 0 or more than one databaseID if represented in multiple databases...
//NOTE: are all ascension numbers numeric?
// e.g., DOI could be considered an ascension number but it has non-numeric characters


-(id)init;

/** author, title , and doi can be nil or empty (white space only), 
    although to generate a citekey the citation should have either a title or a doi
 
    @return newly initialized BCCitation object
 
 */
-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d;


/** returns universal citekey. 
 
    if doi is available, returns doiCiteKey;
    if doi is not available, then titleCiteKey is returned; 
    if citeKey cannot be generated, then returns nil

    @return citeKey or nil if citekey cannot be generated
 
*/
-(NSString *)citeKey;


/** given a database ID string (e.g. @"PMID") return the stored ascension number;
 if no ascension number available, then return -1
 
 @param database a key to identify database, e.g. PMID, PMCID, JSTOR, PSYCHLIT, etc.
 @return ascension number for this citation in given database key
*/
-(NSString *)ascensionForDatabase:(NSString *)database;

@end
