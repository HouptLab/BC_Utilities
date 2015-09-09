//
//  BCCitationAuthor.m
//  Caravan
//
//  Created by Tom Houpt on 15/3/16.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCCitationAuthor.h"

@implementation BCCitationAuthor

@synthesize indexName;
@synthesize givenName;
@synthesize initials;
@synthesize orcid;

-(id)init; {
    
    self = [super init];
    
    if (self) {
        
        indexName = @"Anonymous";
        givenName = [NSString string];
        initials = [NSString string];
        orcid = [NSString string];

    }
    
    return self;
}

-(NSDictionary *)packIntoDictionary; {
    
    NSDictionary *theDictionary = [NSDictionary
                                   dictionaryWithObjects:@[
                                                           indexName,
                                                           givenName,
                                                           initials,
                                                           orcid
                                                           ]
                                   forKeys:@[
                                             kCitationAuthorIndexNameKey,
                                             kCitationAuthorGivenNameKey,
                                             kCitationAuthorInitialsKey,
                                             kCitationAuthorOrcidKey,
                                             ]
                                   
                                   ];
    
    return theDictionary;
    
}
-(void)unpackFromDictionary:(NSDictionary *)theDictionary; {
    
    for (NSString *key in [theDictionary allKeys]) {
        [self setValue:[theDictionary objectForKey:key] forKey:key];
    }
    
}


@end
