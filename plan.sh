pkg_name=python_modules
pkg_origin=pip
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_source="http://some_source_url/releases/${pkg_name}-${pkg_version}.tar.gz"

do_download() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  return 0
}

do_begin() {
  export HAB_ORIGIN="pip"
  for plan in "$PLAN_CONTEXT/plans/*"
  do
    hab pkg build "${plan}"
    return $?
  done
}

do_build() {
  return 0
}

do_install() {
  return 0
}
