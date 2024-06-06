{ pkgs, inputs, lib, config, ... }: {
  imports = [
    ./hardware.nix
    # Generated at runtime by nixos-infect
    ./networking.nix
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
  ];

  programs.git.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins=["git" "vi-mode" "systemd" "z"];
    };
  };
  services.vscode-server.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE08e9yPCfh8kEp/sUxzF+hJIkOnoPCrjwjUNr3cdt2I"
  ];

  users.users.msboba = {
    isNormalUser = true;

    name = "msboba";
    initialPassword = "password";

    home = "/home/msboba";
    group = "users";
  
    shell = pkgs.zsh;

    # wheel is needed for sudo
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE08e9yPCfh8kEp/sUxzF+hJIkOnoPCrjwjUNr3cdt2I"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
}