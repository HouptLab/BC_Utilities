//
//  BCObjectMatrix.h
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import <Foundation/Foundation.h>

@interface BCObjectMatrix : NSObject

// parallel implementation of BCMatrix but using objects in an NSMutableArray instead of elements in void *buffer

// [myMatrix objectAtIndices:i,j,k]
// matrix object [i][j][k] is at bufferArray [ c[0] * i + c[1] * j + c[3] * k]
// internally: matrix object [i][j][k] is at bufferArray [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2])  ]


@property NSInteger dimension;
@property NSMutableArray *buffer;
@property NSInteger *dimensionSizes;
@property NSInteger *c; // coeffecients for indexing into array buffer
@property NSInteger *index; // an array to hold the indices when dereferencing an element

-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes;


-(void)dealloc; // free the malloc'd buffers

-(NSInteger)count; // total number of elements in matrix

-(id)objectAtIndices:(NSInteger) firstIndex,...;
    // variadic method
    // returns object at matrix[firstIndex,...]
    // note that this returns object reference, not a copy of the object

-(void)setObject:(id)object atIndices:(NSInteger) firstIndex,...; 
    // variadic method
    // sets object into matrix[firstIndex,...]
    // of course, # indices should == dimension
    // but we can't check this ourselves

@end
