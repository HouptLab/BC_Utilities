//
//  BCSplitViewUtilities.h
//  Xynk
//
//  Created by Tom Houpt on 15/1/12.
//
//

#import <Cocoa/Cocoa.h>

@interface   NSSplitView (BCSplitViewUtilities)


-(void)saveUsingAutosaveName;
-(BOOL)readUsingName:(NSString *)name;
//    read routine from     ElmerCat on StackOverflow Dec 31 2014
// http://stackoverflow.com/questions/16587058/nssplitview-auto-saving-divider-positions-doesnt-work-with-auto-layout-enable

@end
