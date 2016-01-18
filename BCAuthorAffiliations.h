//
//  BCAuthorAffiliations.h
//  
//
//  Created by Tom Houpt on 15/10/13.
//
//

#import <Foundation/Foundation.h>

@class AffNode;
@class BCAuthor;

@interface BCAuthorAffiliations : NSObject

@property NSArray *authors;
@property AffNode *affroot;
@property NSInteger currentLeafNumber;

-(id)initWithAuthors:(NSArray *)a; 
-(NSString *)affiliationsString;
-(NSString *)authorsWithFootNotes;
/** return -1 for no footnotes, or foot notes not found 
*/
-(NSInteger)footnoteForAuthor:(BCAuthor *)author;
@end
