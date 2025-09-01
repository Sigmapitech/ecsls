{
  description = "Epitech Coding Style Checker Language Server";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    vera-clang.url = "github:Sigmapitech/vera-clang";
  };

  outputs = { nixpkgs, utils, vera-clang, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python3
            banana-vera
            black
          ];
        };

        packages = rec {
          default = ecsls;
          ecsls =
            let
              vera = vera-clang.packages.${system}.vera;
            in pkgs.python3Packages.callPackage ./ecsls.nix { inherit vera; };
        };
      });
}
