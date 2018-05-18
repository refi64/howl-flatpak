#!/bin/sh

set -e

manifest="$1"
root="$2"
stop="$3"
replace="$4"
run="$5"

run() {
  (echo "+ running: $@"; "$@")
  return $?
}

if [ "$replace" = "replace" ]; then
  run flatpak-builder --force-clean "$root" "$manifest" --stop-at="$stop"
  rm -rf .flatpak-builder/git/
  run flatpak-builder --force-clean "$root" "$manifest" --download-only ||:

  if ! [ -d .flatpak-builder/git/* ]; then
    echo 'The flatpak-build command only works if the main module has a single Git source.'
    exit 1
  fi

  rm -rf .flatpak-builder/local-git
  cp -r .git .flatpak-builder/local-git
  git --git-dir=.flatpak-builder/local-git --work-tree=. add *
  git --git-dir=.flatpak-builder/local-git --work-tree=. commit -m 'initial'

  pushd .flatpak-builder/git/*
  git remote set-url origin "$PWD/../../local-git"
  git fetch origin --force
  popd
fi

run flatpak-builder --force-clean "$root" "$manifest"

if [ "$run" = "run" ]; then
  pushd "$root"
  command="`grep 'command=' metadata | cut -d= -f2`"
  popd

  if [ -z "$command" ]; then
    echo 'Flatpak has no command to run'
    exit 1
  fi

  run flatpak-builder --run --allow=devel "$root" "$manifest" $command
fi
