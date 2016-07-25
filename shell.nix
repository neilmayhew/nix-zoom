{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
with pkgs;

callPackage ./default.nix {}
