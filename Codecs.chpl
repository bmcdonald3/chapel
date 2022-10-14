module Codecs {
  use CTypes;
  use idna;

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