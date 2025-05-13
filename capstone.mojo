
from algorithm.functional import parallelize

import time
from random import random_si64
from time import perf_counter

#List of references to possibly use
#--------------------------------------------------
#   -https://youtu.be/GdDc5MigPWw?si=05Dycwe3H--n6CcZ (Creating Matrixes but pointers are not working)
#   -https://docs.modular.com/mojo/stdlib/algorithm/functional/parallelize (Creating the parallel processing but can't get it to work)
#   -https://docs.modular.com/mojo/stdlib/time/time/ (timer)
#--------------------------------------------------
#List of problems currently
#--------------------------------------------------
#   -(semi-fixed) Comparison of times with multithreading and without multithreading 
#   -For me(Chris) keep getting error about llvm-symbolizer when trying to run both 
#    Multithread and standard.  Seems to also sometimes happen when dealing with big numbers
#    very weird bug that I cannot seem to fix rn
#   -For some reason standard is faster than Multithread method.  A good amount faster too.
#--------------------------------------------------

#Matrix class
struct Matrix(Copyable):
    var height: Int
    var width: Int
    var matrix: List[List[Float64]]

    fn __init__(out self) raises:
        var height:Int = 10
        var width:Int = 10
        self.height = height if height > 0 else 1
        self.width = width if width > 0 else 1
        self.matrix = List[List[Float64]](capacity=(self.width*self.height)) #For initializing the 2D array (Capacity is only how much it can hold but doesn't show actual size)
        #Adding the elements of the matrix
        for i in range(self.height):
            for j in range(self.width):
                #var message = String("Input the element at location ", i, ", ", j, ": ")
                var elementInput = random_si64(0, 1000)
                self.matrix[i].append(Float64(elementInput))
        
    #Second constructor mainly to copy the width of other matrices for the second matrix
    fn __init__(out self, matrix: Matrix) raises:
        var width:Int = 10
        self.height = matrix.width if matrix.width > 0 else 1
        self.width = width if width > 0 else 1
        self.matrix = List[List[Float64]](capacity=(self.width*self.height))
        #Adding the elements of the matrix
        for i in range(self.height):
            for j in range(self.width):
                #var message = String("Input the element at location ", i, ", ", j, ": ")
                var elementInput = random_si64(0, 1000)
                self.matrix[i].append(Float64(elementInput))

    #Third constructor to create the answer matrix
    fn __init__(out self, matrix1: Matrix, matrix2: Matrix):
        self.height = matrix1.height
        self.width = matrix2.width
        self.matrix = List[List[Float64]](capacity=(self.width*self.height))
        var temp = List[List[Float64]](capacity=(matrix2.width*matrix2.height))

        for i in range(matrix2.width):
            for j in range(matrix2.height):
                temp[i].append(matrix2.matrix[j][i])
        #Multithreading
        @parameter
        fn processColumn(i:Int):
            var list1 = matrix1.matrix[i]
            var list3: List[Float64] = List[Float64](capacity=matrix2.width)
            @parameter
            fn processRow(j:Int):
                var list2 = temp[j]
                
                list3.insert(j, self.initRow1(list1, list2))
            parallelize[processRow](self.width)
            self.matrix.insert(i, list3)
        parallelize[processColumn](self.height)

    #Standard method constructor 
    fn __init__(out self, matrix1: Matrix, matrix2: Matrix, switch: Int):
        self.height = matrix1.height
        self.width = matrix2.width
        self.matrix = List[List[Float64]](capacity=(self.width*self.height))
        var temp = List[List[Float64]](capacity=(matrix2.width*matrix2.height))

        for i in range(matrix2.width):
            for j in range(matrix2.height):
                temp[i].append(matrix2.matrix[j][i])

        for i in range(self.height):
            var list1 = matrix1.matrix[i]
            for j in range(self.width):
                var list2 = temp[j]
                self.matrix[i].append( self.initRow2(list1, list2))
            
                
        

    fn getElement(self, x:Int, y:Int) -> Float64:
        return self.matrix[y][x]

    #fn printMatrix(self):
    #    for i in range(self.height):
    #        for j in range(self.width):
    #            print(self.matrix[i][j], end=",\t ")
    #        print()

    #Initialization code with multithreading
    fn initRow1(self, row: List[Float64], column: List[Float64]) -> Float64:
        var sum: Float64 = 0
        @parameter
        fn makeSum(i:Int):
            sum += (row[i] * column[i])
        parallelize[makeSum](len(column))

        return sum

    #Initialization code without multithreading
    fn initRow2(self, row: List[Float64], column: List[Float64]) -> Float64:
        var sum: Float64 = 0
        for i in range(len(column)):
            sum += (row[i] * column[i])
        return sum

    fn __copyinit__(out self, other: Self):
        self.height = other.height
        self.width = other.width
        self.matrix = other.matrix



fn main() raises: 
    var matrix_1:Matrix = Matrix()
    print()
    print("Matrix 1:")
    #matrix_1.printMatrix()
    var matrix_2:Matrix = Matrix(matrix_1)
    print()
    print("Matrix 2:")
    #matrix_2.printMatrix()

    var matrix_1_copy = matrix_1
    var matrix_2_copy = matrix_2

    #multithreaded matrix multiplication
    var start1 = time.perf_counter()
    var matrix_3:Matrix = Matrix(matrix_1, matrix_2)
    var end1 = time.perf_counter()
    print()
    print("Matrix Product:")
    #matrix_3.printMatrix()
    print("Time elapsed (Multithreading): ", end1 - start1, " seconds")

    #standard matrix multiplication
    var start2 = time.perf_counter()
    var matrix_4:Matrix = Matrix(matrix_1_copy, matrix_2_copy, 1)
    var end2 = time.perf_counter()
    print()
    print("Matrix Product:")
    #matrix_4.printMatrix()
    print("Time elapsed (Standard): ", end2 - start2, " seconds")
    

    
    


