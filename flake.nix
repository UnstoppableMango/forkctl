{
  description = "An OCaml flake";

  nixConfig = {
    allow-import-from-derivation = false;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/triplet";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { pkgs, ... }:
        let
          inherit (pkgs) ocamlPackages;
          version = "0.0.1";
          forkctl = ocamlPackages.callPackage ./nix { inherit version; };
        in
        {
          packages = {
            inherit forkctl;
            default = forkctl;
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ forkctl ];
            packages =
              (with pkgs; [
                gnumake
                nixfmt
              ])
              ++ (with ocamlPackages; [
                dune_3
                ocaml-lsp
                ocamlformat
                odoc
              ]);
          };

          treefmt.programs = {
            actionlint.enable = true;
            nixfmt.enable = true;
            ocamlformat.enable = true;
          };
        };
    };
}
