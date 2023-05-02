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
  pname = "tailwindcss-language-server";
  version = "0.9.11";

  src = fetchFromGitHub {
    owner = "tailwindlabs";
    repo = "tailwindcss-intellisense";
    rev = "v${version}";
    hash = "sha256-+KG7dE0gk9fJGeL2hDlgyYFgEs9dcXwFSEM4kJckn5o=";
  };

  npmDepsHash = "sha256-oAr9RsJ8/BHHlduzu/6FK1fPZAl4qWMQYtXuLTffGTU=";

  makeCacheWritable = true;

  # nativeBuildInputs = [ python3 ];

  # buildInputs = optionals isDarwin [ CoreServices ];

  # npmFlags = [ "--build-from-resource" ];

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.mit;
    maintainers = [ maintainers.ehllie ];
  };
}
