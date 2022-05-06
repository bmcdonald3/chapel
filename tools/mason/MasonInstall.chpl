use MasonBuild;
use MasonUpdate;
use MasonHelp;
use ArgumentParser;
use MasonEnv;
use TOML;
use IO;
use List;

proc masonInstall(args: [] string) throws {
  var parser = new argumentParser(helpHandler=new MasonBuildHelpHandler());

  // TODO: take optional version argument
  // TODO: accept either a toml file path or just a package name
  var packageArg = parser.addArgument(name='packageName');
  parser.parseArgs(args);

  var packageName = packageArg.value();

  updateRegistry(false);

  // bricks that store toml
  // TODO: Stop hardcoding version number (detect newest version?)
  const toParse = open(MASON_HOME+'/mason-registry/Bricks/'+packageName+'/0.1.0.toml', iomode.r);

  var packageBrick = owned.create(parseToml(toParse))['brick']!;

  var sourceList: list((string, string, string));

  sourceList.append((packageBrick['source']!.s, packageName, packageBrick['version']!.s));
  
  getSrcCode(sourceList, false);
}
