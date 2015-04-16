//
//  BCCiteKeyWrapper.m
//  Caravan
//
//  Created by Tom Houpt on 15/4/15.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

#import "BCCiteKeyWrapper.h"
#import "AppKit/AppKit.h"

@implementation BCCiteKeyWrapper


-(id)initWithCiteKey:(NSString *)citeKey; {
    
    NSData *ckData = [citeKey dataUsingEncoding:NSASCIIStringEncoding];
    //    return (BCCiteKeyWrapper *)[ckAttributedString RTFDFileWrapperFromRange:NSMakeRange(0,[ckAttributedString length])documentAttributes:[NSDictionary dictionaryWithObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute]];

    self = [super initRegularFileWithContents:ckData];
    
    if (self) {
        NSString *filename = [citeKey stringByAppendingPathExtension:@"txt"];
        [self setPreferredFilename:filename];
    }
    return self;
    
    
//    NSAttributedString *ckAttributedString = [[NSAttributedString alloc] initWithString:citeKey];
//    return (BCCiteKeyWrapper *)[ckAttributedString RTFDFileWrapperFromRange:NSMakeRange(0,[ckAttributedString length])documentAttributes:[NSDictionary dictionaryWithObject:NSPlainTextDocumentType forKey:NSDocumentTypeDocumentAttribute]];
//
    
    
}

@end
