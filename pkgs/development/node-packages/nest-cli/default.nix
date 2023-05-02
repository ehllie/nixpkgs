{ buildNpmPackage
, darwin
, fetchFromGitHub
, lib
, python3
, stdenv
}:
let
  inherit (darwin.apple_sdk.frameworks) CoreServices;
  inherit (lib) optionals;
  inherit (stdenv) isDarwin;
in

buildNpmPackage rec {
  pname = "nest-cli";
  version = "9.4.2";

  src = fetchFromGitHub {
    owner = "nestjs";
    repo = pname;
    rev = version;
    hash = "sha256-9I6ez75byOPVKvX93Yv1qSM3JaWlmmvZCTjNB++cmw0=";
  };

  # PYTHON = "${python3}/bin/python";

  # buildInputs = optionals isDarwin [ CoreServices ];

  npmDepsHash = "sha256-g6H5sBQMGNgUhP7PtBQT1+eDqPVx0kA5A+HwI5Bx9EY=";

  meta = with lib; {
    description = "CLI tool for Nest applications 🍹";
    homepage = "https://nestjs.com";
    license = licenses.mit;
    maintainers = [ maintainers.ehllie ];
  };
}
