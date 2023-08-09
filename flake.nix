{
  description = "Epitech Coding Style Checker Language Server";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    ruleset = {
      url = "git+ssh://git@github.com/Epitech/banana-coding-style-checker.git";
      flake = false;
    };

    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ruleset, utils }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          python311
          banana-vera
          black
        ];
      };

      packages = {
        ecsls = let
          pypkgs = pkgs.python311Packages;
        in pypkgs.buildPythonPackage {
          pname = "ecsls";
          version = "0.0.1";
          src = ./.;

          propagatedBuildInputs = [ pypkgs.pygls pypkgs.tomli ];
          nativeBuildInputs = with pkgs; [
            makeWrapper
          ];

          postPatch = ''
            substituteInPlace src/ecsls/config.py --replace   \
              'self.path = "./banana-coding-style-checker"' \
              'self.path = "${ruleset}"'
          '';

          postFixup = ''
            wrapProgram $out/bin/ecsls_run \
            --set PATH ${pkgs.lib.makeBinPath ([ pkgs.banana-vera ])}
          '';
        };

        default = self.packages.${system}.ecsls;
      };
    });
}
