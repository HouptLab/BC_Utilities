//
//  BCCitationAuthor.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/16.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCitationAuthorIndexNameKey @"indexName"
#define kCitationAuthorGivenNameKey @"givenName"
#define kCitationAuthorInitialsKey @"initials"
#define kCitationAuthorOrcidKey @"orcid"

@interface BCCitationAuthor : NSObject



-(id)initWithLastNameAndInitialsString:(NSString *)authorName; 
// pass in e.g. @"Smith, J.C., Jr"
// -> indexName: @"Smith", initials: @"J.C., Jr"
// have to set given name and orcid by hand

@property (copy) NSString *indexName;
@property (copy) NSString *givenName;
@property (copy) NSString *initials;
@property (copy) NSString *orcid;
//-> @property (copy) NSString *clusterID;
//-> @property (copy) NSString *authorType


-(NSDictionary *)packIntoDictionary;
-(void)unpackFromDictionary:(NSDictionary *)theDictionary;

@end
