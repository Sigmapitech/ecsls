{
  description = "Epitech Coding Style Checker Language Server";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
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
          pname = "sourcery-analytics";
          version = "0.0.1";
          src = ./.;

          propagatedBuildInputs = [ pypkgs.pygls ];
        };

        default = self.packages.${system}.ecsls;
      };
    });
}
