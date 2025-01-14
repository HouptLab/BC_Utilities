//
//  BCCiteKey.h
//  Xynk
//
//  Created by Tom Houpt on 15/2/23.
//
//

#import <Foundation/Foundation.h>

#define BCCiteKeyPBoardType @"BCCiteKeyPBoardType"
#define BCCiteKeyCellPBoardType @"BCCiteKeyCellPBoardType"

// NOTE: probably need to revise regex to work with unicode or other characters in authors name..
/** match citeKeys of form "{<author-name>:YYYYaa}"
 (make sure to escape the backslashes to escape the curly brackets!)
*/
#define citeKeyRegexString @"\\{[A-Za-z-]+:[0-9]{4,4}[a-z]{2,2}\\}"

 extern  NSInteger globalAnonCitationCount;


@interface BCCiteKey : NSObject


/** for generating citeKey
*/
@property (copy) NSString *doi; /// can be nil or empty
@property (copy) NSString *firstAuthor; /// can be nil or empty (will return @"Anonymous")
@property (copy) NSString *title; /// can be nil or empty
@property NSInteger publicationYear; /// parse bibtex year to integer

/**
  Editing Properties
 */
@property (copy) NSString *oldCiteKey; /// for updating old citekeys

@property BOOL hasBeenDeleted; /// YES if result of editing operation is that we should be deleted -- used to signal that citekeys in text should be deleted...


-(id)init;

/** author, title , and doi can be nil or empty (white space only), 
    although to generate a citekey the citation should have either a title or a doi
 
    year can be -1, in which case current year is inserted
 
 
    @return newly initialized BCCiteKey object
 
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

/** return @"{<citekey>}"
 
*/
-(NSString *)citeKeyInBrackets;



/** returns author-year base for citekey, e.g. "Smith:1968"
 
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

-(NSString *)doiHash:(NSString *)theDoi;
-(NSString *)titleHash:(NSString *)theTitle;

@end
