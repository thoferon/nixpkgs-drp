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

    allowPorts = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Set up the firewall to allow traffic on the given interface or on all
        interfaces if none given.
      '';
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

      cmd =
        if cfg.dhcp
          then (if cfg.interface != null
                  then ["--dhcp-ifs=${cfg.interface}"]
                  else [])
          else ["--disable-dhcp"];
    };

    networking.firewall.allowedTCPPorts =
      mkIf (cfg.allowPorts && cfg.interface == null) [8091 8092];
    networking.firewall.allowedUDPPorts =
      mkIf (cfg.allowPorts && cfg.interface == null)
        ([69] ++ (if cfg.dhcp then [67 68 4011] else []));

    networking.firewall.interfaces =
      mkIf (cfg.allowPorts && cfg.interface != null) {
        "${cfg.interface}" = {
          allowedTCPPorts = [8091 8092];
          allowedUDPPorts = [69] ++ (if cfg.dhcp then [67 68 4011] else []);
        };
      };
  };
}
