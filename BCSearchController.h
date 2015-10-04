//
//  BCSearchController.h
//  Caravan
//
//  Created by Tom Houpt on 15/9/27.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, BCSearchOptionsType) {

    kContainsSearchTerm = 0,
    kStartsWithSearchTerm = 1,
    kEndsWithSearchTerm = 2,
    kFullWordSearchTerm = 3

};

#define kBCSearchTermPositionKey @"BCSearchTermPositionKey"
#define kBCSearchIgnoreCaseKey @"BCSearchIgnoreCaseKey"
#define kBCSearchUsingRegexKey @"BCSearchUsingRegexKey"

#define kDefaultSearchTermPosition @0
#define kDefaultSearchIgnoreCase @YES
#define kDefaultSearchUsingRegex @NO


@class CaravanSourceFile;
@class CaravanSourceListDocument;

@interface BCFindResult: NSObject 

@property CaravanSourceFile *file;
@property NSRange resultRange;
@property NSMutableAttributedString *resultString;

@end


@interface BCSearchTableView: NSTableView

-(void)handleDoubleClick:(id)sender; 

@end

@interface BCSearchController : NSObject <NSTableViewDataSource, NSTableViewDelegate> {


    NSDictionary *insertDictionary;
    
       NSCharacterSet  *controlChars;
       NSDictionary *boldAttribute;
       
        NSString *regexPattern;
        NSInteger searchOptions;
        NSInteger regexOptions;
        NSRegularExpression *regExp;

}

@property CaravanSourceListDocument *document;
@property NSMutableArray *results;

@property IBOutlet BCSearchTableView *resultsTable;

@property IBOutlet NSButton *find;
@property IBOutlet NSButton *replace;
@property IBOutlet NSButton *replaceAll;

@property IBOutlet NSButton *ignoreCase;
@property IBOutlet NSButton *regex;
@property IBOutlet NSMatrix *position;

@property IBOutlet NSTextField *findString;
@property IBOutlet NSTextField *replaceString;

@property IBOutlet NSButton *deleteFind;
@property IBOutlet NSButton *deleteReplace;

@property IBOutlet NSPopUpButton *insertFind;
@property IBOutlet NSPopUpButton *insertReplace;


@property IBOutlet NSButton *okButton;
@property IBOutlet NSWindow *dialog;

-(NSArray *)dialogForWindow:(NSWindow *)ownerWindow; 




-(void)handleRowDoubleClick:(BCSearchTableView*)table;

-(IBAction)OKButtonPressed:(id)sender;
-(IBAction)handleDoubleClick:(id*)sender;
-(IBAction)regexPressed:(id)sender;

-(IBAction)deleteFindPressed:(id)sender;
-(IBAction)deleteReplacePressed:(id)sender;
-(IBAction)insertFindPressed:(id)sender;
-(IBAction)insertReplacePressed:(id)sender;

-(IBAction)findStringEntered:(id)sender;

-(IBAction)replacePressed:(id)sender;
-(IBAction)replaceAllPressed:(id)sender;
-(BOOL) replaceFindResult:(BCFindResult *)result;

@end
