{ buildGoModule, fetchFromGitHub, pkgs }:

buildGoModule rec {
  name = "drpcli-${version}";
  version = "4.2.4";

  subPackages = ["cmds/drpcli"];

  src = fetchFromGitHub {
    owner = "digitalrebar";
    repo = "provision";
    rev = "v${version}";
    sha256 = "1hp0r2ypq49rh86k4jpz835pch4nksnr5ns8smw2y3kvpfifmn88";
  };

  modSha256 = "0lxdl916kb4yqk6vd4xb3kz8219ikv5vgrzbiaar2yjvncbp4m56";
}
