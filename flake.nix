{
  description = "An example of how to selfhost BobaBoard";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  
    bobaboard = {
      url = "github:bobaboard/boba-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  
    snowfall-lib = {
      url = "github:snowfallorg/lib/dev";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils-plus.url = "github:fl42v/flake-utils-plus";
      };
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      src = ./.;

      # Configuration for deploy-rs
      deploy.nodes = {
        boba-gay = {
          hostname = "boba-example";
          profiles.system = {
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.boba-example;
            user = "root";
            sshUser = "root";
          };
        };
      };
  
      systems.modules.nixos = with inputs; [
        vscode-server.nixosModules.default
        bobaboard.nixosModules."services/bobaboard"
      ];

      # These checks will run before deployment to check that everything
      # is configured correctly.
      # NOTE: commented out because it will run checks on MacOS and fail.
      # checks =
      #   builtins.mapAttrs
      #     (system: deploy-lib:
      #       deploy-lib.deployChecks inputs.self.deploy)
      #     inputs.deploy-rs.lib;
    };
}