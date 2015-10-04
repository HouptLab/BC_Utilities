//
//  BCSearchController.m
//  Caravan
//
//  Created by Tom Houpt on 15/9/27.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCSearchController.h"
#import "CaravanSourceFile.h"
#import "CaravanSourceListDocument.h"

@implementation BCFindResult

@end

#define CONTEXT_WIDTH 30


@implementation BCSearchTableView

-(void)handleDoubleClick:(id)sender; 
{
    
    [(BCSearchController *)[self dataSource] handleRowDoubleClick:self];

}

@end


@implementation BCSearchController

@synthesize dialog;

-(id)init; {
    
    self = [super init];
    
    
        if (self) {

        // set up some useful data structures
        
        // to replace control characters and the unicode for NSAttachmentCharacter (whichmarks citekeys in text)
    
        unsigned char bitmapRep[8192];
        
        for (int i=0; i<8192; i++) {
            bitmapRep[i] = 0;
        }
bitmapRep[NSAttachmentCharacter >> 3] |= (((unsigned int)1) << (NSAttachmentCharacter & 7));
    
     NSMutableCharacterSet *mut_controlChars = [NSMutableCharacterSet characterSetWithBitmapRepresentation:[NSData dataWithBytes:bitmapRep length:8192]];
    
    


    
    [mut_controlChars formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
    
    controlChars =  [mut_controlChars copy]; 
    
    
    //the font for highlighting found string in results
    
    NSFont *boldFont = [NSFont fontWithName:@"Menlo Bold" size:12.0];

    
    boldAttribute = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
  
  
  // the dictionary for inserting odd characters into find or replace strings
  
    unichar attachmentChar = NSAttachmentCharacter;
  NSString *attachmentString = [NSString stringWithCharacters:&attachmentChar length:1];


 insertDictionary =  [ NSDictionary dictionaryWithObjectsAndKeys:
            @"\t", @"Tab", 
            @"\r", @"Line Break",
            @"\r\r", @"Paragraph Break",
            @"???", @"Page Break",
            @"@([a-zA-Z0-9])", @"Any Characters",
            @"([a-zA-Z]+)", @"Letters",
            @"([0-9]+)", @"Digits",
            @"(\\s+)", @"White Space",
            attachmentString, @"CiteKey Marker",
            nil];

                
        if (!dialog) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [NSBundle  loadNibNamed:@"BCSearchDialog" owner:self];
#pragma clang diagnostic pop

 
            
        }

    }
    
    return self;
    
}

-(void)awakeFromNib; {

        [self.position setEnabled:YES];
        [self.position selectCellAtRow:kContainsSearchTerm column:0];
        [self.regex setState:NSOffState];
        [self.ignoreCase setState:NSOnState];
        

}

