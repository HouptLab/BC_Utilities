//
//  BCMatrix.m
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import "BCMatrix.h"
#include "BCArrayUtilities.h"
#import "Accelerate/Accelerate.h"

// TODO: PUT IN BUNCH OF ASSERTIONS TO MAKE SURE ROW & COLUMN WITHIN RANGE

@implementation BCMatrix

// [myMatrix elementAtIndices:i,j,k]
// matrix element [i][j][k] is at buffer [ c[0] * i + c[1] * j + c[3] * k]
// internally: matrix element [i][j][k] is at buffer [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2]) * elementSize ]


// TODO: refactor using NSMutableBytes, somewhat safer?
//@synthesize dimension;
//@synthesize elementSize;
//@synthesize buffer;
//@synthesize c;
//@synthesize dimensionSizes;
//@synthesize index;


-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes forElementSize:(size_t)eS; {
    
    assert( d > 0 );
    assert( d == [sizes count]);
    // must have specificed a maximum size for each dimension of the matrix
    
    self = [super init];
    
    if (self) {
        
        _buffer = NULL;
        _c = NULL;
        _index = NULL;
        _dimensionSizes = NULL;
        
        _dimension = d;
        
        _dimensionSizes = calloc(_dimension, sizeof(NSInteger)); // make sure zeroed
        // copy the maximum size for each _dimension into the _dimensionSizes array
        for (int i=0;i<[sizes count];i++) {
            _dimensionSizes[i] = [[sizes objectAtIndex:i] intValue];
        }

        // generate the coeffecient array as a product of the lower _dimensions
        _c = calloc(_dimension, sizeof(NSInteger));
        _c[0] = 1;
        for (int i=1;i<_dimension;i++) {
            _c[i] = _dimensionSizes[i-1] * _c[i-1];
        }
              
        _elementSize = eS;
        size_t num_buffer_elements = [self count];
        _bufferSize = [self count] * _elementSize;
        _buffer = calloc(num_buffer_elements,_elementSize); // zero the memory
        
        // make an array to hold the indices when dereferencing an element
        // and zero the memory
        _index = calloc(_dimension, sizeof(NSInteger));
        
        
    }
    
    return self;
    
}


- (id)copyWithZone:(NSZone*)zone; {

    NSMutableArray *dSizes = [NSMutableArray array];
    
    for (NSInteger i = 0; i< _dimension;i++) {
        [dSizes addObject: [NSNumber numberWithInteger: _dimensionSizes[i]]];
    }
    
    
    // create a new matrix of the same dimensions
    BCMatrix *matrixCopy = [[[self class] allocWithZone:zone] initWithDimension:_dimension andMaxCount:dSizes forElementSize:_elementSize];

    
    // copy over the elements from the source buffer
    memcpy(matrixCopy.buffer,self.buffer,self.bufferSize);

    return matrixCopy;

}

-(void)dealloc; {
    // free the malloc'd buffers

    if (NULL != _buffer) {  free(_buffer); }
    if (NULL != _dimensionSizes) {  free(_dimensionSizes); }
    if (NULL != _c) {  free(_c); }
    if (NULL != _index) {  free(_index); }
    
}

-(NSInteger)count; {
    // total number of elements in matrix

    return (productOfIntArray(_dimensionSizes, _dimension));
    
}

-(void *)copyOfElementAtIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // returns ptr to new malloc'd block of data with copy ofelement at matrix[firstIndex,...]
    // caller is responsible for free'ing this block
    

    va_list argumentList;
    
