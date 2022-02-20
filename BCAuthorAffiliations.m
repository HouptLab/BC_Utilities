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
@property AffNode *parent;
@property NSMutableArray *children;
@property NSMutableArray *authors;
@property NSInteger leafNumber;

-(NSInteger)numberOfLeaves;
-(NSString *)stringWithFootNotes:(BOOL)showFootNotes;
-(NSInteger)footnoteForAuthor:(BCAuthor *)author;

@end

@interface BCAuthorAffiliations (private)


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
        self.parent = nil;
        self.leafNumber = -1;
    }
    
    return self;


}

-(NSInteger)numberOfLeaves; {

    
    if (0 == [self.children count]) { return 1; }
    
    NSInteger sumLeaves = 0;
    
    for (AffNode *child in self.children) {
    
        sumLeaves+= [child numberOfLeaves];
    
    }

    return sumLeaves;
}

-(NSString *)stringWithFootNotes:(BOOL)showFootNotes; {

    NSMutableString *s = [NSMutableString string];
     
    if (nil != self.token) {
        if (showFootNotes) {
            if (self.leafNumber != -1) {
                if (self.leafNumber > 1 ) {
                     [s appendString:@" and "];
                }
                [s appendString:[NSString stringWithFormat:@"^%ld^", self.leafNumber]];
            }
        }
        [s appendString:self.token];
        [s appendString:@","];
    }
    
   
    
    for (NSInteger i = [self.children count] - 1; i >= 0; i--) {
        
//       if (1 < [self.children count] 
//            && ([self.children count] - 1) == i
//            && self.parent.parent == nil) {
//            [s appendString:@"and "];
//        }
         [s appendString:[[self.children objectAtIndex:i] stringWithFootNotes:showFootNotes]];
    }
    
   

    return s;

}


-(NSInteger)footnoteForAuthor:(BCAuthor *)author; {


    if ([self.authors containsObject:author]) {
        return self.leafNumber;
    }
    for (AffNode *child in self.children) {
    
        NSInteger authorleaf = [child footnoteForAuthor:author];
        if (-1 != authorleaf) { return authorleaf; }
    }
    
    return -1;

}

@end

//---------------------------------------------------------------------
//---------------------------------------------------------------------


@implementation BCAuthorAffiliations


-(id)initWithAuthors:(NSArray *)a; {


    self = [super init];
    if (self) {
    
        self.authors = [NSArray arrayWithArray:a];
        

    }

    return self;

}

-(void)constructTree; {

    self.affroot = [[AffNode alloc] init];
    self.currentLeafNumber = 1;

    for (BCAuthor *author in self.authors) {

        NSArray *tokens = [[author affiliation] componentsSeparatedByString:@","];
        
        AffNode *currentNode = self.affroot;
        
       for (NSString *token in [tokens reverseObjectEnumerator]) {
            
            BOOL hasToken = NO;
            
            for (AffNode *child in [currentNode children]) {
                if ([child.token isEqualToString:token]){
                    hasToken = YES;
                    currentNode = child;
                    break;
                }
            }
            
            if (!hasToken) {
                AffNode *newNode = [[AffNode alloc] init];
                newNode.token = token;
                newNode.parent = currentNode;
                [currentNode.children addObject:newNode];
                currentNode = newNode;
            }
        
        }
        [currentNode.authors addObject:author]; 
        
        if (1 == [currentNode.authors count]) {
            currentNode.leafNumber = self.currentLeafNumber;
            self.currentLeafNumber++;
        }
                
    }
    
}

-(NSString *)affiliationsString; {

   if (nil == self.affroot) { [self constructTree]; }
   
   NSString *backwardsString;
    if ([self.affroot numberOfLeaves] > 1) {
       backwardsString = [self.affroot stringWithFootNotes:YES];
    }

    else {
        backwardsString = [self.affroot stringWithFootNotes:NO];
    }
    
    NSArray *backwardsTokenArray = [backwardsString componentsSeparatedByString:@","];
    NSMutableArray *tokenArray = [NSMutableArray array];
    for (NSString *token in [backwardsTokenArray reverseObjectEnumerator]) {
        if (0 < [token length]){ [tokenArray addObject:token]; }
    }
    NSMutableString *affString = [NSMutableString string];
    
    for (NSInteger i = 0; i < [tokenArray count]; i++) {
    
        if (0 != i) {
            if (![[tokenArray objectAtIndex:i] hasPrefix:@"and"]) {
                [affString appendString:@","];
            }
            [affString appendString:@" "];
        }
        
        [affString appendString:[tokenArray objectAtIndex:i]];
 
    }
    
    return affString;
}

-(NSString *)authorsWithFootNotes; {

   if (nil == self.affroot) { [self constructTree]; }


    NSMutableString *authorString = [NSMutableString string];

    for (NSInteger i = 0; i < [self.authors count]; i++) {
    
        BCAuthor *author = [self.authors objectAtIndex:i];
        
        if (i != 0 ){
        
            if ( i == [self.authors count] - 1) {
                [authorString appendString:@" and "];
            }
            else {
                [authorString appendString:@", "];
            }
        }
    
        NSInteger footnote = [self footnoteForAuthor:author];
    
        if (-1 == footnote) {
            [authorString appendString:[author fullName]];
        }
        else {
            [authorString appendString:[NSString stringWithFormat:@"%@^%ld^",[author fullName],footnote]];
        }
        
        
    
    }
    
    return authorString;

}

-(NSInteger)footnoteForAuthor:(BCAuthor *)author; {

    if ([self.affroot numberOfLeaves] <= 1) { return -1; }
    
    return [self.affroot footnoteForAuthor:author];

}

@end
