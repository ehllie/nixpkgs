{ lib, stdenvNoCC, makeSetupHook, nodejs, srcOnly, buildPackages, makeWrapper }:

let
  # We patch npm here to deal with roadblocks involving git depedencies. See
  # front-matter in the patch, but it mainly comes down to these git
  # dependencies must be built and pacote executes its own `npm install` process
  # for this. We need to intercept that to run our own logic to build it
  # similarly to the below hooks instead.
  patchedNode = stdenvNoCC.mkDerivation {
    name = "${nodejs.name}-patched";

    src = buildPackages.nodejs;

    patches = [ ./npm.patch ];

    bash = lib.getExe buildPackages.bash;
    prefetchNpmDeps = lib.getExe buildPackages.prefetch-npm-deps;

    postPatch = ''
      substituteAllInPlace lib/node_modules/npm/node_modules/pacote/lib/git.js

      # We're careful here since the `node` binary contains references to this path, but we can't
      # modify it or else things will implode on Darwin.
      find . -type f | xargs sed -i "s|#!${buildPackages.nodejs}|#!$out|g"
      sed -i "s|${buildPackages.nodejs}|$out|g" include/node/config.gypi
    '';

    installPhase = ''
      runHook preInstall

      cp -a . "$out"

      runHook postInstall
    '';

    dontFixup = true;
  };
in
{
  npmConfigHook = makeSetupHook
    {
      name = "npm-config-hook";
      substitutions = {
        inherit patchedNode;

        nodeSrc = srcOnly nodejs;

        # Specify `diff`, `jq`, and `prefetch-npm-deps` by abspath to ensure that the user's build
        # inputs do not cause us to find the wrong binaries.
        diff = "${buildPackages.diffutils}/bin/diff";
        jq = "${buildPackages.jq}/bin/jq";
        prefetchNpmDeps = "${buildPackages.prefetch-npm-deps}/bin/prefetch-npm-deps";

        nodeVersion = nodejs.version;
        nodeVersionMajor = lib.versions.major nodejs.version;
      };
    } ./npm-config-hook.sh;

  npmBuildHook = makeSetupHook
    {
      name = "npm-build-hook";
    } ./npm-build-hook.sh;

  npmInstallHook = makeSetupHook
    {
      name = "npm-install-hook";
      propagatedBuildInputs = [ buildPackages.makeWrapper ];
      substitutions = {
        hostNode = "${nodejs}/bin/node";
        jq = "${buildPackages.jq}/bin/jq";
      };
    } ./npm-install-hook.sh;
}
