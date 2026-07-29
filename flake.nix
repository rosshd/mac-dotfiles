{
  description = "Ross keyboard-first macOS development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      username = "ross";
      homeDirectory = "/Users/${username}";
    in {
      darwinConfigurations."Rosss-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username homeDirectory; };
        modules = [
          ./nix/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./nix/home.nix;
            home-manager.extraSpecialArgs = { inherit username homeDirectory; };
          }
        ];
      };
    };
}
