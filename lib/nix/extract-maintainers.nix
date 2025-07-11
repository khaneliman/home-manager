{
  lib ? import ../../modules/lib/stdlib-extended.nix (import <nixpkgs> {}).lib,
  pkgs ? import <nixpkgs> {},
  changedFilesJson ? throw "provide either changedFiles or changedFilesJson",
  changedFiles ? builtins.fromJSON changedFilesJson,
}:
let
  # Create a minimal config to get access to the maintainers evaluation
  config = {};
  
  # Helper function for safe evaluation
  try = expr: fallback:
    let
      result = builtins.tryEval expr;
    in
      if result.success then result.value else fallback;
  
  # Process each changed file to extract maintainers
  extractMaintainersFromFile = file:
    let
      # Only process files in the modules directory
      isModuleFile = lib.hasPrefix "modules/" file && lib.hasSuffix ".nix" file;
      
      # Try to evaluate the module to get maintainers
      moduleResult = if isModuleFile then
        try
          (let
            module = import (../../. + "/${file}") { inherit lib pkgs config; };
          in
            module.meta.maintainers or []
          )
          []
      else
        [];
    in
      moduleResult;

  # Extract maintainers from all changed files
  allMaintainers = lib.pipe changedFiles [
    (map extractMaintainersFromFile)
    lib.concatLists
    lib.unique
  ];

  # Extract GitHub usernames
  githubUsers = lib.pipe allMaintainers [
    (lib.filter (maintainer: maintainer ? github))
    (map (maintainer: maintainer.github))
    lib.unique
  ];

in
githubUsers