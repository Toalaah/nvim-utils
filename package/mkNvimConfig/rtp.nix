pkgs: rtp:
pkgs.stdenv.mkDerivation {
  name = "rtp";
  src = rtp;
  phases = ["installPhase"];
  installPhase = ''
    mkdir -p $out
    # sanitize out-path, ex: /nix/store/xxxxxx-file.lua -> file.lua
    for f in $src; do
      out_name="$(basename $f | cut -c 34-)"
      cp -r $f $out/$out_name
    done
  '';
}
