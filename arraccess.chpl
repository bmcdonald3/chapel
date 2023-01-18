var A: [0..#10, 0..#10] int;

writeln(A[5,5]);

use BlockDist;

var D = newBlockDom({0..#10, 0..#10});
var B: [D] int;
writeln(B[6,6]);