//    for (int i = 0; i < _dimension; i++) {
//        NSLog(@"DimensionSize %d = %ld",i, _dimensionSizes[i]);
//    }
    
    _index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;
    
    while (currentIndex < _dimension) {
        // As many times as we can get an argument of type "NSInteger"
        // that isn't nil, add it to self's contents.
        _index[currentIndex] = va_arg(argumentList, NSInteger);
        if (_index[currentIndex] >= _dimensionSizes[currentIndex]){
            NSLog(@"BCMatrix currentIndex:%ld _index[] = %ld _dimensionSizes[] = %ld", (long)currentIndex,  (long)_index[currentIndex], (long)_dimensionSizes[currentIndex]);
        }

        if (_index[currentIndex] >= _dimensionSizes[currentIndex]) {
            NSLog(@"BCMatrix copyElement:Out of bounds _index: %zd", (long)currentIndex);
            
                  assert( _index[currentIndex] < _dimensionSizes[currentIndex]);
            
            return NULL;
        }
        currentIndex++;
    }
    va_end(argumentList);
    
    size_t offset_into_buffer = 0;
    int i;
    for (i=0;i<_dimension;i++) {
        offset_into_buffer += _c[i] * _index[i];
        
    }
    
    assert(offset_into_buffer < [self count]);
//    NSLog(@"BCMatrix copyElement [%zd,%zd] offset: %zd",(long)_index[0],(long)_index[1],offset_into_buffer);

    offset_into_buffer *= _elementSize;
    
    void *elementCopy = calloc(_elementSize,_elementSize);
    
    memcpy(elementCopy,&(_buffer[offset_into_buffer]),_elementSize );
    
    return (elementCopy);
    
    
}

-(void)setElement:(void *)element atIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // copies element at address *element into matrix[firstIndex,...]
    // of course, # indices should == _dimension
    // element should be same size as _elementSize
    // but we can't check this ourselves

    
    va_list argumentList;
    
    _index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;

    while (currentIndex < _dimension) {
        // get as many arguments of type "NSInteger"
        // as we have _dimensions
        _index[currentIndex] = va_arg(argumentList, NSInteger);
        assert( _index[currentIndex] < _dimensionSizes[currentIndex]);
        if (_index[currentIndex] >= _dimensionSizes[currentIndex]) {
            NSLog(@"BCMatrix setElement Out of bounds _index: %zd", (long)currentIndex);
            return;
        }
        currentIndex++;
    }
    va_end(argumentList);
    
    size_t offset_into_buffer = 0;
    int i;
    for (i=0;i<_dimension;i++) {
        offset_into_buffer += _c[i] * _index[i];
    }
    
    
    assert(offset_into_buffer < [self count]);

// NSInteger myCount = [self count];
//    NSLog(@"dimension = %zd",_dimension);
//    NSLog(@"dimensionSizes[0] = %zd",_dimensionSizes[0]);
//    NSLog(@"dimensionSizes[1] = %zd",_dimensionSizes[0]);
//    NSLog(@"count = %zd",myCount);
//     NSLog(@"offset_into_buffer = %zd",offset_into_buffer);
//   NSLog(@"BCMatrix setElement [%zd,%zd] offset: %zd",(long)_index[0],(long)_index[1],offset_into_buffer);

    
    offset_into_buffer *= _elementSize;
    
    memcpy(&(_buffer[offset_into_buffer]),element,_elementSize);

}

-(NSInteger)sumIntegerMatrix; {
    
    assert(_elementSize == sizeof(NSInteger));
    
    NSInteger sum = 0;
    NSInteger numberOfElements = [self count];
    NSInteger i;
    NSInteger *intBuffer = (NSInteger *)_buffer;
    for (i=0;i<numberOfElements;i++) {
        sum+= intBuffer[i];
    }
    
    return sum;
}
-(CGFloat)sumDoubleMatrix; {
    
    assert(_elementSize == sizeof(CGFloat));

    CGFloat sum = 0.0;
    NSInteger numberOfElements = [self count];
    NSInteger i;
    CGFloat *doubleBuffer = (CGFloat *)_buffer;
    for (i=0;i<numberOfElements;i++) {
        sum+= doubleBuffer[i];
    }
    
    return sum;
}


@end



@implementation BC2DMatrix

- (id)initWithRows:(NSInteger)r andColumns:(NSInteger)c; {
    return [super initWithDimension:2 andMaxCount:[NSArray arrayWithObjects:[NSNumber numberWithInteger:r],[NSNumber numberWithInteger:c], nil] forElementSize:sizeof(CGFloat)];
}

