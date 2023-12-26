{ stdenv
, darwin
, lib
, ninja
, gn
, pkg-config
, python3
, ffmpeg
, SDL2
, src
}:
stdenv.mkDerivation {
  name = "shanocast";
  inherit src;
  NIX_CFLAGS_COMPILE =
    if stdenv.isLinux
    then
      (toString [ "-Wno-error=maybe-uninitialized" "-Wno-error=stringop-overflow" "-Wno-error=ignored-attributes" ])
    else
      (toString ["-Wno-error=uninitialized"]);
  ninjaFlags = [ "cast_receiver" ];
  prePatch = ''
    substituteInPlace build/config/sysroot.gni --replace 'sysroot_platform = "bullseye"' ""
    substituteInPlace build/config/BUILD.gn --replace '--target=aarch64-linux-gnu' ""
  '';
  gnFlags = [
    "is_clang=${lib.boolToString stdenv.cc.isClang}"
    "cast_allow_developer_certificate=true"
    "have_ffmpeg=true"
    "have_libsdl2=true"
  ];
  installPhase = ''
    mkdir -p $out/bin
    mv cast_receiver $out/bin/shanocast
  '';
  patches = [
    ./shanocast.patch
  ];
  buildInputs = [
    ffmpeg
    SDL2
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.IOKit
  ];
  nativeBuildInputs = [
    gn
    ninja
    pkg-config
    python3
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.cctools
  ];
}

