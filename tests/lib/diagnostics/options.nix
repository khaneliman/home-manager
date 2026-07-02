{ lib, ... }:

{
  options.programs.example.enable = lib.mkEnableOption "example";
  options.programs.unused.enable = lib.mkEnableOption "unused";
}
