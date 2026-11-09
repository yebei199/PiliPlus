{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeDesktopItem,
  copyDesktopItems,
  alsa-lib,
  at-spi2-atk,
  cairo,
  fontconfig,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk3,
  harfbuzz,
  libepoxy,
  libGL,
  libsoup_3,
  libva,
  libvdpau,
  libx11,
  libxi,
  mpv-unwrapped,
  pango,
  vulkan-loader,
  webkitgtk_4_1,
  zlib,
}:

let
  # Written by .github/workflows/nix-track.yml when upstream publishes a release.
  release = lib.importJSON ./release.json;
in
stdenv.mkDerivation {
  pname = "piliplus";
  inherit (release) version;

  src = fetchurl {
    url = "https://github.com/bggRGjQaUbCoE/PiliPlus/releases/download/${release.version}/${lib.escapeURL release.asset}";
    inherit (release) hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    fontconfig
    gdk-pixbuf
    glib
    glib-networking
    gtk3
    harfbuzz
    libepoxy
    libsoup_3
    libx11
    libxi
    mpv-unwrapped
    pango
    stdenv.cc.cc.lib
    webkitgtk_4_1
    zlib
  ];

  # libdartjni links libjvm, but the desktop app does not load it.
  autoPatchelfIgnoreMissingDeps = [ "libjvm.so" ];

  # dlopen resolves against the calling library's RUNPATH, which is not transitive:
  # Dart FFI needs $ORIGIN for the bundled plugins, libmpv needs the GPU loaders.
  appendRunpaths = [
    "$ORIGIN"
    (lib.makeLibraryPath [
      libGL
      libva
      libvdpau
      mpv-unwrapped
      vulkan-loader
    ])
  ];

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  desktopItems = [
    (makeDesktopItem {
      name = "piliplus";
      desktopName = "PiliPlus";
      comment = "A third-party Bilibili client developed in Flutter";
      exec = "piliplus %u";
      icon = "piliplus";
      startupWMClass = "com.example.piliplus";
      categories = [
        "AudioVideo"
        "Video"
        "Player"
      ];
      mimeTypes = [ "x-scheme-handler/bilibili" ];
    })
  ];

  # The Flutter runner resolves data/ and lib/ from /proc/self/exe, so the tree stays intact.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/piliplus $out/bin
    cp -r piliplus data lib $out/lib/piliplus/
    chmod +x $out/lib/piliplus/piliplus
    ln -s $out/lib/piliplus/piliplus $out/bin/piliplus
    install -Dm644 ${../assets/images/logo/desktop/logo_large.png} $out/share/pixmaps/piliplus.png
    runHook postInstall
  '';

  meta = {
    description = "Third-party Bilibili client developed in Flutter";
    homepage = "https://github.com/bggRGjQaUbCoE/PiliPlus";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "piliplus";
    platforms = [ "x86_64-linux" ];
  };
}
