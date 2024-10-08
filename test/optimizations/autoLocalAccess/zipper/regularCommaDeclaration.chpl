use common;

{
  var D = createDom({1..10});

  var A, B, C: [D] real;

  B = 3;
  C = 7;

  // this is the very basic case and optimzed completely
  forall (i, loopIdx) in zip(D, 1..) with (ref A) {
    A[i] = B[i] + C[i];
  }
  writeln(A);
}

{
  var D = createDom({1..10});

  var A, B, C: [D] real;

  B = 3;
  C = 7;

  // this only optimizes `A[i]` can do more static tracing to optimize others
  forall (i, loopIdx) in zip(A.domain, 1..) with (ref A) {
    A[i] = B[i] + C[i] * loopIdx;
  }
  writeln(A);
}
