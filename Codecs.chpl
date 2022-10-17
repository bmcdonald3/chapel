module Codecs {
  use CTypes;
  use idna;
  use iconv;

  var i = "UTF-8": c_string;
  var o = "UTF=16":c_string;

  var inS = {0x10, 0x20, 0x30, 0x00};
  var inL: c_size_t = 3;

  var outS: c_string;
  var outL: c_size_t = 3;

  //extern proc libiconv_open(tocode : c_string, fromcode : c_string) : libiconv_t;
  var cd = libiconv_open(i, o);
  //extern proc libiconv(cd : libiconv_t, inbuf : c_ptr(c_string), inbytesleft : c_ptr(c_size_t), outbuf : c_ptr(c_string), outbytesleft : c_ptr(c_size_t)) : c_size_t;
  var r = libiconv(cd,c_ptrTo(inS), c_ptrTo(inL), c_ptrTo(outS), c_ptrTo(outL));
  
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