- (id)copyWithZone:(NSZone*)zone; {

    // create a new matrix of the same dimensions
    BC2DMatrix *matrixCopy = [[[self class] allocWithZone:zone] initWithRows:[self numRows] andColumns:[self numColumns]];
    
    // copy over the elements from the source buffer
    memcpy(matrixCopy.buffer,self.buffer,self.bufferSize);

    return matrixCopy;

}

- (void)setValue:(CGFloat)value atRow:(NSInteger)r  andColumn:(NSInteger)c; {
    
    [self setElement:&value atIndices:r,c];
    
}
- (CGFloat *)getValueAtRow:(NSInteger)r  andColumn:(NSInteger)c; {
    
   return [self copyOfElementAtIndices:r,c];
    
}

- (NSInteger)numRows;  { return  self.dimensionSizes[0];}
- (NSInteger)numColumns; { return  self.dimensionSizes[1];}

- (void)setColumn:(NSInteger)c toValues:(CGFloat *)values; {
    for (NSInteger r = 0; r< self.dimensionSizes[0];r++){
        [self setElement:&(values[r]) atIndices:r,c];
    }
}
- (void)setRow:(NSInteger)r toValues:(CGFloat *)values; {
    for (NSInteger c = 0; c< self.dimensionSizes[1];c++){
        [self setElement:&(values[c]) atIndices:r,c];
    }
}
- (void)setColumn:(NSInteger)c toArray:(NSArray *)values; {
    for (NSInteger r = 0; r< self.dimensionSizes[0];r++){
        CGFloat value = [values[r] doubleValue];
        [self setElement:&value atIndices:r,c];
    }
}
- (void)setRow:(NSInteger)r toArray:(NSArray *)values; {
    for (NSInteger c = 0; c< self.dimensionSizes[1];c++){
        CGFloat value = [values[c] doubleValue];
        [self setElement:&value atIndices:r,c];
    }
}

-(NSString *)toString; {

    NSMutableString *string = [NSMutableString string];
    
    [string appendString:@"[ "];
    for (NSInteger row = 0; row < self.numRows; row++) {
        
        [string appendString:@"  "];
        if (row > 0) { [string appendString:@"  "];}
        
        for (NSInteger col = 0; col < self.numColumns; col++) {
            CGFloat *value = [self getValueAtRow:row andColumn:col];
            [string appendString:[NSString stringWithFormat:@"%.2lf  ",*value]];
        }
        if (row == (self.numRows - 1)) { [string appendString:@"  ]"]; }
        [string appendString:@"\n"];
    }
    
    return string;

}

