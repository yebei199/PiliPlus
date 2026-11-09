{
  description = "PiliPlus, packaged from the official Linux release";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      piliplus = pkgs.callPackage ./nix/package.nix { };
    in
    {
      packages.${system} = {
        inherit piliplus;
        default = piliplus;
      };
      apps.${system}.default = {
        type = "app";
        program = "${piliplus}/bin/piliplus";
      };
    };
}
