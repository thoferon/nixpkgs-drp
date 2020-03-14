{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.services.drp;

in
{
  options.services.drp = {
    enable = mkEnableOption "Digital Rebar Provision";

    image = mkOption {
      type = types.str;
      default = "digitalrebar/provision";
      description = "Docker image to run.";
    };

    imageFile = mkOption {
      type = with types; nullOr package;
      default = null;
      description = "Docker image to load instead of ''image''.";
    };

    dhcp = mkOption {
      type = types.bool;
      default = true;
      description = "Enable DHCP server.";
    };

    interface = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Network interface on which to allow traffic.";
    };
  };

  config = mkIf cfg.enable {
    docker-containers.drp = {
      inherit (cfg) image imageFile;

      autoStart = true;
      volumes = ["/var/lib/drp-data:/provision/drp-data"];

      extraDockerOptions = [
        "--network=host"
      ];

      cmd = if cfg.dhcp then [] else ["--disable-dhcp"];
    };

    networking.firewall.allowedTCPPorts =
      mkIf (cfg.interface == null) [8091 8092];
    networking.firewall.allowedUDPPorts =
      mkIf (cfg.dhcp && cfg.interface == null) [67 68 4011];

    networking.firewall.interfaces = mkIf (cfg.interface != null) {
      "${cfg.interface}" = {
        allowedTCPPorts = [8091 8092];
        allowedUDPPorts = mkIf cfg.dhcp [67 68 4011];
      };
    };
  };
}
