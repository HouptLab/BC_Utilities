//
//  BCCitation.m
//  Xynk
//
//  Created by Tom Houpt on 15/2/23.
//
//

#import "BCCitation.h"


@interface BCCitation (Private)

-(void)setFirstAuthor:(NSString *)firstAuthor;
-(void)setDoi:(NSString *)doi;
-(void)setTitle:(NSString *)title  ;
-(void)setPublicationYear:(NSInteger)publicationYear;
-(void)updateCiteKey;


@end


@implementation BCCitation

@synthesize doi;
@synthesize firstAuthor;
@synthesize title;
@synthesize publicationYear;


@synthesize titleCiteKey;
@synthesize doiCiteKey;
@synthesize authors;
@synthesize journal;
@synthesize volume;
@synthesize number;
@synthesize startPage;
@synthesize endPage;
@synthesize publicationDate;
@synthesize databaseIDs;

-(id)init; {
    
    NSInteger currentYear =  [[[NSCalendar currentCalendar]
                               components:NSCalendarUnitYear fromDate:[NSDate date]]
                              year];
    
    return [self initWithAuthor:nil title:nil year:currentYear doi:nil];
}
-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d; {
    
    self = [super init];
    if (self) {
        if (nil != a) { firstAuthor = [a copy]; }
        if (nil != t) { title = [t copy]; }
        if (nil != d) { doi = [d copy]; }
        publicationYear = y;
        [self updateCiteKey];
        
        databaseIDs = [NSMutableDictionary dictionary];
    }
    
    return self;
}
-(NSString *)citeKey; {
    
    if (nil != doiCiteKey) {
        return doiCiteKey;
    }
    if (nil != titleCiteKey) {
        return titleCiteKey;
    }
    return nil;
}

-(NSString *)ascensionForDatabase:(NSString *)database; {
    
    if (nil == database) { return nil; }
    return [databaseIDs valueForKey:database];
}

-(void)setAscension:(NSString *)a forDatabase:(NSString *)database; {
    
    if (nil != a) {
        [databaseIDs setValue:a forKey:database];
    }
    
}

-(void)setFirstAuthor:(NSString *)a; {
    if (a!=nil) {
        firstAuthor = [a copy];
    }
    else {
        firstAuthor = nil;
    }
    [self updateCiteKey];
}
-(void)setDoi:(NSString *)d;{
    if (d!=nil) {
        doi = [d copy];
    }
    else {
        doi = nil;
    }
    [self updateCiteKey];

    
}
-(void)setTitle:(NSString *)t;{
    if (t!=nil) {
        title = [t copy];
    }
    else {
        title = nil;
    }
    [self updateCiteKey];

}
-(void)setPublicationYear:(NSInteger)y;{
    publicationYear = y;
    [self updateCiteKey];

}
-(void)updateCiteKey;{
    
}

@end
