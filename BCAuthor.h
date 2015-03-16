//
//  BCAuthor.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/13.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCAffliation;

#define	kAuthorIndexNameKey	 @"indexName"
#define	kAuthorInitialsKey	 @"initials"
#define	kAuthorOrcidKey	 @"orcid"
#define	kAuthorContributionKey	 @"contribution"
#define	kAuthorPositionKey	 @"position"
#define	kAuthorPrefixKey	 @"prefix"
#define	kAuthorFullNameKey	 @"fullName"
#define	kAuthorDegreesKey	 @"degrees"
#define	kAuthorInformalKey	 @"informal"
#define	kAuthorAffiliationKey	 @"affiliation"
#define	kAuthorAddressKey	 @"address"
#define	kAuthorPhoneKey	 @"phone"
#define	kAuthorFaxKey	 @"fax"
#define	kAuthorEmailKey	 @"email"
#define	kAuthorWebsiteKey	 @"website"



@interface BCAuthor : NSObject

// required for citations
@property (copy) NSString *indexName;// last or family name in Europe
@property (copy) NSString *initials; // "J.C." or "JC" or "J C". note that a hypen, e.g. "J-LP", is not a separator, so "J-LP" would be parsed as "J.-L. P"

@property (copy) NSString * orcid; // 16 digit number with hyphen every 4 digits

// requird for title page or contact info...
// probably overdetermined
// can be matched more directly to vcard?

@property (copy) NSString *contribution;
@property (copy) NSString *position; /// e.g. "Research Associate, Professor, Chair" can be multiple can be multiple

@property (copy) NSString *prefix; /// "Professor" or "Professor Dr.
@property (copy) NSString *fullName; /// as used on title page "James C. Smith"
@property (copy) NSString *degrees; // e.g. "PhD, MD"
@property (copy) NSString *informal; // e.g. Jim


@property (copy) NSString *affiliation;// bind to fancy affliation structure...[define like an URL..., can be multiple
@property (copy) NSString *address;
@property (copy) NSString *phone;
@property (copy) NSString *fax;
@property (copy) NSString *email;
@property (copy) NSString *website;

-(NSDictionary *)packIntoDictionary;
-(void)unpackFromDictionary:(NSDictionary *)theDictionary;

-(NSString *)indexNameWithLeadingInitials;
-(NSString *)indexNameWithTrailingInitials;
-(NSString *)authorToken;

@end
