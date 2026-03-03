{
  description = "A Nix-flake-based Ruby development environment";

  inputs = {
   # Proivdes legacy compatibility for nix-shell
   flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
   # Provides some nice helpers for multiple system compatibility
   flake-utils.url = "github:numtide/flake-utils";
   # Specify the nixpkgs for our particular ruby version
   # https://search.nixos.org/packages?channel=25.11&query=nodejs
   nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
              nodejs
            ];
          };
        });
}
