{
  buildPythonPackage,
  setuptools,
  pygls,
  tomli,
  makeWrapper,
  lib,
  vera,
}:
buildPythonPackage {
  pname = "ecsls";
  version = "0.0.1";
  src = ./.;

  pyproject = true;

  build-system = [ setuptools ];

  dependencies = [
    pygls
    tomli
  ];

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/ecsls_run \
      --set PATH ${lib.makeBinPath ([ vera ])}
  '';

  meta = {
    description = "Epitech Coding Style Language Server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "ecsls";
  };
}
