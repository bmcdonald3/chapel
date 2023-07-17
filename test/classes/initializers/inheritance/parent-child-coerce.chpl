class Parent {
  proc init(x:int) {
    writeln("In Parent init(int)");
  }
  proc init() {
  }
}

class Child : Parent {
  proc init(x:real) {
    writeln("In Child init(real)");
  }
}

var i:int = 1;
var ownX = new owned Child(i);
var x = ownX.borrow();
writeln(x);
