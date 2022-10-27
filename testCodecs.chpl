use Codecs;

proc testIdna(input: string) throws {
  try {
    writeln("Using IDNA");
    writeln("Original string: ", input);
    var output = try! decode(input, 'IDNA');
    writeln("Decoded: ", output);

    output = try! encode(output, 'IDNA');
    writeln("Re-encoded: ", output);
    writeln();
  } catch {
    writeln("FAILED: ", input, " -> IDNA");
  }
}

proc testEncoding(input:string, encoding:string) {
  try {
    writeln("Using ", encoding);
    writeln("Original string: ", input);
    var output = try! encode(input, encoding);
    writeln("Encoded: ", output);

    output = try! decode(output, encoding);
    writeln("Decoded: ", output);
    writeln();
  } catch {
    writeln("FAILED: ", input, " -> ", encoding);
  }
}

testIdna('xn--mnchen-3ya');
testEncoding("asd", "UTF-16");
testEncoding("asd", "ASCII");
testEncoding("asd", "PT154");
