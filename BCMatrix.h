//
//  BCMatrix.h
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import <Foundation/Foundation.h>

@class BCVector;

/**

 generic "matrix", really a multi-dimensional array that stores C numeric elements like integers or doubles.  
 
 Used by Xynk to store numbers associated with multi-dimensional tuples, eg. posthoc results between all possible group comparions.
 
 Memory for the array is allocated by calloc based on sizeof each element (_elementSize).
 
 elements in the matrix are stored in a C-style linear array (_buffer), where we find each element by dereferencing into the linear array by each dimensional coordinate

 [myMatrix elementAtIndices:i,j,k]
 matrix element [i][j][k] is at buffer [ c[0] * i + c[1] * j + c[3] * k]
 internally, matrix element [i][j][k] is at buffer [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2]) * elementSize]

@note parent class of BC2DMatrix and BCVector, which are used for wrappers of BLAS and LINPACK

*/
@interface BCMatrix : NSObject<NSCopying>

@property NSInteger dimension;
@property size_t elementSize;
@property void *buffer;
@property size_t bufferSize;
@property NSInteger *dimensionSizes; // maximum size of each dimension of array
@property NSInteger *c; // coeffecients for indexing into array buffer == product of lower dimensionSizes
@property NSInteger *index; // an array to hold the indices when dereferencing an element

/**
    initialize a new BCMatrix
    
    @param d dimension of the "matrix", i.e. 1 for a vector, 2 for an (m x n) matrix, 3 for a (m x n x p) 3-D matrix
    @param sizes an NSArray of NSNumbers, with the size of each of the d dimensions, i.e. [m,n] for d=2 matrix of size (m x n)
    @param iS size in bytes of each element of the matrix, i.e. if matrix contains doubles, iS will be sizeof(double)
    @return a new BCMatrix with all elements cleared to zero


*/

-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes forElementSize:(size_t)iS;

/** frees the malloc'd buffers.  

    Should be called automatically by ARC

*/
-(void)dealloc; // 

/**
    @return total number of elements in matrix
*/
-(NSInteger)count; 

/** variadic method
 
 @param firstIndex  a comma separared list of integers, being the n indices into the n-dimensional matrix
 @return a newly malloc'd chunk of memory with the contents of element at matrix[firstIndex,secondIndex,...]
*/
-(void *)copyOfElementAtIndices:(NSInteger) firstIndex,...; 
    
 /**
     variadic method
     copies element at address *element into matrix[firstIndex,secondIndex...]
     does not alter or retain the element which is passed in
     of course, # indices should == dimension
     element should be same size as elementSize
     but we can't check this ourselves
     
     @param element a C-pointer to the element to be copied into the matrix at given indices
     @param firstIndex a comma separared list of integers, being the n indices into the n-dimensional matrix
     
*/
-(void)setElement:(void *)element atIndices:(NSInteger) firstIndex,...; 



/**
 assuming matrix is composed of NSInteger elements, return sum of all elements -- only checking is an assert test of element size
*/
-(NSInteger)sumIntegerMatrix;

/**
    assuming matrix is composed of double elements, return sum of all elements -- only checking is an assert test of element size
    
    @note safer to use BC2DMatrix
*/
-(double)sumDoubleMatrix; 



@end

/** 2-dimensional double-valued matrix for use in linear algebra with BLAS and LINPACK
    
    @note the matrix is **column major**  (ie CblasColMajor)

*/
@interface BC2DMatrix: BCMatrix<NSCopying>

/** initialize new 2D double-valued (r x c) matrix

uses BCMatrix with dimensional size 2 and element size = sizeof(CGFloat)

@param r number of rows
@param c number of columns

@return newly initialzed BC2DMatrix, with all elements set to 0


*/
- (id)initWithRows:(NSInteger)r andColumns:(NSInteger)c;

/**
    @return number of rows in matrix
*/
- (NSInteger)numRows; 

/** number of columns in matrix

    @return number of columns in matrix
*/
- (NSInteger)numColumns;

/**
set value of an element of matrix at [r,c]

@param value the new value to be inserted at [r,c]
@param r the zero-indexed row of the matrix
@param c the zero-indexed column of the matrix

*/
- (void)setValue:(CGFloat)value atRow:(NSInteger)r  andColumn:(NSInteger)c;

/**
get the value of an element of matrix at [r,c]

@param r the zero-indexed row of the matrix
@param c the zero-indexed column of the matrix
@return  the value  at [r,c]
*/

- (CGFloat)getValueAtRow:(NSInteger)r  andColumn:(NSInteger)c; 

