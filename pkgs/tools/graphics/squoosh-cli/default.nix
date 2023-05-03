{ buildNpmPackage
, fetchFromGitHub
, lib
}:

buildNpmPackage rec {
  pname = "squoosh-cli";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "GoogleChromeLabs";
    repo = "squoosh";
    rev = "v${version}";
    hash = "sha256-Av00rh8IohQonCcjTtI+V4QWAbd6/51mqUlFydaUZaA=";
  };

  # Generated a new package-lock.json by running `npm upgrade`
  # The upstream lockfile is using an old version of `fsevents`,
  # which does not build on Darwin
  # postPatch = ''
  #   cp ${./package-lock.json} ./package-lock.json
  # '';

  npmDepsHash = "sha256-R/jjI27EAPSkAnUeOwZmgNYCeIxlMwqTcLVM+G2HLPc=";

  meta = with lib; {
    description = "Squoosh CLI is an experimental way to run all the codecs you know from the Squoosh web app on your command line using WebAssembly.";
    homepage = "github.com/GoogleChromeLabs/squoosh";
    license = licenses.asl20;
    maintainers = [ maintainers.ehllie ];
  };
}
