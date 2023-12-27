{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    openscreen = {
      url = "git+https://chromium.googlesource.com/openscreen.git?rev=934f2462ad01c407a596641dbc611df49e2017b4&submodules=1";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # arm64 only supported on linux according to openscreen upstream
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = rec {
          shanocast = default;
          default = pkgs.callPackage ./cast_receiver.nix { src = inputs.openscreen; };
        };
      };
    };
}
