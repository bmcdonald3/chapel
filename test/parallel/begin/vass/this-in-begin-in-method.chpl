// Checks that heap allocation works.

record RR {
  var xx: int;
  proc ref modify(ee: int) {
    begin with (ref this) {
      doModify(this, ee);
    }
  }
}
proc doModify(ref recv: RR, ee: int) {
  recv.xx = ee;
}

var rr = new RR();
rr.modify(151515);

if rr.xx != 123123 then writeln("OK");