-(BC2DMatrix *)multiplyWithMatrix:(BC2DMatrix *)B andAddMatrix:(BC2DMatrix *)C transposeMatrixA:(BOOL)transposeAFlag transposeMatrixB:(BOOL)transposeBFlag scaleAB:(CGFloat)alpha scaleC:(CGFloat)beta; {

    const enum CBLAS_ORDER matrix_order = CblasRowMajor;

  // matrix A -- ourself
    const enum CBLAS_TRANSPOSE matrixA_transpose = transposeAFlag ? CblasTrans  : CblasNoTrans;
    const int32_t matrixA_rows = (int32_t)[self numRows];
    const int32_t matrixA_columns = (int32_t)[self numColumns];
    const double matrixAB_alpha = alpha; // Scaling factor for the product of matrix A and matrix B.
    const double *matrixA_buffer = self.buffer;
    const int32_t matrixA_lda = matrixA_rows; // first dimension of MatrixA
    
    const int32_t matrixA_K =  matrixA_columns;

 // matrix B -- the other multiplicand
 
    const enum CBLAS_TRANSPOSE matrixB_transpose = transposeBFlag ? CblasTrans  : CblasNoTrans;
    const int32_t matrixB_rows = (int32_t)[B numRows];
    const int32_t matrixB_columns = (int32_t)[B numColumns];

    const double *matrixB_buffer = self.buffer;
    const int32_t matrixB_ldb = matrixB_rows; // first dimension of MatrixA
    
// matrix C -- will be added to the product of AB
// if nil passed in, then create an empty (all zero matrix) in its place
// result matrix is placed into what is passed in for C, so we pass in a copy of C to prevent overwrite.

    BC2DMatrix *resultMatrix = (nil == C) ?  [[BC2DMatrix alloc] initWithRows:matrixA_rows andColumns:matrixB_columns ] : [C copy];
    
    const double matrixC_beta = beta; // Scaling factor for the matrix C.
    const int32_t matrixC_ldc = (int32_t)[resultMatrix numRows];
    double *matrixC_buffer = resultMatrix.buffer ;


        // TODO: assert that rows and columns match between matrix and vector
        assert(matrixA_columns == matrixB_rows);

        cblas_dgemm(matrix_order,
            matrixA_transpose,
            matrixB_transpose,
            matrixA_rows,
            matrixA_columns,
            matrixA_K,
            matrixAB_alpha,
            matrixA_buffer,
            matrixA_lda,
            matrixB_buffer,
            matrixB_ldb,
            matrixC_beta,
            matrixC_buffer,
            matrixC_ldc);
            
            
    return resultMatrix;

 
}

/**
wrapper for cblas_dgemv

This function multiplies A * X (after transposing A, if needed) and multiplies the resulting matrix by alpha. It then multiplies vector Y by beta. It stores the sum of these two products in vector Y.
Thus, it calculates either
Y←αAX + βY
with optional use of the transposed form of A.

see https://developer.apple.com/documentation/accelerate/1513338-cblas_dgemv

*/
-(BCVector *)multiplyWithVector:(BCVector *)X andAddVector:(BCVector *)Y transposeMatrix:(BOOL)transposeFlag matrixScale:(CGFloat)alpha vectorScale:(CGFloat)beta; {

    const enum CBLAS_ORDER matrix_order = CblasRowMajor;

    // matrix A -- ourself
    const enum CBLAS_TRANSPOSE matrixA_transpose = transposeFlag ? CblasTrans  : CblasNoTrans;
    const int32_t matrixA_rows = (int32_t)[self numRows];
    const int32_t matrixA_columns = (int32_t)[self numColumns];
    const double matrixA_alpha = alpha; // Scaling factor for the product of matrix A and vector X.
    const double *matrixA_buffer = self.buffer;
    const int32_t matrixA_lda = matrixA_rows; // first dimension of MatrixA


     // vector X -- vector passed in 
    const double *vectorX_buffer = X.buffer;
    const int32_t vectorX_inc = 1; // Stride within X. For example, if incX is 7, every 7th element is used.
     
    // result vector Y -- vector passed in to add to product of ourselves and vector X
        // if nil passed in, then create an empty (all zero vector) in its place
// result vector is placed into what is passed in for Y, so we pass in a copy of Y to prevent overwrite.

    BCVector *resultVector = (nil == Y) ?  [[BCVector alloc] initWithRows:matrixA_rows ] : [Y copy];

    const double vectorY_beta = beta; // Scaling factor for vector Y.
    double *vectorY_buffer = resultVector.buffer;
    const int32_t vectorY_inc = 1; // Stride within Y. For example, if incY is 7, every 7th element is used.

// TODO: assert that rows and columns match between matrix and vector
    assert([self numColumns] == [X numRows]);
    assert([self numColumns] == [resultVector numRows]);


    cblas_dgemv( 
        matrix_order,
        matrixA_transpose,
        matrixA_rows,
        matrixA_columns,
        matrixA_alpha,
        matrixA_buffer,
        matrixA_lda,
        vectorX_buffer,
        vectorX_inc,
        vectorY_beta,
        vectorY_buffer,
        vectorY_inc);


    return resultVector;
    
}
-(BCMatrix *)multiplyWithScalar:(CGFloat *)scaler; {
    return nil;
}

