
from algorithm.functional import parallelize

import time
#List of references to possibly use
#--------------------------------------------------
#   -https://youtu.be/GdDc5MigPWw?si=05Dycwe3H--n6CcZ (Creating Matrixes but pointers are not working)
#   -https://docs.modular.com/mojo/stdlib/algorithm/functional/parallelize (Creating the parallel processing but can't get it to work)
#--------------------------------------------------
#List of problems currently
#--------------------------------------------------
#   -Comparison of times with multithreading and without multithreading
#--------------------------------------------------

#Matrix class
struct Matrix:
    var height: Int
    var width: Int
    var matrix: List[List[Float64]]

    fn __init__(out self) raises:
        var height:Int = Int(input("Input the height of the matrix: "))
        var width:Int = Int(input("Input the width of the matrix: "))
        self.height = height if height > 0 else 1
        self.width = width if width > 0 else 1
        self.matrix = List[List[Float64]](capacity=(self.width*self.height)) #For initializing the 2D array (Capacity is only how much it can hold but doesn't show actual size)
        #Adding the elements of the matrix
        for i in range(self.height):
            for j in range(self.width):
                var message = String("Input the element at location ", i, ", ", j, ": ")
                var elementInput = input(message)
                self.matrix[i].append(Float64(elementInput))
        
    #Second constructor mainly to copy the width of other matrices for the second matrix
    fn __init__(out self, matrix: Matrix) raises:
        var width:Int = Int(input("Input the width of the matrix: "))
        self.height = matrix.width if matrix.width > 0 else 1
        self.width = width if width > 0 else 1
        self.matrix = List[List[Float64]](capacity=(self.width*self.height))
        #Adding the elements of the matrix
        for i in range(self.height):
            for j in range(self.width):
                var message = String("Input the element at location ", i, ", ", j, ": ")
                var elementInput = input(message)
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
        for i in range(self.height):
            var list1 = matrix1.matrix[i]
            #Multithreading
            @parameter
            fn processRow(j:Int):
                var list2 = temp[j]
                self.matrix[i].insert(j, self.initRow(list1, list2))
            parallelize[processRow](self.width)
        
        #Initialization code without multithreading
        #for i in range(self.height):
        #    var list1 = matrix1.matrix[i]
        #    for j in range(self.width):
        #        var list2 = temp[j]
        #        self.matrix[i].append( self.initRow(list1, list2))
            
                
        

    fn getElement(self, x:Int, y:Int) -> Float64:
        return self.matrix[y][x]

    fn printMatrix(self):
        for i in range(self.height):
            for j in range(self.width):
                print(self.matrix[i][j], end=",\t ")
            print()

    fn initRow(self, row: List[Float64], column: List[Float64]) -> Float64:
        var sum: Float64 = 0
        for i in range(len(column)):
            sum += (row[i] * column[i])
        return sum





fn main() raises:
    
    var matrix_1:Matrix = Matrix()
    print()
    print("Matrix 1:")
    matrix_1.printMatrix()
    var matrix_2:Matrix = Matrix(matrix_1)
    print()
    print("Matrix 2:")
    matrix_2.printMatrix()
    var matrix_3:Matrix = Matrix(matrix_1, matrix_2)
    print()
    print("Matrix Product:")
    matrix_3.printMatrix()
    
    
    
    
    


