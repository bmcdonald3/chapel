//  lhs: unmanaged?  rhs: borrowed?  error: mm

class MyClass {  var x: int;  }

var rhs: borrowed MyClass?;

record MyRecord {
  var lhs: unmanaged MyClass? = rhs;
}

var myr = new MyRecord();

compilerError("done");
