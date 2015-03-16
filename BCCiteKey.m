//
//  BCCiteKey.m
//  Xynk
//
//  Created by Tom Houpt on 15/2/23.
//
//

#import "BCCiteKey.h"
#import "BCStringExtensions.h"



@implementation BCCiteKey

@synthesize doi;
@synthesize firstAuthor;
@synthesize title;
@synthesize publicationYear;

-(id)init; {
    
    NSInteger currentYear =  [[[NSCalendar currentCalendar]
                               components:NSCalendarUnitYear fromDate:[NSDate date]]
                              year];
    
    return [self initWithAuthor:@"Houpt" title:@"Productivity gain from use of a manuscript IDE" year:currentYear doi:nil];
}
-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d; {
    
    self = [super init];
    if (self) {
        
        if (nil != a) { self.firstAuthor = a; }
        else {  self.firstAuthor = [NSString string]; }
        
        if (nil != t) { self.title = t; }
        else {  self.title = [NSString string]; }

        if (nil != d) { self.doi = d; }
        else {  self.doi = [NSString string]; }

        publicationYear = y;

    }
    
    return self;
}

-(NSString *)citeKeyBase; {
    
    // if no author name provided, use "Anonymous"
    // otherwise, use canonical form of author name, and replace white space with dashes
    
    NSString *author_name;
    if (nil == firstAuthor || 0 == [firstAuthor length]) {
        author_name = @"Anonymous";
    }
    else {
        // replace multiple whitespace with single whitespace
        
        NSString *authorWithWhiteSpaceCompressed = [firstAuthor stringByReplacingOccurrencesOfString:@"\\s+"
                                                                                          withString:@" "
                                                                                             options:NSRegularExpressionSearch
                                                                                               range:NSMakeRange(0, firstAuthor.length)];
        
        NSString *trimmedAuthor = [authorWithWhiteSpaceCompressed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        author_name = [[trimmedAuthor decomposedStringWithCanonicalMapping] stringWithDashesForWhiteSpace];
    }
    NSString *citeKeyBase = [NSString stringWithFormat:@"%@:%ld",author_name,(long)publicationYear];
    
    return citeKeyBase;
}

-(NSString *)doiCiteKey; {
    
    NSString * ucDoi;
    if (nil == doi || 0 == [doi length]) {
        // nil string if no doi provided
        ucDoi = nil;
    }
    else {
        // need to confirm that crc32 uses same table as Papers citekey
        UInt32 crcDoi = [doi crc32];
        char doiHash1 = 'b' + (char)floor((crcDoi % (10 * 26))/26);
        char doiHash2 = 'a' + (char)(crcDoi % 26);
        ucDoi = [NSString stringWithFormat:@"%@%c%c",[self citeKeyBase],doiHash1,doiHash2];
    }

    return ucDoi;
}
-(NSString *)titleCiteKey; {
    
    NSString * ucTitle;
    if (nil == title || 0 == [title length]) {
        // nil string if no doi provided
        ucTitle = nil;
    }
    else {
        // convert strings to "canonical form"
        // see http://unicode.org/reports/tr15/
        // see http://www.objc.io/issue-9/unicode.html
        // I think Papers citekey uses equivalent of [NSString decomposed​String​With​Canonical​Mapping]
        // and not precomposedStringWithCanonicalMapping
        
        // replace multiple whitespace with single whitespace
        
        NSString *titleWithWhiteSpaceCompressed = [title stringByReplacingOccurrencesOfString:@"\\s+"
                                                                                   withString:@" "
                                                                                      options:NSRegularExpressionSearch
                                                                                        range:NSMakeRange(0, title.length)];
        
        NSString *trimmedTitle = [titleWithWhiteSpaceCompressed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // get canonical version
        NSString *canonicalTitle = [[trimmedTitle  lowercaseString] decomposedStringWithCanonicalMapping];
        UInt32 crcTitle = [canonicalTitle crc32];
        char titleHash1 = 't' + (char)floor((crcTitle % (4 * 26))/26);
        char titleHash2 = 'a' + (char)(crcTitle % 26);
        ucTitle = [NSString stringWithFormat:@"%@%c%c",[self citeKeyBase],titleHash1,titleHash2];
    }
    
    return ucTitle;
}

-(NSString *)citeKey; {
    
    NSString *citeKey = [self doiCiteKey];
    if (nil == citeKey) {
        citeKey =  [self titleCiteKey];
    }
    return citeKey;
}




@end
