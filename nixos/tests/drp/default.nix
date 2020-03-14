import <nixpkgs/nixos/tests/make-test-python.nix> ({ pkgs, ... }: {
  name = "drp";

  nodes = {
    drp = { ... }: {
      imports = [
        ../../modules/services/misc/drp
      ];

      services.drp = {
        enable = true;
        imageFile = builtins.fetchurl
          "https://github.com/thoferon/nixpkgs-drp/archive/v4.2.4.tar.gz";
      };
    };
  };

  testScript = builtins.readFile ./tests.py;
})
