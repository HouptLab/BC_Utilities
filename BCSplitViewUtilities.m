//
//  BCSplitViewUtilities.m
//  Xynk
//
//  Created by Tom Houpt on 15/1/12.
//
//

#import "BCSplitViewUtilities.h"

@implementation NSSplitView (BCSplitViewUtilities)

-(void)saveUsingAutosaveName; {
    
    NSString *key = self.autosaveName;

    NSMutableArray *subviewFrames = [NSMutableArray array];
    

    for (NSInteger i=0; i < [[self subviews] count]; i++ ) {

       NSRect frame = [[[self subviews] objectAtIndex:i] frame];
        
        NSString *flag = [self isSubviewCollapsed:[[self subviews] objectAtIndex:i] ] ? @"YES" : @"NO";
        
        NSString *frameString = [NSString stringWithFormat:@"%g, %g, %g, %g, %@",
                                 frame.origin.x, frame.origin.y,
                                 frame.size.width, frame.size.height,
                                 flag];
        
        [subviewFrames addObject:frameString];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:subviewFrames forKey:key];
}

-(BOOL)readUsingName:(NSString *)name; {
    
//    read routine  from     ElmerCat on StackOverflow Dec 31 2014
// http://stackoverflow.com/questions/16587058/nssplitview-auto-saving-divider-positions-doesnt-work-with-auto-layout-enable
    
    // Yes, I know my Autosave Name; but I won't necessarily restore myself automatically.    
    NSArray *subviewFrames = [[NSUserDefaults standardUserDefaults] valueForKey:name];
    
    if (nil == subviewFrames) {
        return NO;
    }
    
    // the last frame is skipped because I have one less divider than I have frames
    for (NSInteger i=0; i < (subviewFrames.count - 1); i++ ) {
        
        // this is the saved frame data - it's an NSString
        NSString *frameString = subviewFrames[i];
        NSArray *components = [frameString componentsSeparatedByString:@", "];
        
        // only one component from the string is needed to set the position
        CGFloat position;
        
        // if I'm vertical the third component is the frame width
        if (self.vertical) position = [components[2] floatValue];
        
        // if I'm horizontal the fourth component is the frame height
        else position = [components[3] floatValue];
        
        [self setPosition:position ofDividerAtIndex:i];
    }
    
    return YES;
}


@end
