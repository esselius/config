{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    ez-configs.url = "github:ehllie/ez-configs";
    authentik-nix.url = "github:nix-community/authentik-nix/node-22";
    authentik-nix.inputs.authentik-src.url = "github:esselius/authentik/patch-1";
    nixos-tests.url = "github:esselius/nixos-tests";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        inputs.ez-configs.flakeModule
        inputs.nixos-tests.flakeModule
      ];

      systems = [ "aarch64-linux" "aarch64-darwin" "x86_64-linux" "x86_64-darwin" ];

      ezConfigs.root = ./.;

      perSystem = { pkgs, ... }: {
        devshells.default = {
          env = [{
            name = "PLAYWRIGHT_BROWSERS_PATH";
            value = pkgs.playwright-driver.browsers;
          }];
        };

        nixosTests = {
          path = ./tests;
          args = {
            inherit inputs;
            myModules = self.nixosModules;
          };
        };
      };
    };
}
