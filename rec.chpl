use ZMQ;
use CTypes;
use Time;

config const message_size=100_000_000;
config const message_count=1;

proc receiveArr(port, ref t, ref otherT) {
  otherT.start();
  var context: Context;
  var socket = context.socket(ZMQ.PULL);
  socket.connect("tcp://localhost:"+port:string);
  otherT.stop();
  t.start();
  var locData = socket.recv(bytes);
  t.stop();
  otherT.start();
  var locArr = makeArrayFromPtr(locData.c_str():c_void_ptr:c_ptr(int), message_size:uint);
  otherT.stop();
  return locArr;
}

proc main() {
  var numMB = (message_size*c_sizeof(int)/1000000);
  
  var t: stopwatch;
  var otherT: stopwatch;
  for i in 1..message_count do
    receiveArr(1234, t, otherT);

  var throughput = message_count / t.elapsed();
  var megabits = throughput * message_size * c_sizeof(int) / 1000000;

  writeln("message size: ", message_size, " [B]");
  writeln("message count: ", message_count);
  writeln("mean throughput: ", throughput, " [msg/s]");
  writeln("mean throughput: ", megabits, " [Mb/s]");
  writeln("Time spent copying: ", otherT.elapsed(), " vs ", t.elapsed());
}
