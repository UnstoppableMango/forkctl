{
  lib,
  buildDunePackage,
  cmdliner,
  version,
}:

buildDunePackage {
  pname = "forkctl";
  inherit version;

  src = lib.cleanSource ../.;

  buildInputs = [ cmdliner ];

  meta = {
    description = "Tooling to maintain a fleet of forked git repos";
    homepage = "https://github.com/UnstoppableMango/forkctl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
