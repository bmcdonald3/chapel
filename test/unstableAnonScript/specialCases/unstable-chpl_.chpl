// Copied from test/compflags/ferguson/unstable-chpl_.chpl

proc chpl_fn() {
  return 2;
}

proc main() {
  var chpl_variable = 1;
  writeln(chpl_variable);
  writeln(chpl_fn());
}
