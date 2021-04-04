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

-(BC2DMatrix *)multiplyWithMatrix:(BC2DMatrix *)B andAddMatrix:(BC2DMatrix *)C transposeMatrixA:(BOOL)transposeAFlag transposeMatrixB:(BOOL)transposeBFlag scaleAB:(CGFloat)scaleAB scaleC:(CGFloat)scaleC; {

    const enum CBLAS_ORDER matrix_order = CblasColMajor;

  // matrix A -- ourself
    const enum CBLAS_TRANSPOSE transA = (transposeAFlag) ? CblasTrans  : CblasNoTrans;
    const int32_t  m = (CblasNoTrans == transA) ? (int32_t)[self numRows] : (int32_t)[self numColumns]; // matrixA_rows
    const int32_t k  = (CblasNoTrans == transA) ? (int32_t)[self numColumns] : (int32_t)[self numRows]; // matrixA_columns
    const double alpha = scaleAB; // Scaling factor for the product of matrix A and matrix B.
    const double *a= self.buffer; // matrixA_buffer 

//    for (int i=0;i<9;i++) {
//                NSLog(@"A: %d %lf",i,matrixA_buffer[i]);
//
//    }
    
    
    int32_t lda = m;
    
    if (CblasNoTrans == transA && CblasColMajor == matrix_order) {
         lda = m; 
    } else if  (CblasNoTrans == transA && CblasRowMajor == matrix_order) {
         lda = k; 
    } else if (CblasNoTrans != transA && CblasColMajor == matrix_order) {
        lda = k; 
    } else if (CblasNoTrans != transA && CblasRowMajor == matrix_order) {
        lda = m; 
    }
    
 // matrix B -- the other multiplicand
 
    const enum CBLAS_TRANSPOSE transB = transposeBFlag ? CblasTrans  : CblasNoTrans;
    const int32_t n = (CblasNoTrans == transB) ? (int32_t)[B numColumns] : (int32_t)[B numRows];
    const int32_t matrixB_rows = (CblasNoTrans == transB) ? (int32_t)[B numRows] : (int32_t)[B numColumns];

    const double *b = B.buffer; //matrixB_buffer
    // NOTE: intel says ldb should be flipped? but this way works
     int32_t ldb = 1;
    
  
    if (CblasNoTrans == transB && CblasColMajor == matrix_order) {
         ldb = k; 
    } else if  (CblasNoTrans == transB && CblasRowMajor == matrix_order) {
         ldb = n; 
    } else if (CblasNoTrans != transB && CblasColMajor == matrix_order) {
        ldb =  n; 
    } else if (CblasNoTrans != transB && CblasRowMajor == matrix_order) {
        ldb = k; 
    }
    
    
//    for (int i=0;i<9;i++) {
//        NSLog(@"B: %d %lf",i,matrixB_buffer[i]);
//    }
    

    
// matrix C -- will be added to the product of AB
// if nil passed in, then create an empty (all zero matrix) in its place
// result matrix is placed into what is passed in for C, so we pass in a copy of C to prevent overwrite.

        const double beta = scaleC; // Scaling factor for the matrix C.

// NOTE: not sure about this and how it interacts with transposed A or B
    const int32_t ldc = (CblasColMajor == matrix_order) ? m : n;
    const int32_t matrixC_rows = ldc;
    const int32_t matrixC_columns = (CblasColMajor == matrix_order) ? n : m;
    
    BC2DMatrix *resultMatrix = (nil == C) ?  [[BC2DMatrix alloc] initWithRows:matrixC_rows andColumns:matrixC_columns ] : [C copy];
    double *c = resultMatrix.buffer ; //matrixC_buffer

        // TODO: assert that rows and columns match between matrix and vector
       // assert(matrixA_columns == matrixB_rows);

    NSLog(@"A:[%d,%d] B:[%d,%d] C:[%d,%d]",
    m,k,
    k,n,
    matrixC_rows,matrixC_columns);

   // assert(matrixB_rows == k);


        cblas_dgemm(
            matrix_order, // Order
            transA, // TransA
            transB, // TransB
            m, // M
            n, // N
            k, // K
            alpha,  // alpha
            a, //A
            lda, //lda
            b, //B
            ldb, // ldb
            beta, // beta
            c, // C
            ldc // ldc
            );
    

        
    return resultMatrix;

 
}

