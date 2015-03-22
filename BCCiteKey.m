//
//  BCCiteKey.m
//  Xynk
//
//  Created by Tom Houpt on 15/2/23.
//
//

#import "BCCiteKey.h"
#import "BCStringExtensions.h"

 NSInteger globalAnonCitationCount = 0;

@implementation BCCiteKey

@synthesize doi;
@synthesize firstAuthor;
@synthesize title;
@synthesize publicationYear;

@synthesize oldCiteKey;
@synthesize hasBeenDeleted;


-(id)init; {
    return [self initWithAuthor:@"Anonymous" title:@"Untitled" year:-1 doi:nil];
}
-(id)initWithAuthor:(NSString *)a title:(NSString *)t year:(NSInteger)y doi:(NSString *)d; {
    
    self = [super init];
    if (self) {
        
        if (nil != a) { self.firstAuthor = a; }
        else {  self.firstAuthor = [NSString stringWithFormat:@"Anonymous%ld",globalAnonCitationCount];
            globalAnonCitationCount++;
        }
        
        if (nil != t) { self.title = t; }
        else {  self.title = @"Untitled"; }

        if (nil != d) { self.doi = d; }
        else {  self.doi = [NSString string]; }
        
        if (y != -1) {
            publicationYear = y;
        }
        else {
           publicationYear =  [[[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear fromDate:[NSDate date]]
                                      year];
        }
        

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
        
        NSString *doiHash = [self doiHash:doi];

        ucDoi = [NSString stringWithFormat:@"%@%@",[self citeKeyBase],doiHash];
    }

    return ucDoi;
}

-(NSString *)doiHash:(NSString *)theDoi; {
    
    // need to confirm that crc32 uses same table as Papers citekey
    UInt32 crcDoi = [theDoi crc32];
    char doiHash1 = 'b' + (char)floor((crcDoi % (10 * 26))/26);
    char doiHash2 = 'a' + (char)(crcDoi % 26);
    return [NSString stringWithFormat:@"%c%c",doiHash1,doiHash2];
}


-(NSString *)titleCiteKey; {
    
    NSString * ucTitle;
    if (nil == title || 0 == [title length]) {
        // nil string if no doi provided
        ucTitle = nil;
    }
    else {
 
        
        NSString *titleHash = [self titleHash:title];
        ucTitle = [NSString stringWithFormat:@"%@%@",[self citeKeyBase],titleHash];
    }
    
    return ucTitle;
}

-(NSString *)titleHash:(NSString *)theTitle; {
    
    //  remove excluded characters
    //  var excluded_characters = "±˙˜´‘’‛“”‟·•!¿¡#∞£¥$%‰&˝¨ˆ¯˘¸˛^~√∫*§◊¬¶†‡≤≥÷:ªº\"\'©®™";
    
    //  replace characters with a space
    //  var replaced_characetrs = "°˚+-–—_…,.;ı(){}‹›<>«=≈?|/\\";
    
    // replace multiple whitespace with single whitespace
    
    // convert strings to "canonical form"
    // see http://unicode.org/reports/tr15/
    // see http://www.objc.io/issue-9/unicode.html
    // I think Papers citekey uses equivalent of [NSString decomposed​String​With​Canonical​Mapping]
    // and not precomposedStringWithCanonicalMapping

    
#define excluded_characters_set @"±˙˜´‘’‛“”‟·•!¿¡#∞£¥$%‰&˝¨ˆ¯˘¸˛^~√∫*§◊¬¶†‡≤≥÷:ªº\"\'©®™"
#define replaced_characters_set @"°˚+-–—_…,.;ı(){}‹›<>«=≈?|/\\"
    
    NSCharacterSet *excludeCharactersSet  = [NSCharacterSet characterSetWithCharactersInString:excluded_characters_set ];
    NSCharacterSet *replaceCharactersSet  = [NSCharacterSet characterSetWithCharactersInString:replaced_characters_set ];

    NSString *excludedString = [[theTitle componentsSeparatedByCharactersInSet:excludeCharactersSet] componentsJoinedByString:@""];
    
    NSString *replacedString = [[excludedString componentsSeparatedByCharactersInSet:replaceCharactersSet] componentsJoinedByString:@" "];
    
    NSString *titleWithWhiteSpaceCompressed = [replacedString stringByReplacingOccurrencesOfString:@"\\s+"
                                                                               withString:@" "
                                                                                  options:NSRegularExpressionSearch
                                                                                    range:NSMakeRange(0, replacedString.length)];
    
    NSString *trimmedTitle = [titleWithWhiteSpaceCompressed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // get canonical version
    NSString *canonicalTitle = [[trimmedTitle  lowercaseString] decomposedStringWithCanonicalMapping];
    UInt32 crcTitle = [canonicalTitle crc32];
    char titleHash1 = 't' + (char)floor((crcTitle % (4 * 26))/26);
    char titleHash2 = 'a' + (char)(crcTitle % 26);
    
    return [NSString stringWithFormat:@"%c%c",titleHash1,titleHash2];
    
}


-(NSString *)citeKey; {
    
    NSString *citeKey = [self doiCiteKey];
    if (nil == citeKey) {
        citeKey =  [self titleCiteKey];
    }
    return citeKey;
}

-(NSString *)citeKeyInBrackets; {
    
    return [NSString stringWithFormat:@"{%@}",self.citeKey];
    
}




@end
