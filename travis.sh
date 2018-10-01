#!/bin/bash

set -ex

main() {
  install_habitat
  build_all
}

install_habitat() {
  curl "https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh" | sudo bash
  hab origin key download --secret --auth="${HAB_AUTH_TOKEN}" pip
  hab origin key download --auth="${HAB_AUTH_TOKEN}" pip
  return $?
}

build_all() {
  for plan in plans/*
  do
    pkg_origin="$(grep pkg_origin= plans/numpy/plan.sh | cut -d= -f2)"
    #shellcheck disable=SC2034
    local HAB_ORIGIN="${pkg_origin}"
    hab pkg build "${plan}"
    return $?
  done
}

main
