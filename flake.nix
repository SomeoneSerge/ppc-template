{
  description = "PPC silly template";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }: {
    devShells =
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      in
      {
        ${system}.default = pkgs.callPackage ./devshell.nix { };
      };
  };
}