/** set an entire column from a C-array of values

@param c the zero-indexed column to be set
@param values C-pointer to the C-array of CGFloat values

*/
- (void)setColumn:(NSInteger)c withValues:(CGFloat *)values;

/** set an entire row from a C-array of values

@param r the zero-indexed row to be set
@param values C-pointer to the C-array of CGFloat values

*/
- (void)setRow:(NSInteger)r withValues:(CGFloat *)values;

/** set an entire column from an NSArray of NSNumber values

@param c the zero-indexed column to be set
@param values the NSArray of NSNumber values

*/
- (void)setColumn:(NSInteger)c withArray:(NSArray *)values;

/** set an entire row from an NSArray of NSNumber values

@param r the zero-indexed row to be set
@param values the NSArray of NSNumber values

*/

- (void)setRow:(NSInteger)r withArray:(NSArray *)values;

/** provides a string representation of matrix in form

[ a b c <br>
  d e f <br>
  g h i ] <br>

@return string representation of the matrix

*/
-(NSString *)toString;

// BLAS wrappers

/**  wrapper for cblass_dgemm

This function multiplies A * B and multiplies the resulting matrix by alpha. It then multiplies matrix C by beta. It stores the sum of these two products in matrix C.
Thus, it calculates either
C←αAB + βC
or
C←αBA + βC
with optional use of transposed forms of A, B, or both.

C can be nil

see https://developer.apple.com/documentation/accelerate/1513282-cblas_dgemm?language=objc

for a less buggy, better descripton see https://software.intel.com/content/www/us/en/develop/documentation/onemkl-developer-reference-c/top/blas-and-sparse-blas-routines/blas-routines/blas-level-3-routines/cblas-gemm.html 

@param B a BC2DMatrix to be multiplied with ourself (matrix A)
@param C a BC2DMatrix added to the product of αAB; can be nil
@param transposeAFlag YES if A should be transposed before the multiply; otherwise pass NO
@param transposeBFlag YES if B should be transposed before the multiply;  otherwise pass NO
@param alpha scalar multiplier α applied to product AB
@param beta scalar multiplier β applied to matrix C

@return a new BC2DMatrix containing αAB + βC


*/
-(BC2DMatrix *)multiplyWithMatrix:(BC2DMatrix *)B andAddMatrix:(BC2DMatrix *)C transposeMatrixA:(BOOL)transposeAFlag transposeMatrixB:(BOOL)transposeBFlag scaleAB:(CGFloat)alpha scaleC:(CGFloat)beta;


/** wrapper for cblas_dgemv

This function multiplies A * X (after transposing A, if needed) and multiplies the resulting matrix by alpha. It then multiplies vector Y by beta. It stores the sum of these two products in vector Y.
Thus, it calculates 
    Y ← αAX + βY
with optional use of the transposed form of A.

Y can be nil

see https://developer.apple.com/documentation/accelerate/1513338-cblas_dgemv

@param X a BCVector to be multiplied with ourself (matrix A)
@param Y a BCVector added to the product of αAX; can be nil
@param transposeFlag YES if A should be transposed before the multiply; otherwise pass NO
@param alpha scalar multiplier α applied to product AX
@param beta scalar multiplier β applied to vector Y

@return a new BCVector containing αAB + βC

*/
-(BCVector *)multiplyWithVector:(BCVector *)X andAddVector:(BCVector *)Y transposeMatrix:(BOOL)transposeFlag matrixScale:(CGFloat)alpha vectorScale:(CGFloat)beta;

/** calls more complete multiplyWithMatrix with nil defaults, no transposition, no vector addition, and no scaling 
 
 
*/

-(BC2DMatrix *)multiplyWithMatrix:(BC2DMatrix *)B;

/** calls more complete multiplyWithVector with nil defaults, no transposition, no vector addition, and no scaling 
 
 
*/

-(BC2DMatrix *)multiplyWithVector:(BCVector *)X;


/** transpose: convert self (n x m matrix) to tranposed (m x n) matrix.

@return new matrix with transpose of self

*/
-(BC2DMatrix *)transpose;

