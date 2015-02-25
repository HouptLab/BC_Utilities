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
@property (copy) NSString *doi; /// can be nil or empty
@property (copy) NSString *firstAuthor; /// can be nil or empty (will return @"Anonymous")
@property (copy) NSString *title; /// can be nil or empty
@property NSInteger publicationYear;



/** stubs for full citation info
 we use NSStrings because even values expected to be numeric, like volume, 
 might contain non-numeric values (e.g. "supplemental volume 5 b" = "S5b"
*/

@property NSMutableArray *authors;
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


-(id)init;

/** author, title , and doi can be nil or empty (white space only), 
    although to generate a citekey the citation should have either a title or a doi
 
    @return newly initialized BCCitation object
 
 */
-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d;




/** returns universal citekey.
    based on: http://support.mekentosj.com/kb/read-write-cite/universal-citekey
    adapted from javascript code at: https://github.com/cparnot/universal-citekey-js
 
 given an author, year of publication, and title or DOI, generate a Papers style cite key
 
 e.g. @"Smith", 1967, @"Trace conditioning with X-rays as an aversive stimulus"  returns @"Smith:1967tu"
 
 (note that delimitors "{...}" are not included in returned string...)
 
    if doi is available, returns doiCiteKey;
    if doi is not available, then titleCiteKey is returned; 
    if citeKey cannot be generated, then returns nil

    @return citeKey or nil if citekey cannot be generated
 
*/
-(NSString *)citeKey;

/** returns author-year base for citekey, e.g. "Smith1968"
 
 uses firstAuthor (last name of first author), or "Anonymous" if first author not available
 */
-(NSString *)citeKeyBase;

/** returns universal citekey based on doi.
 
 if doi is available, returns doiCiteKey;
 if doi is not available, then then returns nil
 
 @return citeKey based on doi or nil if citekey cannot be generated
 
 */
-(NSString *)doiCiteKey;

/** returns universal citekey based on title.
 
 if title is available, returns titleCitekey;
 if title is not available, then returns nil
 
 @return citeKey based on title or nil if citekey cannot be generated
 
 */
-(NSString *)titleCiteKey;

/** given a database ID string (e.g. @"PMID") return the stored ascension number;
 if no ascension number available, then return -1
 
 @param database a key to identify database, e.g. PMID, PMCID, JSTOR, PSYCHLIT, etc.
 @return ascension number for this citation in given database key
*/
-(NSString *)ascensionForDatabase:(NSString *)database;

@end
