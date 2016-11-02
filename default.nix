# The Debian pkg has private copies of all the Qt libs it uses
# gtk2 is needed for theming

{ stdenv, fetchurl, dpkg, patchelf, makeWrapper,
  gtk2, glib, dbus_libs,
  libX11, libXi, libXcursor, libXext, libXfixes, libXrender, libXcomposite, libXdamage, libXtst,
  libxcb, xcbutilimage, xcbutilkeysyms, mesa, xorg,
  alsaLib, libpulseaudio, libuuid, sqlite, nss, nspr, fontconfig, freetype,
  libxml2, libxslt, zlib,
  xkeyboard_config }:

let
  version = "2.0.57232.0713";

  librarypath = stdenv.lib.makeLibraryPath [
    stdenv.cc.cc
    gtk2 glib dbus_libs
    libX11 libXi libXcursor libXext libXfixes libXrender libXcomposite libXdamage libXtst
    libxcb xcbutilimage xcbutilkeysyms mesa xorg.libICE xorg.libSM
    alsaLib libpulseaudio libuuid sqlite nss nspr fontconfig freetype
    libxml2 libxslt zlib ];
in
  stdenv.mkDerivation rec {

    name = "zoom-${version}";

    src = fetchurl {
      url = "https://d11yldzmag5yn.cloudfront.net/prod/${version}/zoom_${version}_amd64.deb";
      sha256 = "0dgy9gdh9z42v8im465bl01dmyyshrd3b2h4jnqcf4zaarzyd6sz";
    };

    phases = "installPhase";

    buildInputs = [ dpkg makeWrapper ];

    installPhase = ''
      dpkg-deb -x ${src} $out
      mv $out/usr/share $out
      rm -r $out/usr

      interpreter=$(<$NIX_CC/nix-support/dynamic-linker)

      for F in $out/opt/zoom/{zoom,ZoomLauncher}; do
        patchelf --set-interpreter $interpreter $F
      done

      makeWrapper $out/opt/zoom/zoom $out/bin/zoom --argv0 /usr/bin/zoom \
        --prefix LD_LIBRARY_PATH : ${librarypath}:$out/opt/zoom \
        --prefix QT_XKB_CONFIG_ROOT : ${xkeyboard_config}/share/X11/xkb
    '';

    meta = with stdenv.lib; {
      homepage = https://zoom.us/;
      description = "The Zoom Video Conferencing client";
      longDescription = ''
        Zoom, the cloud meeting company, unifies cloud video
        conferencing, simple online meetings, and group messaging into
        one easy-to-use platform. Our solution offers the best video,
        audio, and screen-sharing experience across Zoom Rooms,
        Windows, Mac, Linux, iOS, Android, and H.323/SIP room systems.
      '';
      license = stdenv.lib.licenses.unfree;
      maintainers = [ "Neil Mayhew <neil_mayhew@users.sourceforge.net>" ];
      platforms = platforms.linux;
    };
  }
