//
//  BCMatrix.h
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import <Foundation/Foundation.h>

@class BCVector;

// [myMatrix elementAtIndices:i,j,k]
// matrix element [i][j][k] is at buffer [ c[0] * i + c[1] * j + c[3] * k]
// internally, matrix element [i][j][k] is at buffer [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2]) * elementSize]




@interface BCMatrix : NSObject<NSCopying>

@property NSInteger dimension;
@property size_t elementSize;
@property void *buffer;
@property size_t bufferSize;
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


-(NSInteger)sumIntegerMatrix;
// assuming matrix is composed of NSInteger elements, return sum of all elements -- only checking is an assert test of element size

-(double)sumDoubleMatrix; 
// assuming matrix is composed of double elements, return sum of all elements -- only checking is an assert test of element size


@end

@interface BC2DMatrix: BCMatrix<NSCopying>

- (id)initWithRows:(NSInteger)r andColumns:(NSInteger)c;
- (NSInteger)numRows; 
- (NSInteger)numColumns;
- (void)setValue:(CGFloat)value atRow:(NSInteger)r  andColumn:(NSInteger)c;
- (CGFloat *)getValueAtRow:(NSInteger)r  andColumn:(NSInteger)c; 
- (void)setColumn:(NSInteger)c toValues:(CGFloat *)values;
- (void)setRow:(NSInteger)r toValues:(CGFloat *)values;
- (void)setColumn:(NSInteger)c toArray:(NSArray *)values;
- (void)setRow:(NSInteger)r toArray:(NSArray *)values;

-(NSString *)toString;

// BLAS wrappers

/** multiplyWithMatrix:andAddMatrix:transposeMatrixA:transposeMatrixB:scaleAB:scaleC:

wrapper for cblass_dgemm

This function multiplies A * B and multiplies the resulting matrix by alpha. It then multiplies matrix C by beta. It stores the sum of these two products in matrix C.
Thus, it calculates either
C←αAB + βC
or
C←αBA + βC
with optional use of transposed forms of A, B, or both.

C can be nil

see https://developer.apple.com/documentation/accelerate/1513282-cblas_dgemm?language=objc
*/


-(BC2DMatrix *)multiplyWithMatrix:(BC2DMatrix *)B andAddMatrix:(BC2DMatrix *)C transposeMatrixA:(BOOL)transposeAFlag transposeMatrixB:(BOOL)transposeBFlag scaleAB:(CGFloat)alpha scaleC:(CGFloat)beta;


/** multiplyWithVector:andAddVector:transposeMatrix:matrixScale:vectorScale

wrapper for cblas_dgemv

This function multiplies A * X (after transposing A, if needed) and multiplies the resulting matrix by alpha. It then multiplies vector Y by beta. It stores the sum of these two products in vector Y.
Thus, it calculates either
Y←αAX + βY
with optional use of the transposed form of A.

Y can be nil

see https://developer.apple.com/documentation/accelerate/1513338-cblas_dgemv

*/
-(BCVector *)multiplyWithVector:(BCVector *)X andAddVector:(BCVector *)Y transposeMatrix:(BOOL)transposeFlag matrixScale:(CGFloat)alpha vectorScale:(CGFloat)beta;

@end


// assumed to be column vector; [vector transposed] returns a single row 2D Matrix
@interface BCVector: BC2DMatrix<NSCopying>

-(id)initWithRows:(NSInteger)r; 
-(void)setValue:(CGFloat)value atRow:(NSInteger)r; 
-(void)setValues:(CGFloat *)values;
-(BCMatrix *)multiplyWithMatrix:(BCVector *)vector2;
-(BCVector *)addWithVector:(BCVector *)vector2 ;
-(CGFloat)dotProductWithVector:(BCVector *)vector2;
-(CGFloat)length;
-(CGFloat)absoluteSum;
@end

/** given two matrixes C and D, return CDC'
 we multiple C * D and then by C' (the tranpose of C), 
 in order to multiply each element of D by the square of each element of C 
 (so CDC' is matrix equivalent of c^2*d)
 
*/
BC2DMatrix *CalcCDCprime(BC2DMatrix *C, BC2DMatrix *D);


BC2DMatrix *CalcCMuA(BC2DMatrix *C, BCVector *mu,BCVector *A);

void testANOVA(void);
