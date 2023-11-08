{ buildNpmPackage
, darwin
, fetchFromGitHub
, fetchNpmDeps
, lib
, symlinkJoin
, python3
, stdenv
}:

buildNpmPackage rec {
  pname = "pyright";
  version = "1.1.335";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = pname;
    rev = version;
    hash = "sha256-wj+LnbfO+jma9L34Z+ZOZs4tAc8VQu4oGLQ8ITvTPMs=";
  };

  npmDepsHash = "sha256-UnhKh5C4IOC+ReUrzk0cw+gBsFpt8TwL9/T1E2jfdRg=";

  npmWorkspace = "packages/pyright";

  npmExtraLockfileDirs = [
    "packages/pyright-internal"
    "packages/vscode-pyright"
    "packages/pyright"
  ];

  meta = with lib; {
    description = "Static Type Checker for Python";
    homepage = "https://github.com/microsoft/pyright";
    license = licenses.mit;
    maintainers = [ maintainers.ehllie ];
  };
}
