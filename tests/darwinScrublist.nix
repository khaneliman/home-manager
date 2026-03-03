{ lib, scrubDerivation }:

let
  # Keep this list intentionally tiny. Everything else is scrubbed by default.
  # These are core package set internals that should stay unscrubbed to avoid
  # breaking nixpkgs evaluation on Darwin.
  packagesToKeep = [
    # keep-sorted start case=no numeric=yes
    "buildPackages"
    "darwin"
    "lib"
    "stdenv"
    # keep-sorted end
  ];

  # Scrub every attr by default, except the minimal keep set above.
  packageScrubOverlay =
    self: super:
    lib.mapAttrs (
      name: value: if lib.elem name packagesToKeep then value else scrubDerivation name value
    ) super;

in
self: super:
packageScrubOverlay self super
// {
  buildPackages = super.buildPackages.extend packageScrubOverlay;
}
