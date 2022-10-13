{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "aliyun-cli";
  version = "3.0.128";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "aliyun";
    repo = pname;
    fetchSubmodules = true;
    sha256 = "sha256-FKynQXvxWU4adGzLTKkRpGCej1So8XbeqqGYu0RM4Rw=";
  };

  vendorSha256 = "sha256-p1QRYXPetuC8jkPRx54jIKBN5WHgrw4/TZ2RUK2kzDU=";

  subPackages = [ "main" ];

  ldflags = [ "-s" "-w" "-X github.com/aliyun/aliyun-cli/cli.Version=${version}" ];

  postInstall = ''
    mv $out/bin/main $out/bin/aliyun
  '';

  meta = with lib; {
    description = "Tool to manage and use Alibaba Cloud resources through a command line interface";
    homepage = "https://github.com/aliyun/aliyun-cli";
    changelog = "https://github.com/aliyun/aliyun-cli/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ ornxka ];
    mainProgram = "aliyun";
  };
}
