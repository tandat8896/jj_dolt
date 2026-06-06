{
  description = "Learning shell for Dolt and Jujutsu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            dolt
            jujutsu
          ];

          shellHook = ''
            echo "Dolt + Jujutsu learning shell"
            echo
            echo "Versions:"
            dolt version
            jj --version
            echo
            echo "Try:"
            echo "  dolt init"
            echo "  jj git init --colocate"
          '';
        };
      }
    );
}
