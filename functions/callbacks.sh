# shellcheck disable=SC2148
# shellcheck disable=SC2034
pkg_maintainer="Blake Irvin <blakeirvin@me.com>"
# shellcheck disable=SC2034
pkg_lib_dirs=("lib")
python_major_version="3.7"
python_minor_version="0"
# shellcheck disable=SC2034
pkg_build_deps=(
  "bixu/cacher"
  "core/pcre"
  "core/curl"
  "core/gcc"
  "core/inetutils"
  "core/jq-static"
  "core/libffi"
  "core/python/${python_major_version}.${python_minor_version}"
)

pkg_version() {
  export LC_ALL="en_US" LANG="en_US"
  # shellcheck disable=SC2154
  pip search --disable-pip-version-check "${pkg_name}" \
    | grep "^${pkg_name} " \
    | cut -d\( -f2 | cut -d\) -f1
}

do_before() {
  update_pkg_version
  if hab pkg install ${pkg_origin}/${pkg_name}/${pkg_version} &> /dev/null
  then
    build_line "${pkg_origin}/${pkg_name}/${pkg_version} has already been"
    build_line "vendored to Builder. See :"
    build_line "  https://bldr.habitat.sh/#/pkgs/${pkg_origin}/${pkg_name}"
    exit_with "" 0
  fi
}

do_setup_environment() {
  # shellcheck disable=SC2154
  push_runtime_env   PYTHONPATH      "${pkg_prefix}/lib/python${python_major_version}/site-packages"

  HAB_ENV_LD_LIBRARY_PATH_SEPARATOR=:
  push_buildtime_env LD_LIBRARY_PATH "$(pkg_path_for core/gcc)/lib"
  push_buildtime_env LD_LIBRARY_PATH "$(pkg_path_for core/libffi)/lib"
  push_buildtime_env LD_LIBRARY_PATH "$(pkg_path_for core/pcre)/lib"

  # shellcheck disable=SC2154
  set_buildtime_env  PKG_IDENT       "${pkg_origin}/${pkg_name}/${pkg_version}/${pkg_release}"
  return $?
}

_record_pkg_metadata() {
  echo "export pkg_origin=$pkg_origin
export pkg_name=$pkg_name
export pkg_version=$pkg_version
export pkg_release=$pkg_release" > '/src/pkg.env'
return $?
}

_promote_pkg() {
  source '/src/pkg.env'
  hab origin key download "$pkg_origin" --secret
  hab origin key download "$pkg_origin"
  hab pkg upload "/src/results/$pkg_origin-$pkg_name-$pkg_version-$pkg_release-x86_64-linux.hart"
  hab pkg promote "$pkg_origin/$pkg_name/$pkg_version/$pkg_release" $1
  return $?
}

do_prepare() {
  python -m venv "${pkg_prefix}"
  # shellcheck disable=SC1090
  source "${pkg_prefix}/bin/activate"
  pip install --upgrade --quiet --no-cache-dir "pip"
  _record_pkg_metadata
  return $?
}

do_build() {
  pip install --quiet --no-cache-dir "${pkg_name}==${pkg_version}"
  return $?
}

do_check() {
  # python modules are normally imported by whatever prefix comes before a `-`
  module_name=$(echo -n ${pkg_name} | cut -d- -f1)
  build_line "Attempting import of \`${module_name}\` Python module"
  if python -c "import ${module_name}; print(${module_name}.__version__)" \
    > /dev/null
  then
    build_line "Import of  \`${module_name}\` Python module successful"
    return 0
  else
    build_line "Import of  \`${module_name}\` module failed"
    return 1
  fi
}

do_install() {
  return 0
}

do_strip() {
  for module in $(pip freeze | grep -v $pkg_name==$pkg_version)
  do
    pip uninstall --yes "${module}"
  done
  rm -rf ${pkg_prefix}/lib/python${python_major_version}/site-packages/pip*
  rm -rf ${pkg_prefix}/lib64/python${python_major_version}/site-packages/pip*
  rm -rf ${pkg_prefix}/lib/python${python_major_version}/site-packages/setuptools*
  rm -rf ${pkg_prefix}/lib64/python${python_major_version}/site-packages/setuptools*
  rm -rf ${pkg_prefix}/bin/pip*
  return $?
}

do_after_success() {
  _promote_pkg "stable"
  return $?
}
