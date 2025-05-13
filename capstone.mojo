from algorithm.functional import parallelize
from time import perf_counter_ns
from random import random_si64

#List of references to possibly use
#--------------------------------------------------
#   -https://youtu.be/GdDc5MigPWw?si=05Dycwe3H--n6CcZ (Creating Matrixes but pointers are not working)
#   -https://docs.modular.com/mojo/stdlib/algorithm/functional/parallelize (Creating the parallel processing but can't get it to work)
#   -https://docs.modular.com/mojo/stdlib/time/time/ (timer)
#--------------------------------------------------
#List of problems currently
#--------------------------------------------------
#   
#--------------------------------------------------

struct Matrix(Copyable):
    var height: Int
    var width: Int
    var matrix: List[List[Float64]]

    fn __init__(out self, height: Int, width: Int) raises:
        self.height = height if height > 0 else 1
        self.width = width if width > 0 else 1
        self.matrix = List[List[Float64]](capacity=self.height)

        #initialize with random variables
        for _ in range(self.height):
            var row = List[Float64](capacity=self.width)
            for _ in range(self.width):
                row.append(Float64(random_si64(0, 1000)))
            self.matrix.append(row)

    fn __copyinit__(out self, other: Self):
        self.height = other.height
        self.width = other.width
        self.matrix = List[List[Float64]](capacity=self.height)
        for _ in other.matrix:
            var new_row = List[Float64](capacity=self.width)
            for x in range(self.width):
                new_row.append(x)
            self.matrix.append(new_row)

    # Matrix multiplication (Standard)
    fn multiply_standard(self, other: Self) raises -> Self:
        #copy given Matrix
        var result = Matrix(self.height, other.width)

        #change second matrix's rows to columns
        var temp = List[List[Float64]](capacity=other.width)
        for j in range(other.width):
            var col = List[Float64](capacity=other.height)
            for i in range(other.height):
                col.append(other.matrix[i][j])
            temp.append(col)

        #initialize and fill result's matrix
        for i in range(self.height):
            for j in range(other.width):
                var sum: Float64 = 0
                for k in range(self.width):
                    sum += self.matrix[i][k] * temp[j][k]
                result.matrix[i][j] = sum

        return result

    # Matrix multiplication (Multithreaded)
    fn multiply_parallel(self, other: Self) raises -> Self:
        #copy given Matrix
        var result = Matrix(self.height, other.width)

        #change second matrix's rows to columns
        var temp = List[List[Float64]](capacity=other.width)
        for j in range(other.width):
            var col = List[Float64](capacity=other.height)
            for i in range(other.height):
                col.append(other.matrix[i][j])
            temp.append(col)

        #initialize and fill result's matrix
        @parameter
        fn compute_row(i: Int):
            for j in range(other.width):
                var sum: Float64 = 0
                for k in range(self.width):
                    sum += self.matrix[i][k] * temp[j][k]
                result.matrix[i][j] = sum

        parallelize[compute_row](self.height)
        return result

    fn printMatrix(self):
        for i in range(self.height):
            for j in range(self.width):
                print(self.matrix[i][j], end=",\t")
            print()


fn main() raises:
    #initialize a matrix with a big data set
    var size = 1000
    var m1 = Matrix(size, size)
    var m2 = Matrix(size, size)

    #initialize a matrix with a small data set
    size = 2
    var m3 = Matrix(size, size)
    var m4 = Matrix(size, size)

    #print the small matrices
    print("Smaller Matrix Example 1:")
    m3.printMatrix()
    print()
    print("Smaller Matrix Example 1:")
    m4.printMatrix()
    print()

    #print the times with small matrices
    var start3 = perf_counter_ns()
    var result_parallel2 = m3.multiply_parallel(m4)
    var end3 = perf_counter_ns()
    print("Parallel Time (Smaller Matrices): ", end3 - start3, " nanoseconds")

    var start4 = perf_counter_ns()
    var result_standard2 = m3.multiply_standard(m4)
    var end4 = perf_counter_ns()
    print("Standard Time (Smaller Matrices): ", end4 - start4, " nanoseconds")

    print()

    #print the times with big matrices
    var start1 = perf_counter_ns()
    var result_parallel = m1.multiply_parallel(m2)
    var end1 = perf_counter_ns()
    print("Parallel Time (Bigger Matrices): ", end1 - start1, " nanoseconds")

    var start2 = perf_counter_ns()
    var result_standard = m1.multiply_standard(m2)
    var end2 = perf_counter_ns()
    print("Standard Time (Bigger Matrices): ", end2 - start2, " nanoseconds")
