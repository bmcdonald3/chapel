use LockFreeStack;

const InitialStackSize = 64;
const OperationsPerThread = 64;

proc main() {
  var lfs = new unmanaged LockFreeStack(int);

  // Fill the stack and warm up the cache.
  forall i in 1..InitialStackSize with (var tok = lfs.getToken()) do lfs.push(i, tok);

  coforall tid in 1..here.maxTaskPar {
    var tok = lfs.getToken();
    // Even tasks handle push, odd tasks handle pop...
    if tid % 2 == 0 {
      for i in 1..OperationsPerThread do lfs.push(i, tok);
    } else {
      for i in 1..OperationsPerThread do lfs.pop(tok);
    }
  }
  lfs.tryReclaim();
}
