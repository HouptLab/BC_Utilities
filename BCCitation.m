//
//  BCCitation.m
//  Xynk
//
//  Created by Tom Houpt on 15/2/25.
//
//

#import "BCCitation.h"

@implementation BCCitation

@synthesize authors;
@synthesize journal;
@synthesize volume;
@synthesize number;
@synthesize startPage;
@synthesize endPage;

@synthesize bookTitle;
@synthesize bookLength;
@synthesize editors;
@synthesize publisher;
@synthesize publicationPlace;

@synthesize publicationDate;
@synthesize databaseIDs;

-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d; {
    
    self = [super initWithAuthor:a title:t year:y doi:d];
    
    if (self) {
        
        authors = [NSMutableArray array];
        databaseIDs = [NSMutableDictionary dictionary];
    }
 
    return self;
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

@end
