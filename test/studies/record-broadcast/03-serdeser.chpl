use CommDiagnostics, Time, CTypes, CyclicDist;

config const size = 10,
             printRecords = false,
             printDiagnotics = true;

class dist_array {
  const Space = {0..Locales.size};
  const D: domain(1) dmapped CyclicDist.Cyclic(startIdx=Space.lowBound) = Space;
  var foos: [D] foo;
}

// Record that will be locale to each locale
record foo {
  var Space = {1..size, 1..size};
  var data: [Space] int;

  proc init(val = 0) {
    data = val;
  }
}

proc main() {
  const world_array = new shared dist_array();

  startCommDiagnostics();

  ref globalFoo = world_array.foos[0];
  coforall loc in Locales do on loc {

    process(globalFoo);
  }

  stopCommDiagnostics();
  printCommDiagnosticsTable();

  if printRecords then
    writeln("back home: ", world_array.foos[0]);
}

proc process(x) {
  if printRecords then
    writeln((here.id, x));

  return + reduce x.data;
}

proc foo.chpl__serialize() {
  var locBuf: c_ptr(int) = c_ptrTo(data);
  return new serializedFoo(locBuf, (size*size), this.locale.id);
}

proc type foo.chpl__deserialize(in data: serializedFoo) {
  var r = new foo();

  import Communication as Comm;
  Comm.get(c_ptrTo(r.data), data.buff, data.locale_id,
           (data.size*c_sizeof(int)).safeCast(c_size_t));

  return r;
}

record serializedFoo {
  var buff: c_ptr(int);
  var size: int;
  var locale_id: int;
}