-(NSArray *)dialogForWindow:(NSWindow *)ownerWindow; 
{
    
    // NOTE: run last used keywords, select last selected journal 
    [self regexPressed:self];

    NSString *findPBoardString = [[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSPasteboardTypeString];
    
    if (nil != findPBoardString) {
            [self.findString setStringValue:findPBoardString];
    }
    
        
    NSString *replacePBoardString = [[NSPasteboard pasteboardWithName:@"NSReplacePboard"] stringForType:NSPasteboardTypeString];

    
    if (nil != replacePBoardString) {
            [self.findString setStringValue:replacePBoardString];
    }
        
    [self.replace setEnabled: NO];

    [self.resultsTable setDoubleAction:@selector(handleDoubleClick:)];
    [self.resultsTable setRowHeight:24];
    [self.resultsTable setDelegate:self];
    [self.resultsTable setDataSource:self];
    
    [self.results removeAllObjects];
    
    NSTableColumn *fileColumn = [self.resultsTable tableColumnWithIdentifier:@"filename"];
    [fileColumn setTitle:  [NSString stringWithFormat:@"Files (--)"]];
   
    NSTableColumn *resultsColumn = [self.resultsTable tableColumnWithIdentifier:@"text"];
    [resultsColumn setTitle:  [NSString stringWithFormat:@"Search Results (--)"]];
   
   [self.resultsTable reloadData];

    
    if (self.results == nil) { self.results = [NSMutableArray array]; }
    
    [NSApp beginSheet: dialog
       modalForWindow: ownerWindow
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp runModalForWindow: dialog];
    
    // See NSApplication Class Reference/runModalSession
    
    [NSApp endSheet:  dialog];
    [dialog orderOut: self];

    [self.resultsTable setDelegate:nil];
    [self.resultsTable setDataSource:nil];

    
    return nil;
    
}



-(void)handleRowDoubleClick:(BCSearchTableView*)table; {

   NSInteger selectedRow = [self.resultsTable selectedRow];
        
    if (-1 == selectedRow) {
        return;
    }

    BCFindResult *result = [self.results objectAtIndex:selectedRow];
    
    [result.file setLastInsertionIndex:result.resultRange.location];
    
    [self.document expandAndSelectSourceListObject: result.file];
    
    [[result.file textView] setSelectedRange:result.resultRange];


    [NSApp stopModal];


}


-(IBAction)OKButtonPressed:(id)sender;{

       
      
   [NSApp stopModal];

}

-(IBAction)cancelButtonPressed:(id)sender; {

    [NSApp stopModal];

}

-(IBAction)regexPressed:(id)sender; {

    [self.position setEnabled:![self.regex state]];

}

-(IBAction)ignoreCasePressed:(id)sender; {

    [self findStringEntered:self];

}
-(IBAction)positionPressed:(id)sender; {

    [self findStringEntered:self];

}



-(void)setSearchParameters;
{

    searchOptions = 0;
    regexOptions = 0;
   
    if ([self.regex state] == NSOnState) {
            regexPattern = [self.findString stringValue];
            if ([self.ignoreCase state] == NSOnState) {
                regexOptions = NSRegularExpressionCaseInsensitive;
            }
            
            regExp = [NSRegularExpression regularExpressionWithPattern:regexPattern options:regexOptions error:nil]; 
    }
   else {
   
        if ([self.position selectedRow] == kFullWordSearchTerm) {
            regexPattern = [NSString stringWithFormat:@"\\b(%@)\\b",[self.findString stringValue]];
            if ([self.ignoreCase state] == NSOnState) {
                regexOptions = NSRegularExpressionCaseInsensitive;
            }
            regExp = [NSRegularExpression regularExpressionWithPattern:regexPattern options:regexOptions error:nil]; 
        }
        else if ([self.position selectedRow] == kStartsWithSearchTerm) {            
            regexPattern = [NSString stringWithFormat:@"\\b(%@)",[self.findString stringValue]];
            if ([self.ignoreCase state] == NSOnState) {
                regexOptions = NSRegularExpressionCaseInsensitive;
            }
            regExp = [NSRegularExpression regularExpressionWithPattern:regexPattern options:regexOptions error:nil];        
        }
        else if ([self.position selectedRow] == kEndsWithSearchTerm) {
            regexPattern = [NSString stringWithFormat:@"(%@)\\b",[self.findString stringValue]];
            if ([self.ignoreCase state] == NSOnState) {
                regexOptions = NSRegularExpressionCaseInsensitive;
            }
            regExp = [NSRegularExpression regularExpressionWithPattern:regexPattern options:regexOptions error:nil];                
        }
        
        if ([self.ignoreCase state] == NSOnState) {
            searchOptions = searchOptions | NSCaseInsensitiveSearch;
        }
        
    }



}

-(NSRange)searchText:(NSString *)text inRange:(NSRange)searchRange; {

    NSRange range;
  
        if (([self.regex state] == NSOnState) || ([self.position selectedRow] != kContainsSearchTerm)) {
            
            NSTextCheckingResult *regResult = [regExp firstMatchInString:text options:0 range:searchRange];
            
            range = (nil == regResult) ? NSMakeRange(NSNotFound,0) : [regResult range];
               
        }
        else {
            range = [text rangeOfString:[self.findString stringValue] options:searchOptions range:searchRange];
        }
        // {NSNotFound, 0} if find string is not found

        return range;
}

-(IBAction)findStringEntered:(id)sender; {


    [self.results removeAllObjects];
    NSInteger numberOfFilesWithResults = 0;

    // check if findString is valid
    
    if (nil != [self.findString stringValue] && 0 < [[self.findString stringValue] length]) {
    
        // save findString to NSFindPBoard

        [[NSPasteboard pasteboardWithName:NSFindPboard] clearContents];
        [[NSPasteboard pasteboardWithName:NSFindPboard] setString:[self.findString stringValue] forType:NSStringPboardType];
        
        [[NSPasteboard pasteboardWithName:@"NSReplacePBoard"] clearContents];
        [[NSPasteboard pasteboardWithName:@"NSReplacePBoard"] setString:[self.replaceString stringValue] forType:NSStringPboardType];

        // set up regex and other search options
        [self setSearchParameters];
        
        
        // get all the text files we're going to search
        
       NSArray *files = [self.document textFilesForFindAndReplace];
       
       for (CaravanSourceFile *file in files) {
       
            BOOL foundResult = NO;
            NSString *text = [[[file textView] textStorage] string];
            
            NSRange searchRange = NSMakeRange(0, [text length]);
            while (searchRange.location <  [text length]) {
            
                NSRange range = [self searchText:text inRange:searchRange];
                // {NSNotFound, 0} if find string is not found
                
                if (NSNotFound != range.location) {
                
                    BCFindResult *result = [[BCFindResult alloc] init];
                    
                    result.resultRange = range;
                    result.file = file;
                    NSRange resultRange = range;
                    resultRange.length += (CONTEXT_WIDTH * 2);
                    if (CONTEXT_WIDTH < resultRange.location) { resultRange.location -= CONTEXT_WIDTH; }
                    else { resultRange.location = 0; }
                    
                    if ([text length] < (resultRange.length +  resultRange.location)) { 
                            resultRange.length =  [text length] - resultRange.location; }
                            
                    NSString *resultString = [text substringWithRange:resultRange];
                    
                    
                    // NOTE: get rid of citation marks as well?
                    resultString = [                
                          [resultString componentsSeparatedByCharactersInSet:controlChars]
                          componentsJoinedByString:@" "];
                    
                    
                    NSRange resultInStringRange = [resultString rangeOfString:[self.findString stringValue] options:NSCaseInsensitiveSearch];                    
                    
                    if (resultInStringRange.location < CONTEXT_WIDTH) {
                    
                        NSInteger padding = CONTEXT_WIDTH - resultInStringRange.location;
                        
                        NSMutableString *pad = [NSMutableString stringWithCapacity:padding];
                        
                        for (NSInteger i=0; i<padding;i++) {
                            [pad appendString:@" "];
                        }
                        
                        resultString = [pad stringByAppendingString:resultString];
                        
                        // NOTE: truncate end by same amount
                          
                    }
                    
                    result.resultString = [[NSMutableAttributedString alloc] initWithString:resultString];
                    
                    [result.resultString addAttribute:NSFontAttributeName
                        value:[NSFont fontWithName:@"Menlo Bold" size:12.0]
                        range:NSMakeRange(CONTEXT_WIDTH,range.length)];

                    // NOTE: need to fix padding/bolding if findString occurs twice in same context string
                    
                    [self.results addObject:result];
                    
                    searchRange = range;
                    searchRange.location += [[self.findString stringValue] length];
                    searchRange.length = [text length] - searchRange.location;
                    
                    foundResult = YES;
                }
                else {
                    searchRange.location = NSNotFound;
                }
                
            }
            
            if (foundResult) { numberOfFilesWithResults++; }
       }
       
   }// valid findString
   
   // display number of results, and reload results table
   
    NSTableColumn *fileColumn = [self.resultsTable tableColumnWithIdentifier:@"filename"];
   [fileColumn setTitle:  [NSString stringWithFormat:@"Files (%ld)",numberOfFilesWithResults]];
   
   NSTableColumn *resultsColumn = [self.resultsTable tableColumnWithIdentifier:@"text"];
   [resultsColumn setTitle:  [NSString stringWithFormat:@"Search Results (%ld)",[self.results count]]];
   
   [self.resultsTable reloadData];

}


-(IBAction)replaceAllPressed:(id)sender; {
    
    
     if (self.results == 0 || nil == [self.replaceString stringValue] || 0 == [[self.replaceString stringValue] length]) {
        return; 
     }
    
    
    // NOTE: put up alert that can not be undone

        
    for (NSInteger i= ([self.results count] - 1); i>=0; i--) {
        
        BCFindResult *result = [self.results objectAtIndex:i];
        
        [self replaceFindResult:result];
        
       
    }
    
    // try re-searching for find term as a way to update the results..

    // NOTE: post announcement of x # of replacments
    
    [self findStringEntered:self];

}

-(BOOL) replaceFindResult:(BCFindResult *)result; {

 // check if ok to make replacement
 
            if ([[result.file textView] shouldChangeTextInRange:result.resultRange
                                    replacementString:[self.replaceString stringValue]]) {
        
        //if we wanted to preserve current attributes, then we could get attributedSubstringFromRange,
        // then swap out the text for the replaced text (but leave the attributes)
        
  
        NSTextStorage *store= [[result.file textView] textStorage];

        
        // then notify that change took place
        [[store mutableString] replaceCharactersInRange:result.resultRange withString:[self.replaceString stringValue]];
            
        
        [[result.file textView] didChangeText];
        
        // force file to save itself
        
        [result.file save]; 


        // NOTE: do we need to post notification after all text in this file changed?

        // [[self delegate] textDidChange:[NSNotification notificationWithName:NSTextDidChangeNotification object:self]];
        
        return YES;
    }
    return NO;
        
}

-(IBAction)replacePressed:(id)sender; {

    NSInteger selectedRow = [self.resultsTable selectedRow];
        
    if (-1 == selectedRow) {
        return;
    }

    BCFindResult *result = [self.results objectAtIndex:selectedRow];
    
    if ([self replaceFindResult:result]){
    
    // NOTE Make this UNDOABLE ?
        [self.results removeObjectAtIndex:selectedRow];
        
        [self.resultsTable reloadData];
    }
        

}

-(IBAction)deleteFindPressed:(id)sender; {
    [self.findString setStringValue:@""];
}
-(IBAction)deleteReplacePressed:(id)sender; {
    [self.replaceString setStringValue:@""];
}

-(void)insertString:(NSString *)insertString intoTextField:(NSTextField *)field; {


// NOTE: maybe we want to retrieve string, insert offline, then put string back into control...
    [[field currentEditor] insertText:insertString];
}


-(IBAction)insertFindPressed:(id)sender; {

    NSString *insertKey = [self.insertFind titleOfSelectedItem];
   
    NSString *insertString = [insertDictionary objectForKey:insertKey];
    
    [self insertString:insertString intoTextField:self.findString];
   
}
-(IBAction)insertReplacePressed:(id)sender;{

    NSString *insertKey = [self.insertFind titleOfSelectedItem];
   
    NSString *insertString = [insertDictionary objectForKey:insertKey];
    
    [self insertString:insertString intoTextField:self.replaceString];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
{

    if (aTableView != self.resultsTable) { return 0; }

    return [self.results count];

}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex;
{

    if (aTableView != self.resultsTable) { return nil; }

    if ([[aTableColumn identifier] isEqualToString:@"filename"]) {
    
        return [[[self.results objectAtIndex:rowIndex] file] name];

    
    }
    else if ([[aTableColumn identifier] isEqualToString:@"text"] ) {
    
        return [[self.results objectAtIndex:rowIndex] resultString];
    
    }
    
    return nil;
            
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification; {

    if (self.resultsTable == [aNotification object]) {
        NSInteger intSelectedRow = [self.resultsTable selectedRow];
        
        if (-1 == intSelectedRow) {
            [self.replace setEnabled: NO];
        }
        else {
            [self.replace setEnabled: YES];
        }
    }
}

@end
