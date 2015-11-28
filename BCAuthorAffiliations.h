//
//  BCAuthorAffiliations.h
//  
//
//  Created by Tom Houpt on 15/10/13.
//
//

#import <Foundation/Foundation.h>

@interface BCAuthorAffiliations : NSObject

@property NSArray *authors;

-(id)initWithAuthors:(NSArray *)a; 
-(NSString *)affiliations;
-(NSString *)authorsWithFootNotes;
-(NSArray *)authorFootNoteNumbers;

@end
