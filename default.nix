import <nixpkgs/nixos> {
  configuration = builtins.toPath (./. + "/configuration.nix");
}