/**

wrapper for LAPACK routines DGETRF and DGETRI  

 ----------------------------------


DGETRF

from http://www.netlib.org/lapack/explore-html/dd/d9a/group__double_g_ecomputational_ga0019443faea08275ca60a734d0593e60.html#ga0019443faea08275ca60a734d0593e60

subroutine dgetrf    (    integer     M,
integer     N,
double precision, dimension( lda, * )     A,
integer     LDA,
integer, dimension( * )     IPIV,
integer     INFO 
)    

DGETRF computes an LU factorization of a general M-by-N matrix A
 using partial pivoting with row interchanges.

 The factorization has the form
    A = P * L * U
 where P is a permutation matrix, L is lower triangular with unit
 diagonal elements (lower trapezoidal if m > n), and U is upper
 triangular (upper trapezoidal if m < n).

 This is the right-looking Level 3 BLAS version of the algorithm.
 
 [in]    M    
          M is INTEGER
          The number of rows of the matrix A.  M >= 0.
[in]    N    
          N is INTEGER
          The number of columns of the matrix A.  N >= 0.
[in,out]    A    
          A is DOUBLE PRECISION array, dimension (LDA,N)
          On entry, the M-by-N matrix to be factored.
          On exit, the factors L and U from the factorization
          A = P*L*U; the unit diagonal elements of L are not stored.
[in]    LDA    
          LDA is INTEGER
          The leading dimension of the array A.  LDA >= max(1,M).
[out]    IPIV    
          IPIV is INTEGER array, dimension (min(M,N))
          The pivot indices; for 1 <= i <= min(M,N), row i of the
          matrix was interchanged with row IPIV(i).
[out]    INFO    
          INFO is INTEGER
          = 0:  successful exit
          < 0:  if INFO = -i, the i-th argument had an illegal value
          > 0:  if INFO = i, U(i,i) is exactly zero. The factorization
                has been completed, but the factor U is exactly
                singular, and division by zero will occur if it is used
                to solve a system of equations.
 
 ----------------------------------

DGETRI

from http://www.netlib.org/lapack/explore-html/dd/d9a/group__double_g_ecomputational_ga56d9c860ce4ce42ded7f914fdb0683ff.html#ga56d9c860ce4ce42ded7f914fdb0683ff

subroutine dgetri    (    integer     N,
double precision, dimension( lda, * )     A,
integer     LDA,
integer, dimension( * )     IPIV,
double precision, dimension( * )     WORK,
integer     LWORK,
integer     INFO 
)    

DGETRI computes the inverse of a matrix using the LU factorization
 computed by DGETRF.

 This method inverts U and then computes inv(A) by solving the system
 inv(A)*L = inv(U) for inv(A).
 
[in]    N    
          N is INTEGER
          The order of the matrix A.  N >= 0.
[in,out]    A    
          A is DOUBLE PRECISION array, dimension (LDA,N)
          On entry, the factors L and U from the factorization
          A = P*L*U as computed by DGETRF.
          On exit, if INFO = 0, the inverse of the original matrix A.
[in]    LDA    
          LDA is INTEGER
          The leading dimension of the array A.  LDA >= max(1,N).
[in]    IPIV    
          IPIV is INTEGER array, dimension (N)
          The pivot indices from DGETRF; for 1<=i<=N, row i of the
          matrix was interchanged with row IPIV(i).
[out]    WORK    
          WORK is DOUBLE PRECISION array, dimension (MAX(1,LWORK))
          On exit, if INFO=0, then WORK(1) returns the optimal LWORK.
[in]    LWORK    
          LWORK is INTEGER
          The dimension of the array WORK.  LWORK >= max(1,N).
          For optimal performance LWORK >= N*NB, where NB is
          the optimal blocksize returned by ILAENV.

          If LWORK = -1, then a workspace query is assumed; the routine
          only calculates the optimal size of the WORK array, returns
          this value as the first entry of the WORK array, and no error
          message related to LWORK is issued by XERBLA.
[out]    INFO    
          INFO is INTEGER
          = 0:  successful exit
          < 0:  if INFO = -i, the i-th argument had an illegal value
          > 0:  if INFO = i, U(i,i) is exactly zero; the matrix is
                singular and its inverse could not be computed.

*/


