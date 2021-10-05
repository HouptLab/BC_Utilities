//
//  BCObjectMatrix.h
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import <Foundation/Foundation.h>
/** parallel implementation of BCMatrix but using objects in an NSMutableArray instead of elements in void *buffer

 [myMatrix objectAtIndices:i,j,k]
 matrix object [i][j][k] is at bufferArray [ c[0] * i + c[1] * j + c[3] * k]
 internally: matrix object [i][j][k] is at bufferArray [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2])  ]
 */
@interface BCObjectMatrix : NSObject



/**
    Number of dimensions of the matrix, ie. 
        1 is a 1 column vector, 
        2 is a m x n matrix
        3 is m x n x p matrix

 */
@property NSInteger dimension;

/** buffer to hold all the elements of the matrix
 
 */
@property NSMutableArray *buffer;

/** C-style array of NSIntegers to hold sizes of each dimenison.
    Array is of length [self dimension]
    v-length vector  -> dimensionSizes = [v]
    m x n matrix -> dimensionSizes= [m,n]
    m x n x p matrix -> dimensionSizes= [m,n,p]
 */
@property NSInteger *dimensionSizes;

/**  PRIVATE
 coeffecients for indexing into array buffer
 
 */
@property NSInteger *c; // coeffecients for indexing into array buffer

/** PRIVATE
an array to hold the indices when dereferencing an element

 */
@property NSInteger *index; 

/** initialize the matrix by giving its dimensionality, and an array of the size of each dimension
 
    @param d dimensionality of matrix
    @param sizes an array of NSInteger 

    @return BCObjectMatrix initialized with  [NSNumber numberWithInteger:0] for each element


 */
-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes;

/** PRIVATE
free the malloc'd buffers
 */
-(void)dealloc; 

/** total number of elements in matrix

    @return total number of elements in matrix
 */
-(NSInteger)count; 

/**
    variadic method
    returns object at matrix[i,j,k,...], with an index provided for every dimension
    @param firstIndex indices for each dimension
    @returns object reference at index i,j,k,., NOT a copy of the object
*/
-(id)objectAtIndices:(NSInteger) firstIndex,...;


 /** variadic method
 sets object into matrix[i,j,k,...]
 of course, # indices should == dimension
 but we can't check this ourselves
 @param object the object to be stored at given indices
 @param firstIndex indices for each dimension
 */

-(void)setObject:(id)object atIndices:(NSInteger) firstIndex,...; 

/**

transpose the object matrix,  so that m x n matrix becomes n x m


 */
-(BCObjectMatrix *)transpose;
@end
