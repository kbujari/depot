{
  writeShellScriptBin,
  grim,
  slurp,
  imagemagick,
  ...
}:

writeShellScriptBin "colorpicker" {
  packages = [
    grim
    slurp
    imagemagick
  ];
} ''grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:-''
