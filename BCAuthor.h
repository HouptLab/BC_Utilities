//
//  BCAuthor.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/13.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCAffliation;


#define kUTTypeBCAuthor @"UTTypeBCAuthor" // type for pasteboard/drag&drop from author list to outside
#define kUTTypeBCAuthorIndexes @"UTTypeBCAuthorIndexes" // private type for pasteboard/drag&drop within the same controller



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


#define kBCAuthorEditedNotification @"authorEditedNotification"
#define kBCAuthorsDeletedNotification @"authorDeletedNotification"
#define kBCAuthorAddedNotification @"authorAddedNotification"



@interface BCAuthor : NSObject

// required for citations
@property (copy) NSString *indexName;// last or family name in Europe
@property (copy) NSString *initials; // "J.C." or "JC" or "J C". note that a hypen, e.g. "J-LP", is not a separator, so "J-LP" would be parsed as "J.-L. P"

@property (copy) NSString * orcid; // 16 digit number with hyphen every 4 digits
// @property (copy) NSString *clusterID;
// @property (copy) NSString *authorType;

// requird for title page or contact info...
// probably overdetermined
// can be matched more directly to vcard?

@property (copy) NSString *contribution;
//NOTE: values of contribution or role should be based on: http://loc.gov/marc/relators/relaterm.html

@property (copy) NSString *position; /// e.g. "Research Associate, Professor, Chair" can be multiple can be multiple

@property (copy) NSString *prefix; /// "Professor" or "Professor Dr.
@property (copy) NSString *fullName; /// as used on title page "James C. Smith"
@property (copy) NSString *degrees; // e.g. "PhD, MD"
@property (copy) NSString *informal; // e.g. Jim


@property (copy) NSString *affiliation;// bind to fancy affliation structure...[define like an URL..., can be multiple

@property (copy) NSString *current_address;// bind to fancy affliation structure...[define like an URL..., can be multiple

@property (copy) NSString *address;
@property (copy) NSString *phone;
@property (copy) NSString *fax;
@property (copy) NSString *email;
@property (copy) NSString *website;

@property BOOL hasBeenDeleted;

-(NSDictionary *)packIntoDictionary;
-(void)unpackFromDictionary:(NSDictionary *)theDictionary;

-(NSString *)indexNameWithLeadingInitials;
-(NSString *)indexNameWithTrailingInitials;
-(NSString *)authorToken;
-(NSString *)correspondenceString;


@end
