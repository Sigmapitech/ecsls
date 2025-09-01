{
  description = "Epitech Coding Style Checker Language Server";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    vera-clang.url = "github:Sigmapitech/vera-clang";
  };

  outputs = { self, nixpkgs, vera-clang, ... }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
      ] (system: function nixpkgs.legacyPackages.${system});

  in {
    devShells.default = forAllSystems (pkgs: pkgs.mkShell {
      packages = with pkgs; [
        python3
        banana-vera
        black
      ];
    });

    packages = forAllSystems (pkgs: {
      default = self.packages.${pkgs.system}.ecsls;

      vera = vera-clang.packages.${pkgs.system}.vera;

      ecsls = pkgs.python3Packages.callPackage ./ecsls.nix {
        inherit (self.packages.${pkgs.system}) vera;
      };
    });
  };
}