-(BCMatrix *)inversion; {

// 1. LU Factorization with dgetrf_
// 2. matrix inversion dgetri_


    BC2DMatrix *invertedMatrix = [[BC2DMatrix alloc] initWithRows: [self numColumns] andColumns:[self numRows]];
    // note num of rows and columns flipped
    // copy our  buffer into this BC2DMatrix object, which will be replaced with inverted matrix results
    memcpy(invertedMatrix.buffer,self.buffer,self.bufferSize);
    
    
// 1. LU Factorization 

    __CLPK_integer matrixA_rows = (__CLPK_integer)[self numRows]; // M
    __CLPK_integer matrixA_columns = (__CLPK_integer)[self numColumns]; // N
    __CLPK_integer matrixA_lda = matrixA_rows; // leading dimension of matrix A
    __CLPK_doublereal *matrixA_buffer = (__CLPK_doublereal *)invertedMatrix.buffer; // DOUBLE PRECISION array, dimension (LDA,N)
    __CLPK_integer *pivot_buffer =  calloc(MIN(matrixA_rows,matrixA_columns),sizeof(__CLPK_integer));
    __CLPK_integer lwork = matrixA_columns;
    __CLPK_doublereal *work_buffer = calloc(lwork,sizeof(__CLPK_doublereal));
    __CLPK_integer info = 0;


    /*  LU factorisation */
    
   dgetrf_(    
    &matrixA_rows,
    &matrixA_columns,
    matrixA_buffer,
    &matrixA_lda,
    pivot_buffer,
    &info 
    );   


    if (info == 0) {
    
    // run workspace query to get optimal size of work_buffer
        /* workspace query */
        lwork = -1;
        dgetri_(    
            &matrixA_rows,
            matrixA_buffer,
            &matrixA_lda,
            pivot_buffer,
            work_buffer,
            &lwork,
            &info 
        );
        
        // found optimal size, now allocate work_buffer
        lwork = (__CLPK_integer)work_buffer[0]; 
        work_buffer = calloc(lwork,sizeof(__CLPK_doublereal));
        
// 2. matrix inversion dgetri_

        /*  matrix inversion */
        dgetri_(    
            &matrixA_rows,
            matrixA_buffer,
            &matrixA_lda,
            pivot_buffer,
            work_buffer,
            &lwork,
            &info 
        );
    }

    free(pivot_buffer);
    free(work_buffer);
    
    if (info != 0) {
        NSLog(@"Error 1");
        return nil;
    }
    
    return invertedMatrix;
}

@end


@implementation BCVector

- (id)initWithRows:(NSInteger)r; {
  //  return [super initWithDimension:1 andMaxCount:[NSArray arrayWithObjects:[NSNumber numberWithInteger:r], nil] forElementSize:sizeof(CGFloat)];
  
  return [super initWithRows:r andColumns:1];
}

- (id)copyWithZone:(NSZone*)zone; {

    // create a new matrix of the same dimensions
    BCVector *vectorCopy = [[[self class] allocWithZone:zone] initWithRows:[self numRows]];
    
    // copy over the elements from the source buffer
    memcpy(vectorCopy.buffer,self.buffer,self.bufferSize);

    return vectorCopy;

}

- (void)setValue:(CGFloat)value atRow:(NSInteger)r; {
    
    [self setElement:&value atIndices:r,0];
    
}

-(void)setValues:(CGFloat *)values; {
    [self setColumn:0 toValues:values]; 
}

