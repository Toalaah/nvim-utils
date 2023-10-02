#!/bin/sh

find modules -type f -name '*.nix' -exec update-nix-fetchgit {} \;