/** invert the matrix; wrapper for LAPACK routines DGETRF and DGETRI  


DGETRF from http://www.netlib.org/lapack/explore-html/dd/d9a/group__double_g_ecomputational_ga0019443faea08275ca60a734d0593e60.html#ga0019443faea08275ca60a734d0593e60


DGETRF computes an LU factorization of a general M-by-N matrix A
 using partial pivoting with row interchanges.

 The factorization has the form
    A = P * L * U
 where P is a permutation matrix, L is lower triangular with unit
 diagonal elements (lower trapezoidal if m > n), and U is upper
 triangular (upper trapezoidal if m < n).

 This is the right-looking Level 3 BLAS version of the algorithm.
 

DGETRI from http://www.netlib.org/lapack/explore-html/dd/d9a/group__double_g_ecomputational_ga56d9c860ce4ce42ded7f914fdb0683ff.html#ga56d9c860ce4ce42ded7f914fdb0683ff

DGETRI computes the inverse of a matrix using the LU factorization
 computed by DGETRF.

 This method inverts U and then computes inv(A) by solving the system
 inv(A)*L = inv(U) for inv(A).

@return nil if matrix is singular and its inverse could not be computed; otherwise inverse of matrix

*/
-(BC2DMatrix *)inversion;

/** wrapper for cblas_daxpy.
 
 The value computed is (alpha * A[i,j]) + B[i,j].
 we use vector addition, by passing in matrix buffer as a vector of length num_rows * num_columns
 
 @param B matrix to be added to αA, the product of α and self (matrix A)   
 @param alpha scalar multiplier α applied to matrix A
 @return a new 2DMatrix containing the sum αA + B
*/
-(BC2DMatrix *)addWithMatrix:(BC2DMatrix *)B scaleA:(CGFloat)alpha;

/** scale matrix by given scalar multiplier

Does not use BLAS routines, just carries out regular floating point multiplication of each matrix element

@param alpha scalar multiplier α applied to self (matrix A)
@return a new 2DMatrix containing product αA 

*/
-(BC2DMatrix *)scale:(CGFloat)alpha; 

/** return a matrix in which every element has been squared
 
*/
-(BC2DMatrix *)squaredElements; 

/** return sum of all elements;
  wrapper for BCMatrix sumDoubleMatrix
 */
-(CGFloat)sum;

@end


/** 1-dimensional double-valued vector (equivalent to a single colum 2D matrix) for use in linear algebra with BLAS and LINPACK

@note [vector transpose] returns a single-row 2D Matrix

*/
@interface BCVector: BC2DMatrix<NSCopying>

/** initialize a vector as a 1-column BC2DMatrix, with all elements set to 0

@param r the number of rows in the vector

*/
-(id)initWithRows:(NSInteger)r; 
/** set the value of a specific element in the vector

@param value the value to be set in vector
@param r the row of the vector to be set

*/
-(void)setValue:(CGFloat)value atRow:(NSInteger)r; 

/** set all the elements in the vector from the values in a C-style array

@param values a C-pointer to an array of CGFloat values, should be the same length as the size of the vector

*/
-(void)setValues:(CGFloat *)values;

/** get the value of a specific element in the vector
@param r row of element in vector
@return value of element at row r
*/
- (CGFloat)getValueAtRow:(NSInteger)r; 

/** transpose a vector (a 1 column matrix with n rows) into a 1-row matrix with n columns

    
    @return a single-row 2D Matrix

*/
-(BC2DMatrix *)transpose;

/**
 wrapper for cblas_daxpy.
 
 The value computed is (alpha * X[i]) + Y[i].
 
*/
-(BCVector *)addWithVector:(BCVector *)Y scaleX:(CGFloat)alpha;

/** wrapper for cblas_ddot

@param vector2 BCVector to be dotted with self
@return double = self • vector2

*/
-(CGFloat)dotProductWithVector:(BCVector *)vector2;

/** return a vector with each element squared.
 
 e.g. [1 2 3 4] --> [1 4 9 16]
 
 @return BCVector with each element the square of corresponding element in self
 
 */
-(BCVector *)squaredElements; 

/** wrapper for cblas_dnrm2

@return Euclidean length of self
*/
-(CGFloat)length;

/** wrapper for cblas_dzasum

@return sum of absolute values of each element in self
*/
-(CGFloat)absoluteSum;

/**
    get (signed) sum of vector elements by finding dot-product of self with a vector [1], 
    which we increment over by zero (so we don't have to construct a N-sized 1-vector)

    @return (signed) sum of vector elements
 */
-(CGFloat)sum;

@end

/** given two matrixes C and D, return CDC'
 we multiple C * D and then by C' (the tranpose of C), 
 in order to multiply each element of D by the square of each element of C 
 (so CDC' is matrix equivalent of c^2*d)
 
*/
BC2DMatrix *CalcCDCprime(BC2DMatrix *C, BC2DMatrix *D);


BC2DMatrix *CalcCMuA(BC2DMatrix *C, BCVector *mu,BCVector *A);

void testANOVA(void);
