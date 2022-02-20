//
//  BCAuthorAffiliations.h
//  
//
//  Created by Tom Houpt on 15/10/13.
//
//
/**

Author Affiliations

Affiliation is parsed as a tree of affiliation nodes

Affiliation is entered as a sequence of comma-separated tokens, e.g.

3 authors, 3 in Department of Biology, and 1 in Department of Psyschology, but both in Program of Neuroscience at FSU. So last 5 tokens are in common:

[Jones],[Biology], [Program in Neuroscience], [FSU], [Tallahassee], [FL], [USA]
[Smith].[Psychology], [Program in Neuroscience], [FSU], [Tallahassee], [FL], [USA]
[Brown],[Biology], [Program in Neuroscience], [FSU], [Tallahassee], [FL], [USA]

Should be footnoted as:

Jones(1),Smith(2), Brown(1)

[Biology] (1) and [Psychology] (2),[ Program in Neuroscience], [FSU], [Tallahassee], [FL], [USA]


So parse each author and add to a tree from last (most general) token to first (most specific) token. Each token/node of tree has a list of authors who contain that token

                root
                [USA]:Jones,Smith,Brown
                [FL]:Jones,Smith,Brown
                [FSU]:Jones,Smith,Brown
        [Program in Neuroscience]:Jones,Smith,Brown
        
[Biology]:Jones,Brown        [Psychology]:Smith
           leaf # 1                 leaf # 2
           
to find footnote number for an author, we traverse tree from root to leaf along nodes that contain the author; the leafnumber of the final leafnode is the footnote number

 */

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
