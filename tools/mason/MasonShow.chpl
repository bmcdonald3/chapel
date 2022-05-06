use FileSystem;
use MasonEnv;
use List;

proc masonShow(args: [?d] string) {
  var listArgs: list(string);
  for x in args do listArgs.append(x);
  masonShow(listArgs);
}

proc masonShow(ref args: list(string)) {
  try! {
    writeln("Mason packages installed:");
    for filename in listdir(MASON_HOME+'/src/', dirs=true, files=true) {
      var first = true;
      for val in filename.split('-',maxsplit=1) {
        if first {
          first=!first;
          write(val, " ");
        } else
          write("Version: ", val);
      }
      writeln();
    }
  }
}

