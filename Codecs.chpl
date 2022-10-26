module Codecs {
  use CTypes;
  use idna;
  use iconv;

  var i = "UTF-8": c_string;
  var o = "UTF-16":c_string;

  var input: [0..3] uint(8);
  input[0] = 0xe2:uint(8);
  input[1] = 0xb4:uint(8);
  input[2] = 0xb0:uint(8);
  input[3] = 0x00:uint(8);

  var inS: c_ptr(uint(8)) = c_ptrTo(input[0]): c_ptr(uint(8));
  
  var inL: c_size_t = 4;

  var output: [0..3] uint(8);

  var outS: c_ptr(uint(8)) = c_ptrTo(output[0]): c_ptr(uint(8));
  var outL: c_size_t = 4;

  var cd = libiconv_open(i, o);
  
  extern proc libiconv(cd : libiconv_t, inbuf, ref inbytesleft, outbuf, ref outbytesleft) : c_size_t;
  var r = libiconv(cd,c_ptrTo(inS), inL, c_ptrTo(outS), outL);

  writeln(r);
  writeln(inL);
  writeln(outL);
  writeln("Input: ", input);
  writeln("Output: ", output);
  
  proc encode(obj, encoding: string = "UTF-8") throws {
    var cRes: c_string;
    var rc = idn2_to_ascii_lz(obj.c_str(), cRes, 0);
    if (rc != IDNA_SUCCESS) {
      throw new Error("Encode failed");
    }
    var chplRes = cRes: string;
    idn2_free(cRes: c_void_ptr);
    return chplRes;
  }
  
  proc decode(obj, encoding: string = "UTF-8") throws {
    var cRes: c_string;
    var rc = idn2_to_unicode_8z8z(obj.c_str(), cRes, 0);
    if (rc != IDNA_SUCCESS) {
      throw new Error("Decode failed");
    }
    var chplRes = cRes: string;
    idn2_free(cRes: c_void_ptr);
    return chplRes;
  }
}