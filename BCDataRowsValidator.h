//
//  BCDataRowsValidator.h
//  Xynk
//
//  Created by Tom Houpt on 21/9/23.
//

#import <Foundation/Foundation.h>


#define kDataRowsMinimum 2 // header and 1 subject
#define kDataColumnsMinimum 3 // subject, group, and one measure column



typedef NSUInteger DataValidationError;

typedef NS_OPTIONS(NSUInteger,DataValidationErrorFlags) {
    kDataValidationErrorNoError = 0,
    kDataValidationErrorNonEqualRowLengths = 1 << 0,
    kDataValidationErrorInsufficientColumns = 1 << 1,
    kDataValidationErrorInsufficientRows = 1 << 2,
    kDataValidationErrorRowsLongerThanHeader = 1 << 3,
    kDataValidationErrorRowsShorterThanHeader = 1 << 4,
    kDataValidationErrorEmptyHeaderCell = 1 << 5,
    kDataValidationErrorNoDataOnPasteboard = 1 << 6,
    kDataValidationErrorProblemSubject = 1 << 7
};


NS_ASSUME_NONNULL_BEGIN

@interface BCDataRowsValidator : NSObject

@property NSMutableArray *rows;
@property NSArray *errorStrings;

-(id)initWithRows:(NSMutableArray *)theRows;
-(DataValidationError)validateRows; 
-(NSString *)errorString:(DataValidationError)error;

@end

NS_ASSUME_NONNULL_END
