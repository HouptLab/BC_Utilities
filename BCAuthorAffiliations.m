//
//  BCAuthorAffiliations.m
//  
//
//  Created by Tom Houpt on 15/10/13.
//
//

#import "BCAuthorAffiliations.h"
#import "BCAuthor.h"


@interface AffNode : NSObject

@property (copy) NSString *token;
@property NSMutableArray *children;
@property NSMutableArray *authors;
@property NSInteger leafNumber;

-(NSInteger)numberOfLeaves;
-(NSString *)stringWithFootNotes:(BOOL)showFootNotes;
@end

@interface BCAuthorAffiliations (private)

@property AffNode *root;

-(void)constructTree;

@end

//---------------------------------------------------------------------
//---------------------------------------------------------------------

@implementation AffNode

-(id)init; {

    self = [super init];
    if (self) {
    
        self.children = [NSMutableArray array];
        self.authors = [NSMutableArray array];
        self.token = nil;
        self.leafNumber = -1;
    }
    
    return self;


}

-(NSInteger)numberOfLeaves; {

    NSInteger sumLeaves = 0;
    
    for (AffNode *child in self.children) {
    
        sumLeaves+= [child numberOfLeaves];
    
    }

    return sumLeaves;
}

-(NSString *)stringWithFootNotes:(BOOL)showFootNotes; {

    NSMutableString *s = [NSMutableString string];
     
    if (nil != self.token) {
        [s appendString:self.token];
        [s appendString:@", "];
    }
    
    
    for (NSInteger i = 0; i < [self.children count]; i++) {
        
        [s appendString:[[self.children objectAtIndex:i] string]];
        
        if (i < ([self.children count] - 1)) {
            [s appendString:@" and "];
        }
    
    }
    
    if (showFootNotes) {
        if (self.leafNumber != -1) {
            [s appendString:[NSString stringWithFormat:@"^%ld^", self.leafNumber]];
        }
    }

    return s;

}

@end

//---------------------------------------------------------------------
//---------------------------------------------------------------------


@implementation BCAuthorAffiliations

-(id)initWithAuthors:(NSArray *)a; {


    self = [super init];
    if (self) {
    
        self.authors = [NSArray arrayWithArray:a];
        
        self.root = nil;

    }

    return self;

}

-(void)constructTree; {

    self.root = [[AffNode alloc] init];

    for (BCAuthor *author in self.authors) {

        NSArray *tokens = [[author affiliation] componentsSeparatedByString:@","];
        
        AffNode *currentNode = self.root;
        
       for (NSString *token in [tokens reverseObjectEnumerator]) {
            
            BOOL hasToken = NO;
            
            for (AffNode *child in [self.root children]) {
                if ([child.token isEqualToString:token]){
                    hasToken = YES;
                    currentNode = child;
                    break;
                }
            }
            
            if (!hasToken) {
                AffNode *newNode = [[AffNode alloc] init];
                newNode.token = token;
                [currentNode.children addObject:newNode];
                currentNode = newNode;
            }
        
        }
        [currentNode.authors addObject:author]; 
        
        currentNode.leafNumber = [self.authors indexOfObject:author] + 1;
                
    }
    
}

-(NSString *)affiliations; {

   if (nil == self.root) { [self constructTree]; }
   
    if ([self.root numberOfLeaves] > 1) {
        return [self.root stringWithFootNotes:YES];
    }

    return [self.root stringWithFootNotes:NO];

}


@end
