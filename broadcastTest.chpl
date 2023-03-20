import CyclicDist;
use CommDiagnostics, Time, CTypes;
config const size = 30000;
config const alwaysFalse = false;
config const mode = 0;
config param doSerialize = true;

// Class containing cyclic distributed array of local records
class dist_array {
  const Space = {0..2};
  const D: domain(1) dmapped CyclicDist.Cyclic(startIdx=Space.lowBound) = Space;
  var foos: [D] foo;
}

// Record that will be locale to each locale
pragma "always RVF"
record foo {
  var Space = {1..size, 1..size};
  var locale_id = chpl_nodeID;
  var data: [Space] int;
  

  proc init() {}

  proc init(b, l) {
    this.complete();
    c_memcpy(c_ptrTo(data), b, l*c_sizeof(int));
  }

  proc chpl__serialize()
    where doSerialize {
    import Communication;
    var locBuf: c_ptr(int) = c_ptrTo(data);
    return new forSerialize(locBuf, (size*size), this.locale_id);
  }

  proc type chpl__deserialize(data)
       where doSerialize {
    var buf: c_ptr(int) = c_malloc(int, data.size);
    import Communication;
    Communication.get(buf, data.buff, data.locale_id, (data.size*c_sizeof(int)).safeCast(c_size_t));
    return new foo(buf, data.size);
  }
}

record forSerialize {
  var buff: c_ptr(int);
  var size: int;
  var locale_id;
}

proc main() {
  var world_array = new shared dist_array();

  forall f in world_array.foos {
    f.data = here.id+5;
  }

  var t: stopwatch;
  t.start();
  startCommDiagnostics();
  if mode == 0 {
    writeln("Running local variable");
    localVariable(world_array);
  } else if mode == 1 {
    writeln("Running with clause");
    withClause(world_array);
  } else {
    writeln("Running RVF with serialize=", doSerialize);
    rvfRecord(world_array);
  }
  stopCommDiagnostics();
  writeln(getCommDiagnostics());

  t.stop();
  writeln("Took      : ", t.elapsed());
}

proc doSomething(rec) {
  var sum = 0;
  for val in rec.data {
    sum += val;
  }
  if alwaysFalse then writeln(sum);
}

proc localVariable(world_array) {
  forall i in world_array.D {
    var locFoo = world_array.foos[0];
    doSomething(locFoo);
  }  
}

proc withClause(world_array) {
  forall i in world_array.D with (var locFoo = world_array.foos[0]) {
    doSomething(locFoo);
  }
}

proc rvfRecord(world_array) {
  ref myRec = world_array.foos[0];
  forall i in world_array.D {
    doSomething(myRec);
  }
}
