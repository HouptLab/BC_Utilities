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



@interface BCSearchTableView: NSTableView

-(void)handleDoubleClick:(id)sender; 

@end

@interface BCSearchController : NSObject {
    
       
    

}

@property IBOutlet BCSearchTableView *resultsTable;

@property IBOutlet NSButton *replace;
@property IBOutlet NSButton *replaceAll;

@property IBOutlet NSButton *ignoreCase;
@property IBOutlet NSButton *regex;
@property IBOutlet NSMatrix *position;

@property IBOutlet NSTextField *findString;
@property IBOutlet NSTextField *replaceString;

@property IBOutlet NSButton *deleteFind;
@property IBOutlet NSButton *deleteReplace;

@property IBOutlet NSButton *insertFind;
@property IBOutlet NSButton *insertReplace;

@property IBOutlet NSMenu *insertMenu;


@property IBOutlet NSButton *okButton;
@property IBOutlet NSWindow *dialog;

-(NSArray *)dialogForWindow:(NSWindow *)ownerWindow; 


-(IBAction)parseTokens:(id)sender; 

-(void) findIntersectionOfKeywords;

-(void)handleRowDoubleClick:(BCSearchTableView*)table;

-(IBAction)OKButtonPressed:(id)sender;
-(IBAction)handleDoubleClick:(id*)sender;
-(IBAction)regexPressed:(id)sender;
-(IBAction)findStringEntered:(id)sender;
-(IBAction)deleteFindPressed:(id)sender;
-(IBAction)deleteReplacePressed:(id)sender;
-(IBAction)insertFindPressed:(id)sender;
-(IBAction)insertReplacePressed:(id)sender;

@end