/**
wrapper for cblas_dgemv

This function multiplies matrix A * vector X (after transposing A, if needed) and multiplies the resulting matrix by alpha. It then multiplies vector Y by beta. It stores the sum of these two products in vector Y.
Thus, it calculates either
Y←αAX + βY
with optional use of the transposed form of A.

see https://developer.apple.com/documentation/accelerate/1513338-cblas_dgemv

*/
-(BCVector *)multiplyWithVector:(BCVector *)X andAddVector:(BCVector *)Y transposeMatrix:(BOOL)transposeFlag matrixScale:(CGFloat)matrixScale vectorScale:(CGFloat)vectorScale; {

    const enum CBLAS_ORDER matrix_order = CblasColMajor;

    // matrix A -- ourself
    const enum CBLAS_TRANSPOSE trans = transposeFlag ? CblasTrans  : CblasNoTrans;
    const int32_t  m = (trans == CblasNoTrans) ? (int32_t)[self numRows] : (int32_t)[self numColumns]; // matrixA_rows
    const int32_t  n = (trans == CblasNoTrans) ? (int32_t)[self numColumns] : (int32_t)[self numRows]; //matrixA_columns
    const double alpha = matrixScale; // Scaling factor for the product of matrix A and vector X.
    const double *a = self.buffer;
    const int32_t lda = (matrix_order == CblasColMajor) ? m : n; // first dimension of MatrixA


     // vector X -- vector passed in 
    const double *x = X.buffer;
    const int32_t incx = 1; // Stride within X. For example, if incX is 7, every 7th element is used.
    const int32_t expected_vectorX_rows = n;
    
   
     
    // result vector Y -- vector passed in to add to product of ourselves and vector X
        // if nil passed in, then create an empty (all zero vector) in its place
// result vector is placed into what is passed in for Y, so we pass in a copy of Y to prevent overwrite.

    const int32_t expected_vectorY_rows = m;
    BCVector *resultVector = (nil == Y) ?  [[BCVector alloc] initWithRows:expected_vectorY_rows ] : [Y copy];

    const double beta = vectorScale; // Scaling factor for vector Y.
    double *y = resultVector.buffer;
    const int32_t incy = 1; // Stride within Y. For example, if incY is 7, every 7th element is used.

// TODO: assert that rows and columns match between matrix and vector
 assert(expected_vectorX_rows == [X numRows]);


    cblas_dgemv( 
        matrix_order, // CblasColMajor or CblasRowMajor; BC2DMatrix is CblasColMajor
        trans, // CblasNoTrans or CblasTrans; value of transposeFlag, whether to transpose matrix A (which is us)
        m, // rows in matrix A after trans operation
        n, // cols in matrix A after trans operation
        alpha, // scalar to scale matrix A
        a, // pointer to buffer of matrix A
        lda, // leading dimension of matrix A; numColumns if CblasColMajor, or numRows if CblasRowMajor
        x, // pointer to buffer of vector X
        incx, // stride into vector X -- we assume we use all of vector X, so incx = 1
        beta, // scalar to scale vector Y
        y, // pointer to buffer of vector Y, which will be overwritten with result vector
        incy // stride into vector Y -- we assume we use all of vector Y, so incy = 1
        );


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


-(BC2DMatrix *)inversion; {

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

-(BC2DMatrix *)transpose; {
// return a 1 x m martix (ie. turn vector sideways)

    BC2DMatrix *transposed = [[BC2DMatrix alloc] initWithRows: [self numColumns] andColumns: [self numRows]];

    for(NSInteger c = 0;  c < [self numColumns]; c++) {
        for(NSInteger r = 0; r < [self numRows]; r++) {
            [transposed setValue: *[self getValueAtRow:r andColumn: c]  atRow:c andColumn: r];
        }
    }
    
    return transposed;
}

/**
 wrapper for cblas_daxpy.
 
 The value computed is (alpha * A[i,j]) + B[i,j].
 we use vector addition, by passing in matrix buffer as a vector of length num_rows * num_columns
 
*/
-(BC2DMatrix *)addWithMatrix:(BC2DMatrix *)B scaleA:(CGFloat)alpha; {

    
    assert([self numRows] == [B numRows]);
    assert([self numColumns] == [B numColumns]);
    
    BC2DMatrix *sumMatrix = [B copy];
    
    const int32_t vector_N = (int32_t)[self numRows] * (int32_t)[self numColumns];
    const double vectorX_alpha = alpha;
    const double *vectorX_values = (const double *)self.buffer;
    double *vectorY_values = (double *)sumMatrix.buffer;
    const int32_t incX = 1;
    const int32_t incY = 1;
    // On return, the contents of vector Y are replaced with the result. 
    // The value computed is (alpha * X[i]) + Y[i].
    cblas_daxpy(vector_N, vectorX_alpha, vectorX_values, incX,vectorY_values, incY);

    return sumMatrix;

}

/**
scale matrix elements by alpha
*/
-(BC2DMatrix *)scale:(CGFloat)alpha; {

    BC2DMatrix *scaled = [self copy];

    CGFloat *double_buffer = self.buffer;
    
    for (NSInteger i = 0;  i < [self numColumns] * [self numRows]; i++) {
        double_buffer[i] = alpha * double_buffer[i];
    }
    
    return scaled;
    
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

- (CGFloat *)getValueAtRow:(NSInteger)r; {

 return [self getValueAtRow:r andColumn:0];    
}

-(void)setValues:(CGFloat *)values; {
    [self setColumn:0 toValues:values]; 
}


/**
 wrapper for cblas_daxpy.
 
 The value computed is (alpha * X[i]) + Y[i].
 
*/
-(BCVector *)addWithVector:(BCVector *)Y scaleX:(CGFloat)alpha; {

    
    assert([self numRows] == [Y numRows]);
    
    BCVector *sumVector = [Y copy];
    
    const int32_t vector_N = (const int32_t)[self numRows];
    const double vectorX_alpha = alpha;
    const double *vectorX_values = (const double *)self.buffer;
    double *vectorY_values = (double *)sumVector.buffer;
    const int32_t incX = 1;
    const int32_t incY = 1;
    // On return, the contents of vector Y are replaced with the result. 
    // The value computed is (alpha * X[i]) + Y[i].
    cblas_daxpy(vector_N, vectorX_alpha, vectorX_values, incX,vectorY_values, incY);

    return sumVector;


}

-(BC2DMatrix *) transpose; {

    return [super transpose];
    
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

// C -- coefficients matrix[numGroups-1,numGroups] for testing hypothesis that group1_mean = coefficient(N-1,N) * groupN_mean

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

// a -- constant vector[numGroups-1] for testing hypothesis C x mu = a

BCVector *a = [[BCVector alloc] initWithRows:numGroups-1];
// initialized to zero

NSLog(@"a = \n%@",[a toString]);



BC2DMatrix *CD = [C multiplyWithMatrix:D andAddMatrix:nil transposeMatrixA:NO transposeMatrixB:NO scaleAB:1.0 scaleC:1.0];
BC2DMatrix *CDCt = [CD multiplyWithMatrix:C andAddMatrix:nil transposeMatrixA:NO transposeMatrixB:YES scaleAB:1.0 scaleC:1.0];

NSLog(@"CDCt = \n%@",[CDCt toString]);

BC2DMatrix *CDCt_inverse = [CDCt inversion];

NSLog(@"CDCt_inverse = \n%@",[CDCt_inverse toString]);

BCVector *Cmu_sub_a = [C multiplyWithVector:mu andAddVector:a transposeMatrix:NO matrixScale:1.0 vectorScale:-1.0];

NSLog(@"Cmu_sub_a = \n%@",[Cmu_sub_a toString]);

BC2DMatrix *Cmu_sub_a_t = [Cmu_sub_a transpose];

NSLog(@"Cmu_sub_a_t = \n%@",[Cmu_sub_a_t toString]);

BC2DMatrix *Cmu_sub_a_t_CDCt_inverse = [Cmu_sub_a_t multiplyWithMatrix:CDCt_inverse andAddMatrix:nil transposeMatrixA:NO transposeMatrixB:NO scaleAB:1.0 scaleC:1.0];

NSLog(@"Cmu_sub_a_t_CDCt_inverse = \n%@",[Cmu_sub_a_t_CDCt_inverse toString]);


BC2DMatrix *Cmu_sub_a_t_CDCt_inverse_Cmu_sub_a = [Cmu_sub_a_t_CDCt_inverse multiplyWithVector:Cmu_sub_a andAddVector:a transposeMatrix:NO matrixScale:1.0 vectorScale:0.0];

NSLog(@"Cmu_sub_a_t_CDCt_inverse_Cmu_sub_a = \n%@",[Cmu_sub_a_t_CDCt_inverse_Cmu_sub_a toString]);

BC2DMatrix *test = [[BC2DMatrix alloc] initWithRows:3 andColumns:3];

    [test setValue:1 atRow:0 andColumn:0];
   [test setValue:3 atRow:0 andColumn:1];
   [test setValue:3 atRow:0 andColumn:2];
   
    [test setValue:1 atRow:1 andColumn:0];
   [test setValue:4 atRow:1 andColumn:1];
   [test setValue:3 atRow:1 andColumn:2];
   
  [test setValue:1 atRow:2 andColumn:0];
   [test setValue:3 atRow:2 andColumn:1];
   [test setValue:4 atRow:2 andColumn:2];
  
  NSLog(@"test= \n%@",[test toString]);
   
   BC2DMatrix *test_inverse = [test inversion];

NSLog(@"test_inversion = \n%@",[test_inverse toString]);

BC2DMatrix *testxtest_inversion = [test multiplyWithMatrix:test_inverse andAddMatrix:nil transposeMatrixA:NO transposeMatrixB:NO scaleAB:1.0 scaleC:0];

NSLog(@"testxtest_inversion = \n%@",[testxtest_inversion toString]);


}

