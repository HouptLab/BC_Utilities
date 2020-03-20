//
//  BCMatrix.m
//  Xynk
//
//  Created by Tom Houpt on 13/5/27.
//
//

#import "BCMatrix.h"
#include "BCArrayUtilities.h"


@implementation BCMatrix

// [myMatrix elementAtIndices:i,j,k]
// matrix element [i][j][k] is at buffer [ c[0] * i + c[1] * j + c[3] * k]
// internally: matrix element [i][j][k] is at buffer [ (c[0] * index[0] + c[1] * index[1] + c[3] * index[2]) * elementSize ]


@synthesize dimension;
@synthesize elementSize;
@synthesize buffer;
@synthesize c;
@synthesize dimensionSizes;
@synthesize index;


-(id)initWithDimension:(NSInteger)d andMaxCount:(NSArray *)sizes forElementSize:(size_t)iS; {
    
    
    assert( d == [sizes count]);
    // must have specificed a maximum size for each dimension of the matrix
    
    self = [super init];
    
    if (self) {
        
        buffer = NULL;
        c = NULL;
        index = NULL;
        dimensionSizes = NULL;
        
        dimension = d;
        
        dimensionSizes = calloc(dimension, sizeof(NSInteger)); // make sure zeroed
        // copy the maximum size for each dimension into the dimensionSizes array
        for (int i=0;i<[sizes count];i++) {
            dimensionSizes[i] = [[sizes objectAtIndex:i] intValue];
        }

        // generate the coeffecient array as a product of the lower dimensions
        c = calloc(dimension, sizeof(NSInteger));
        c[0] = 1;
        for (int i=1;i<dimension;i++) {
            c[i] = dimensionSizes[i-1] * c[i-1];
        }
              
        elementSize = iS;
        size_t buffer_size = [self count];
        buffer = calloc(buffer_size,elementSize); // zero the memory
        
        // make an array to hold the indices when dereferencing an element
        // and zero the memory
        index = calloc(dimension, sizeof(NSInteger));
        
        
    }
    
    return self;
    
}

-(void)dealloc; {
    // free the malloc'd buffers

    if (NULL != buffer) {  free(buffer); }
    if (NULL != dimensionSizes) {  free(dimensionSizes); }
    if (NULL != c) {  free(c); }
    if (NULL != index) {  free(index); }
    
}

-(NSInteger)count; {
    // total number of elements in matrix

    return (productOfIntArray(dimensionSizes, dimension));
    
}

-(void *)copyOfElementAtIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // returns ptr to new malloc'd block of data with copy ofelement at matrix[firstIndex,...]
    // caller is responsible for free'ing this block
    

    va_list argumentList;
    
//    for (int i = 0; i < dimension; i++) {
//        NSLog(@"DimensionSize %d = %ld",i, dimensionSizes[i]);
//    }
    
    index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;
    
    while (currentIndex < dimension) {
        // As many times as we can get an argument of type "NSInteger"
        // that isn't nil, add it to self's contents.
        index[currentIndex] = va_arg(argumentList, NSInteger);
        if (index[currentIndex] >= dimensionSizes[currentIndex]){
            NSLog(@"BCMatrix currentIndex:%ld index[] = %ld dimensionSizes[] = %ld", (long)currentIndex,  (long)index[currentIndex], (long)dimensionSizes[currentIndex]);
        }

        if (index[currentIndex] >= dimensionSizes[currentIndex]) {
            NSLog(@"BCMatrix copyElement:Out of bounds index: %zd", (long)currentIndex);
            
                  assert( index[currentIndex] < dimensionSizes[currentIndex]);
            
            return NULL;
        }
        currentIndex++;
    }
    va_end(argumentList);
    
    size_t offset_into_buffer = 0;
    int i;
    for (i=0;i<dimension;i++) {
        offset_into_buffer += c[i] * index[i];
        
    }
    
    assert(offset_into_buffer < [self count]);
//    NSLog(@"BCMatrix copyElement [%zd,%zd] offset: %zd",(long)index[0],(long)index[1],offset_into_buffer);

    offset_into_buffer *= elementSize;
    
    void *elementCopy = malloc(elementSize);
    
    memcpy(elementCopy,&(buffer[offset_into_buffer]),elementSize );
    
    return (elementCopy);
    
    
}

-(void)setElement:(void *)element atIndices:(NSInteger) firstIndex,...; {
    // variadic method
    // copies element at address *element into matrix[firstIndex,...]
    // of course, # indices should == dimension
    // element should be same size as elementSize
    // but we can't check this ourselves

    
    va_list argumentList;
    
    index[0] = firstIndex;
    
    va_start(argumentList, firstIndex); // Start scanning for arguments after firstObject.
    
    NSInteger currentIndex = 1;

    while (currentIndex < dimension) {
        // get as many arguments of type "NSInteger"
        // as we have dimensions
        index[currentIndex] = va_arg(argumentList, NSInteger);
        assert( index[currentIndex] < dimensionSizes[currentIndex]);
        if (index[currentIndex] >= dimensionSizes[currentIndex]) {
            NSLog(@"BCMatrix setElement Out of bounds index: %zd", (long)currentIndex);
            return;
        }
        currentIndex++;
    }
    va_end(argumentList);
    
    size_t offset_into_buffer = 0;
    int i;
    for (i=0;i<dimension;i++) {
        offset_into_buffer += c[i] * index[i];
    }
    
    
    assert(offset_into_buffer < [self count]);

// NSInteger myCount = [self count];
//    NSLog(@"dimension = %zd",dimension);
//    NSLog(@"dimensionSizes[0] = %zd",dimensionSizes[0]);
//    NSLog(@"dimensionSizes[1] = %zd",dimensionSizes[0]);
//    NSLog(@"count = %zd",myCount);
//     NSLog(@"offset_into_buffer = %zd",offset_into_buffer);
//   NSLog(@"BCMatrix setElement [%zd,%zd] offset: %zd",(long)index[0],(long)index[1],offset_into_buffer);

    
    offset_into_buffer *= elementSize;
    
    memcpy(&(buffer[offset_into_buffer]),element,elementSize);

}

-(NSInteger)sumIntegerMatrix; {
    
    assert(elementSize == sizeof(NSInteger));
    
    NSInteger sum = 0;
    NSInteger numberOfElements = [self count];
    NSInteger i;
    NSInteger *intBuffer = (NSInteger *)buffer;
    for (i=0;i<numberOfElements;i++) {
        
        sum+= intBuffer[i];
    }
    
    return sum;
}
-(double)sumDoubleMatrix; {
    
    assert(elementSize == sizeof(double));

    double sum = 0.0;
    NSInteger numberOfElements = [self count];
    NSInteger i;
    double *doubleBuffer = (double *)buffer;
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
- (void)setValue:(CGFloat)value atRow:(NSInteger)r  andColumn:(NSInteger)c; {
    
    [self setElement:&value atIndices:r,c];
    
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
