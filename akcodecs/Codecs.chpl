module Codecs {
  use CTypes;
  use idna;
  use iconv;
  
  proc encode(obj, encoding: string = "UTF-8") throws {
    if encoding == "IDNA" {
      var cRes: c_string;
      var rc = idn2_to_ascii_lz(obj.c_str(), cRes, 0);
      if (rc != IDNA_SUCCESS) {
        throw new Error("Encode failed");
      }
      var chplRes = cRes: string;
      idn2_free(cRes: c_void_ptr);
      return chplRes;
    } else {
      var cd = libiconv_open("UTF-8":c_string, encoding.c_str());
      var inBuf = obj.c_str();
      var inSize = (obj.size+1): c_size_t;
      // TODO: how do we get this to be the correct size?
      var chplRes = "                  ";
      var outBuf = chplRes.c_str();
      var outSize = chplRes.size: c_size_t;
      var r = libiconv(cd, inBuf, inSize, outBuf, outSize);
      if r != 0 then
        throw new Error("Error encoding object");
      return chplRes;
    }
  }
  
  proc decode(obj, encoding: string = "UTF-8") throws {
    if encoding == "IDNA" {
      var cRes: c_string;
      var rc = idn2_to_unicode_8z8z(obj.c_str(), cRes, 0);
      if (rc != IDNA_SUCCESS) {
        throw new Error("Decode failed");
      }
      var chplRes = cRes: string;
      idn2_free(cRes: c_void_ptr);
      return chplRes;
    }
    else {
      var cd = libiconv_open(encoding.c_str(), "UTF-8":c_string);
      var inBuf = obj.c_str();
      var inSize = (obj.size+1): c_size_t;
      // TODO: how do we get this to be the correct size?
      var chplRes = "                                   ";
      var outBuf = chplRes.c_str();
      var outSize = chplRes.size: c_size_t;
      var r = libiconv(cd, inBuf, inSize, outBuf, outSize);
      if r != 0 then
        throw new Error("Error decoding object");
      return chplRes;
    }
  }
}