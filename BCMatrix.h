//
//  BCMatrix.h
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import <Foundation/Foundation.h>

// [myMatrix elementAtIndices:i,j,k]
// matrix element [i][j][k] is at buffer [ c[0] * i + c[1] * j + c[3] * k]
// internally, matrix element [i][j][k] is at buffer [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2]) * elementSize]


@interface BCMatrix : NSObject

@property NSInteger dimension;
@property size_t elementSize;
@property void *buffer;
@property NSInteger *dimensionSizes; // maximum size of each dimension of array
@property NSInteger *c; // coeffecients for indexing into array buffer == product of lower dimensionSizes
@property NSInteger *index; // an array to hold the indices when dereferencing an element

-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes forElementSize:(size_t)iS;

-(void)dealloc; // free the malloc'd buffers

-(NSInteger)count; // total number of elements in matrix

-(void *)copyOfElementAtIndices:(NSInteger) firstIndex,...; 
    // variadic method
    // returns address of element at matrix[firstIndex,...]
    // caller should copy this into their own data structure,
    // otherwise they could overwrite our entry in the buffer

-(void)setElement:(void *)element atIndices:(NSInteger) firstIndex,...; 
    // variadic method
    // copies element at address *element into matrix[firstIndex,...]
    // of course, # indices should == dimension
    // element should be same size as elementSize
    // but we can't check this ourselves

@end
