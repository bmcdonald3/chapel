use ZMQ;
use CTypes;

config const message_size=1_000_000;
config const message_count=1;

proc sendArr(arr, port) {
  var context: Context;
  var socket = context.socket(ZMQ.PUSH);
  socket.bind("tcp://*:"+port:string);
  const size = arr.size*c_sizeof(int):int;
  var buff = createBytesWithBorrowedBuffer(c_ptrTo(arr):c_ptr(uint(8)), size, size);
  socket.send(buff);
}

proc main() {
  var arr: [0..#message_size] int = 2;
  for i in 1..message_count do
    sendArr(arr, 1234);
}