//
//  BCSemicolonTokenField.m
//  
//
//  Created by Tom Houpt on 15/10/6.
//
//

#import "BCSemicolonTokenField.h"

@implementation BCSemicolonTokenField



-(void)awakeFromNib; {
[self setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];

}

@end
