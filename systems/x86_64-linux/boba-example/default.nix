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

  services.bobaboard = {
    enable = true;

    database = {
      user = "postgres";
      host = "127.0.0.1";
      local = true;
      seed = true;
    };

    server = {
      # This has to be an address whose DNS is mapped to this
      # server. It can be the address of any realm (or of no realm),
      # as long as the DNS is mapped.
      backend = {
        address = "api.bobaboard.gay";
      };
      name =  "^(?<subdomain>.+)bobaboard\.gay$";
    };

    firebaseCredentials = "/var/lib/bobaboard/firebase-sdk.json";

    ssl = {
      certificate = "${config.security.acme.certs."bobaboard.gay".directory}/fullchain.pem";
      key = "${config.security.acme.certs."bobaboard.gay".directory}/key.pem";
    };
  };

   security.acme = {
    acceptTerms = true;

    defaults = {
      email = "essential.randomn3ss@gmail.com";
      # Providers list and settings: https://go-acme.github.io/lego/dns/porkbun/
      dnsProvider = "porkbun";
      dnsPropagationCheck = true;

      # Must be owned by user "acme" and group "nginx"
      credentialsFile = "/var/lib/acme-secrets/porkbun";

      # Makes certificates readable by nginx
      group = lib.mkIf config.services.nginx.enable "nginx";

      # Uncomment this to use the staging server
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";

      # Reload nginx when certs change.
      reloadServices = lib.optional config.services.nginx.enable "nginx.service";
    };

    certs."bobaboard.gay" = {
      domain = "*.bobaboard.gay";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
}