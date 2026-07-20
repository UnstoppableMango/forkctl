{
  lib,
  buildDunePackage,
  version,
}:

buildDunePackage {
  pname = "forkctl";
  inherit version;

  src = lib.cleanSource ../.;

  meta = {
    description = "Tooling to maintain a fleet of forked git repos";
    homepage = "https://github.com/UnstoppableMango/forkctl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
