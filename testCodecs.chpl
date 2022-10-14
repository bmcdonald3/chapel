use Codecs;
var a = 'xn--mnchen-3ya';
var res = try! decode(a);
writeln("Input: ", a);
writeln("Decoded: ", res);

res = try! encode(res);
writeln("Encoded: ", res);