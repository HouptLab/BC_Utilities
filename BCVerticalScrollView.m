//
//  BCVerticalScrollView.m
//  Caravan
//
//  Created by Tom Houpt on 15/4/2.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCVerticalScrollView.h"

@implementation BCVerticalScrollView

-(void)awakeFromNib; {
    
    // make the document view same width as the scrollview contentview
    // scroll to top left of view
    // intercept scrolling to disable horizontal scroll
    
    [[self documentView] setFrameSize:NSMakeSize(self.contentView.frame.size.width,((NSView *)(self.documentView)).frame.size.height)];
    
    NSPoint newOrigin = NSMakePoint(0,
                                    NSMaxY( ((NSView *)(self.documentView)).frame ) -
                                    self.contentView.bounds.size.height);
    
    [[self documentView] scrollPoint:newOrigin];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLiveScroll:)
                                                 name:NSScrollViewDidLiveScrollNotification
                                               object:nil];
    
}

 -(void)dealloc; {
     [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
 }

-(void)handleLiveScroll:(NSNotification*) note; {
    // whenever we scroll, set document frame width to scrollView frame width
    
    if ([note object] != self) { return; }
    
//    NSLog(@"F self: %lf,%lf     content: %lf,%lf    doc:  %lf,%lf",
//          self.frame.size.width,self.frame.size.height,
//          self.contentView.frame.size.width,self.contentView.frame.size.height,
//          ((NSView *)(self.documentView)).frame.size.width,((NSView *)(self.documentView)).frame.size.height);
//
//    NSLog(@"B self: %lf,%lf     content: %lf,%lf    doc:  %lf,%lf",
//          self.bounds.size.width,self.bounds.size.height,
//          self.contentView.bounds.size.width,self.contentView.bounds.size.height, ((NSView *)(self.documentView)).bounds.size.width,((NSView *)(self.documentView)).bounds.size.height);

      [[self documentView] setFrameSize:NSMakeSize(self.contentView.frame.size.width,((NSView *)(self.documentView)).frame.size.height)];
   
    
}

//- (void)scrollWheel:(NSEvent *)theEvent
//{
//    [self.nextResponder scrollWheel:theEvent];
//    // Do nothing: disable scrolling altogether
//}
//
//- (NSRect)adjustScroll:(NSRect)proposedVisibleRect
//{
//    NSRect modifiedRect=proposedVisibleRect;
//    
//    // snap to 72 pixel increments
//    modifiedRect.origin.x = (int)(modifiedRect.origin.x/72.0) * 72.0;
//    modifiedRect.origin.y = (int)(modifiedRect.origin.y/72.0) * 72.0;
//    
//    // return the modified rectangle
//    return modifiedRect;
//}
//

@end
