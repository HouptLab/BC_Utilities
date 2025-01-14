//
//  BCAuthor.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/13.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCAuthor.h"

@implementation BCAuthor

@synthesize indexName;
@synthesize initials;
@synthesize orcid;
@synthesize contribution;
@synthesize position;
@synthesize prefix;
@synthesize fullName;
@synthesize degrees;
@synthesize informal;
@synthesize affiliation;
@synthesize address;
@synthesize phone;
@synthesize fax;
@synthesize email;
@synthesize website;
@synthesize hasBeenDeleted;

-(id)init; {
    
    self = [super init];
    
    if (self) {
        
        indexName = @"Anonymous";
        
        for (NSString *key in @[
                                kAuthorInitialsKey,
                                kAuthorOrcidKey,
                                kAuthorContributionKey,
                                kAuthorPositionKey,
                                kAuthorPrefixKey,
                                kAuthorFullNameKey,
                                kAuthorDegreesKey,
                                kAuthorInformalKey,
                                kAuthorAffiliationKey,
                                kAuthorAddressKey,
                                kAuthorPhoneKey,
                                kAuthorFaxKey,
                                kAuthorEmailKey,
                                kAuthorWebsiteKey
                                ]) {
            
            [self setValue:[NSString string] forKey:key];
            
        }

        
    }
    
    return self;
}

-(NSDictionary *)packIntoDictionary; {
    
    NSDictionary *theDictionary = [NSDictionary
                     dictionaryWithObjects:@[
                               indexName,
                               initials,
                               orcid,
                               contribution,
                               position,
                               prefix,
                               fullName,
                               degrees,
                               informal,
                               affiliation,
                               address,
                               phone,
                               fax,
                               email,
                               website
                                   ]
                        forKeys:@[
                                 kAuthorIndexNameKey,
                                 kAuthorInitialsKey,
                                 kAuthorOrcidKey,
                                 kAuthorContributionKey,
                                 kAuthorPositionKey,
                                 kAuthorPrefixKey,
                                 kAuthorFullNameKey,
                                 kAuthorDegreesKey,
                                 kAuthorInformalKey,
                                 kAuthorAffiliationKey,
                                 kAuthorAddressKey,
                                 kAuthorPhoneKey,
                                 kAuthorFaxKey,
                                 kAuthorEmailKey,
                                 kAuthorWebsiteKey
                                   ]
                                   
                                   ];
    
    return theDictionary;
    
}
-(void)unpackFromDictionary:(NSDictionary *)theDictionary; {
    
    
    for (NSString *key in [theDictionary allKeys]) {
        
        [self setValue:[theDictionary objectForKey:key] forKey:key];
        
    }
    
}

-(NSString *)indexNameWithLeadingInitials; {
    // NOTE: need to strip dots, insert spaces in initials
    return [NSString stringWithFormat:@"%@ %@",
            initials,indexName
             ];
}

-(NSString *)indexNameWithTrailingInitials; {
    // NOTE: need to strip dots, insert spaces in initials
    return [NSString stringWithFormat:@"%@ %@",
            indexName, initials
            ];
}

-(NSString *)authorToken; {
    return [self indexNameWithLeadingInitials];
}

-(NSString *)correspondenceString; {

    NSMutableString *corr = [NSMutableString string];
    [corr appendString:fullName];
    [corr appendString:@", "];
    
    if (0 < [address length]) {
        [corr appendString:address];
    }
    else {
    [corr appendString:[affiliation stringByReplacingOccurrencesOfString:@"," withString:@", "]];
    }
    [corr appendString:@". "];
    
    if (0 < [phone length]) { 
         [corr appendString:@"Tel: "];
         [corr appendString:phone];
         [corr appendString:@". "];
    }
    if (0 < [fax length]) {
        [corr appendString:@"Fax: "];
        [corr appendString:fax];
        [corr appendString:@". "];    
    }
    if (0 < [email length]) {
        [corr appendString:@"Email: "];
        [corr appendString:email];
        [corr appendString:@". "];    
    }

    
    
    return corr;

}

@end