-(BCMatrix *)multiplyWithMatrix:(BCVector *)vector2; {

return nil;
}
/**
 wrapper for cblas_daxpy.
 
 The value computed is (alpha * X[i]) + Y[i].
 
*/
-(BCVector *)addWithVector:(BCVector *)Y scaleX:(CGFloat)alpha; {

    
    assert([self numRows] == [Y numRows]);
    
    BCVector *productVector = [Y copy];
    
    const int32_t vector_N = (const int32_t)[self numRows];
    const double vectorX_alpha = alpha;
    const double *vectorX_values = (const double *)self.buffer;
    double *vectorY_values = (double *)productVector.buffer;
    const int32_t incX = 1;
    const int32_t incY = 1;
    // On return, the contents of vector Y are replaced with the result. 
    // The value computed is (alpha * X[i]) + Y[i].
    cblas_daxpy(vector_N, vectorX_alpha, vectorX_values, incX,vectorY_values, incY);

    return productVector;


}
/**

wrapper for cblas_ddot

*/

-(CGFloat)dotProductWithVector:(BCVector *)Y; {

    assert([self numRows] == [Y numRows]);
    
    const int32_t vector_N = (const int32_t)[self numRows];
    const double *vectorX_values = (const double *)self.buffer;
    const double *vectorY_values = (const double *)Y.buffer;
    const int32_t incX = 1;
    const int32_t incY = 1;

    return cblas_ddot(vector_N, vectorX_values, incX,vectorY_values, incY);
    
}

/**
    wrapper for cblas_dnrm2
*/

-(CGFloat)length; {

    const int32_t vector_N = (const int32_t)[self numRows];
    const double *vector_values = (const double *)self.buffer;
    const int32_t incX = 1;
    
    return cblas_dnrm2(vector_N,vector_values,incX);

}
/**
    wrapper for cblas_dzasum
*/
-(CGFloat)absoluteSum; {

    const int32_t vector_N = (const int32_t)[self numRows];
    const double *vector_values = (const double *)self.buffer;
    const int32_t incX = 1;
    
    return cblas_dzasum(vector_N,vector_values,incX);

}


@end

/*
 

 // Cµ - a
 
  Double scale_by_1 = 1.0;
 
 // C matrix
 CBLAS_ORDER C_order = CblasRowMajor;
 CBLAS_TRANSPOSE C_transpose = CblasNoTrans;
 Int32 C_rows = C.numRows;
 Int32 C_columns = C.numColumns;

 UnsafePointer<Double>! C_matrix_buffer = C.buffer;
 // µ vector
 UnsafePointer<Double>! mu_vector_buffer = Mu.buffer;
 Int32 mu_inc = 1;
 
 
 // Cµ result vector
 // set initial result buffer to zeroes
  UnsafeMutablePointer<Double>!C_Mu_vector_buffer = C_Mu.buffer;
 Double  C_Mu_beta = 1.0;
 Int32 C_Mu_inc = 1;
 Int32 C_Mu_size = C.numRows;
 
 // a vector
 // NB: will be replaced with result of Cµ-a !
  UnsafeMutablePointer<Double>! a_vector_buffer = a.buffer;
  Int32 a_inc = 1;
  Int32 a_size = C.numRows;
 
// https://developer.apple.com/documentation/accelerate/1513338-cblas_dgemv
cblas_dgemv( 
    C_order,
    C_transpose,
    C_rows,
    C_columns,
    scale_by_1,
    C_matrix_buffer,
    C_lda,
    mu_vector_buffer,
    mu_inc,
    scale_by_1,
    C_Mu_vector_buffer,
    C_Mu_inc);
 
 // add a to Cµ
 func cblas_daxpy(
   C_Mu_size, 
   scale_by_1,
   C_MU_vector_buffer, 
   C_Mu_inc, 
   a_vector_buffer, 
   a_inc);
 
 
 // CDC'
 CBLAS_TRANSPOSE D_transpose = CblasNoTrans;
 Int32 D_rows = D.numRows;
 Int32 D_columns = D.numColumns;
 Int32 D_ld = D.numRows;
 UnsafePointer<Double>! D_matrix_buffer = D.buffer;
 
 // NB: DC.buffer should be zeroes, replaced with result
 UnsafeMutablePointer<Double>! CD_matrix_buffer = DC.buffer
 Int32 CD_rows = C_rows;
 Int32 CD_ld = C_rows;
 
 //multiple C and D, put result in CD_matrix_buffer
 func cblas_dgemm(
    C_order, 
    C_transpose, 
    D_transpose, 
    C_rows, 
    D_columns, 
    C_columns, 
    scale_by_1, 
    C_matrix_buffer, 
    C_ld, 
    D_matrix_buffer UnsafePointer<Double>!, 
    D_ld, 
    scale_by_1, 
    CD_matrix_buffer,
    CD_ld);
 
 // multiple CD and C', put result in CDCprime_matrix_buffer
 CBLAS_TRANSPOSE CD_transpose = CblasNoTrans;
 CBLAS_TRANSPOSE Cprime_transpose = CblasTrans;
 
 // NB: CDC.buffer should be zeroes, replaced with result
 UnsafeMutablePointer<Double>! CDCp_matrix_buffer = CDCp.buffer
// Int32 CDCp_rows ;
// Int32 CDCp_columns ;
 Int32 CDCp_ld = CDCp_rows;
 
 func cblas_dgemm(
     C_order, 
     CD_transpose, 
     Cprime_transpose, 
     CD_rows, 
     CDCp_columns, 
     CD_columns, 
     scale_by_1, 
     CD_matrix_buffer, 
     CD_ld, 
     C_matrix_buffer UnsafePointer<Double>!, 
     C_ld, 
     scale_by_1, 
     CDCp_matrix_buffer,
     CDCp_ld);
 
 // CDCp_matrix_buffer should now contain CDC'
 
 */

