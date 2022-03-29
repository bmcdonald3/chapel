//Check if zipped 'foreach' loop is vectorizable
proc loop (A, B) {
  foreach (i,j) in zip(0..511, 0..511) {
    // CHECK: <4 x i32>
    A[i,j] = B[i,j]*3;
  }
}

var A : [0..511, 0..511] int(32);
var B : [0..511, 0..511] int(32);

loop(A, B);
writeln("Sum of A is ", + reduce A);
