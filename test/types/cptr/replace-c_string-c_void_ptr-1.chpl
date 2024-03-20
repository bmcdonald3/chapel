// Verify that users can have their own c_string and c_void_ptr.

// ideally we want to define our own 'c_void_ptr'
// with 'public', not private, use of 'CTypes'
use CTypes;

type c_string = c_ptrConst(c_char);
type c_void_ptr = c_ptr(void);

proc idcstr(arg: c_string): c_string do return arg;

var chstring = "hello";
var cstring: c_string = chstring.c_str();
assert(cstring == idcstr(cstring));

var ptr = c_addrOf(chstring);
var voidPtr = ptr : c_void_ptr;
assert(ptr == voidPtr);