/* test of matrix operations */

void testANOVA(void) {

// Milliken and Johnson Example 1.2 */

NSUInteger numGroups = 6;
CGFloat groupMeans[6];
groupMeans[0]=31.923;
groupMeans[1]=31.083;
groupMeans[2]=35.8;
groupMeans[3]=38.0;
groupMeans[4]=29.5;
groupMeans[5]=28.818;

CGFloat groupSizes[6];
groupSizes[0]=13;
groupSizes[1]=12;
groupSizes[2]=10;
groupSizes[3]=10;
groupSizes[4]=12;
groupSizes[5]=11;

// C -- coefficients matrix[numGroups,numGroups]

BC2DMatrix *C = [[BC2DMatrix alloc] initWithRows:numGroups-1 andColumns:numGroups];

for (NSUInteger row = 0; row < numGroups-1; row++) {
    for (NSUInteger col = 0; col< numGroups; col++) {

        CGFloat entry = 0;
        if (0 == col) { entry = 1;}
        else if (col == row + 1) { entry = -1; }
    
       [C setValue:entry atRow:row andColumn:col];
    
    }
}

NSLog(@"C = \n%@",[C toString]);

// D -- diagonal denominator matrix[numGroups,numGroups] of (1/n)s

BC2DMatrix *D = [[BC2DMatrix alloc] initWithRows:numGroups andColumns:numGroups];

for (NSUInteger row = 0; row < numGroups; row++) {
    for (NSUInteger col = 0; col < numGroups; col++) {
        
        CGFloat entry = 0;
        if (row == col) { 
            entry = 1.0 / groupSizes[col];
        }
         [D setValue:entry atRow:row andColumn:col];
    }
}

NSLog(@"D = \n%@",[D toString]);

// mu -- mean vector[numGroups]

BCVector *mu = [[BCVector alloc] initWithRows:numGroups];

[mu setValues:groupMeans];

NSLog(@"mu = \n%@",[mu toString]);

// a -- constant vector[numGroups] for testing hypothesis C x mu = a

BCVector *a = [[BCVector alloc] initWithRows:numGroups];
// initialized to zero

NSLog(@"a = \n%@",[a toString]);

BC2DMatrix *C_copy = [C copy];
NSLog(@"C_copy = \n%@",[C_copy toString]);
}

