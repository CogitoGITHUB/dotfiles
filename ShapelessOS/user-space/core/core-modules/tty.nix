{ config, pkgs, ... }:

{
  # Console keymap
  console.keyMap = "dvorak";

  # You could also set console font (optional)
  console.font = "Lat2-Terminus16";

  # Other tty settings, if you want:
  # - getty options
  # - automatic login
  # - limiting terminal lines
  # - screen blanking, etc.

  # Example: disable blanking
  console.blankTime = 0;
}
