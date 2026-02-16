{
  writeShellApplication,
  grim,
  slurp,
  imagemagick,
  ...
}:

writeShellApplication {
  name = "colorpicker";
  runtimeInputs = [
    grim
    slurp
    imagemagick
  ];
  text = ''
    grim -g "$(slurp -p)" -t ppm - | magick - -format '%[pixel:p{0,0}]' txt:-
  '';
}
