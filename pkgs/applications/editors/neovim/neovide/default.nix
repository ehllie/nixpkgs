{ rustPlatform
, runCommand
, lib
, fetchFromGitHub
, fetchgit
, fetchurl
, makeWrapper
, pkg-config
, python2
, python3
, openssl
, SDL2
, fontconfig
, freetype
, ninja
, gn
, llvmPackages
, makeFontsConf
, libicns
, libglvnd
, libxkbcommon
, stdenv
, enableWayland ? stdenv.isLinux
, wayland
, xorg
, xcbuild
, Security
, ApplicationServices
, AppKit
, Carbon
, removeReferencesTo
}:
rustPlatform.buildRustPackage rec {
  pname = "neovide";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "Kethku";
    repo = "neovide";
    rev = version;
    sha256 = "sha256-CcBiCcfOJzuq0DnokTUHpMdo7Ry29ugQ+N7Hk0R+cQE=";
  };

  cargoSha256 = "sha256-bS7yBnxAWPoTTabxI6W5Knl1DFiDztYSkEPJMa8bqlY=";

  SKIA_SOURCE_DIR =
    let
      repo = fetchFromGitHub {
        owner = "rust-skia";
        repo = "skia";
        # see rust-skia:skia-bindings/Cargo.toml#package.metadata skia
        rev = "m103-0.51.1";
        sha256 = "sha256-w5dw/lGm40gKkHPR1ji/L82Oa808Kuh8qaCeiqBLkLw=";
      };
      # The externals for skia are taken from skia/DEPS
      externals = lib.mapAttrs (n: fetchgit) (lib.importJSON ./skia-externals.json);
    in
      runCommand "source" {} (
        ''
          cp -R ${repo} $out
          chmod -R +w $out

          mkdir -p $out/third_party/externals
          cd $out/third_party/externals
        '' + (builtins.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "cp -ra ${value} ${name}") externals))
      );

  SKIA_NINJA_COMMAND = "${ninja}/bin/ninja";
  SKIA_GN_COMMAND = "${gn}/bin/gn";
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  preConfigure = ''
    unset CC CXX
  '';

  # test needs a valid fontconfig file
  FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ ]; };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    python2 # skia-bindings
    python3 # rust-xcb
    llvmPackages.clang # skia
    removeReferencesTo
  ] ++ lib.optionals stdenv.isDarwin [
    xcbuild
    libicns
  ];

  # All tests passes but at the end cargo prints for unknown reason:
  #   error: test failed, to rerun pass '--bin neovide'
  # Increasing the loglevel did not help. In a nix-shell environment
  # the failure do not occure.
  doCheck = false;

  buildInputs = [
    openssl
    SDL2
    (fontconfig.overrideAttrs (old: {
      propagatedBuildInputs = [
        # skia is not compatible with freetype 2.11.0
        (freetype.overrideAttrs (old: rec {
          version = "2.10.4";
          src = fetchurl {
            url = "mirror://savannah/${old.pname}/${old.pname}-${version}.tar.xz";
            sha256 = "112pyy215chg7f7fmp2l9374chhhpihbh8wgpj5nj6avj3c59a46";
          };
        }))
      ];
    }))
  ] ++ lib.optionals stdenv.isDarwin [ Security ApplicationServices Carbon AppKit ];

  postFixup = let
    libPath = lib.makeLibraryPath ([
      libglvnd
      libxkbcommon
      xorg.libXcursor
      xorg.libXext
      xorg.libXrandr
      xorg.libXi
    ] ++ lib.optionals enableWayland [ wayland ]);
  in ''
      # library skia embeds the path to its sources
      remove-references-to -t "$SKIA_SOURCE_DIR" \
        $out/bin/neovide

      wrapProgram $out/bin/neovide \
        --prefix LD_LIBRARY_PATH : ${libPath}
    '';

  postInstall =
    if stdenv.isDarwin then
      let
        bundleMeta = (builtins.fromTOML (builtins.readFile "${src}/Cargo.toml")).package.metadata.bundle;
        pListText = lib.generators.toPlist { } {
          CFBundleDevelopmentRegion = "English";
          CFBundleDisplayName = bundleMeta.name;
          CFBundleExecutable = "neovide";
          CFBundleIconFile = "neovide.icns";
          CFBundleIconFiles = [ "neovide.icns" ];
          CFBundleIdentifier = bundleMeta.identifier;
          CFBundleInfoDictionaryVersion = "6.0";
          CFBundleName = bundleMeta.name;
          CFBundlePackageType = "APPL";
          CFBundleSignature = "???";
          CFBundleVersion = version;
          LSMinimumSystemVersion = bundleMeta.osx_minimum_system_version;
          NSHighResolutionCapable = true;
          NSHumanReadableCopyright = bundleMeta.copyright;
        };
      in
      ''
        mkdir -p $out/Applications/Neovide.app/Contents
        ln -s $out/bin $out/Applications/Neovide.app/Contents/MacOS

        cat > "$out/Applications/Neovide.app/Contents/Info.plist" <<EOF
        ${pListText}
        EOF

        png2icns neovide.icns \
          assets/neovide-16x16.png \
          assets/neovide-32x32.png \
          assets/neovide-48x48.png \
          assets/neovide-256x256.png \

        install -m444 -Dt $out/Applications/Neovide.app/Contents/Resources neovide.icns
      ''
    else ''
      for n in 16x16 32x32 48x48 256x256; do
        install -m444 -D "assets/neovide-$n.png" \
          "$out/share/icons/hicolor/$n/apps/neovide.png"
      done
      install -m444 -Dt $out/share/icons/hicolor/scalable/apps assets/neovide.svg
      install -m444 -Dt $out/share/applications assets/neovide.desktop
    '';

  disallowedReferences = [ SKIA_SOURCE_DIR ];

  meta = with lib; {
    description = "This is a simple graphical user interface for Neovim.";
    homepage = "https://github.com/Kethku/neovide";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ck3d ];
    platforms = platforms.all;
    mainProgram = "neovide";
  };
}
