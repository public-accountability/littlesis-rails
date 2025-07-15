{
  description = "A Nix-flake-based Ruby development environment";

  inputs = {
   # Proivdes legacy compatibility for nix-shell
   flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
   # Provides some nice helpers for multiple system compatibility
   flake-utils.url = "github:numtide/flake-utils";
   # Specify the nixpkgs for our particular ruby version
   # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=ruby
   nixpkgs.url = "github:nixos/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat }:
    # Calls the provided function for each "default system", which
    # is the standard set.
    flake-utils.lib.eachDefaultSystem
      (system:
        # instantiate the package set for the supported system, with our
        # rust overlay
        let pkgs = import nixpkgs { inherit system; };
        in
        # "unpack" the pkgs attrset into the parent namespace
        with pkgs;
        {
          devShell = mkShell {
            # Packages required for development.
            buildInputs = [
              ruby
            ];
          };
        });
}
