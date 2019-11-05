# shellcheck disable=SC2148
# shellcheck disable=SC2034
pkg_maintainer="Blake Irvin <blakeirvin@me.com>"
# shellcheck disable=SC2034
pkg_lib_dirs=(lib)
python_major_version="3.7"
python_minor_version="0"
# shellcheck disable=SC2034
pkg_build_deps=(
  bixu/cacher
  core/curl
  core/gcc
  core/inetutils
  core/jq-static
  core/libffi
  core/python/"${python_major_version}"."${python_minor_version}"
)

pkg_version() {
  export LC_ALL=en_US LANG=en_US
  # shellcheck disable=SC2154
  pip search --disable-pip-version-check "${pkg_name}" | grep "^${pkg_name} " | cut -d\( -f2 | cut -d\) -f1
}

do_before() {
  update_pkg_version
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

do_prepare() {
  python -m venv "${pkg_prefix}"
  # shellcheck disable=SC1090
  source "${pkg_prefix}/bin/activate"
  pip install --upgrade --quiet --no-cache-dir pip
  return $?
}

do_build() {
  pip install --quiet --no-cache-dir "${pkg_name}==${pkg_version}"
  return $?
}

do_check() {
  module_name=$(echo -n ${pkg_name} | cut -d- -f1) # python modules normally are imported by whatenver name comes before a `-`
  build_line "Attempting import of \`${module_name}\` Python module"
  if python -c "import ${module_name}; print(${module_name}.__version__)" > /dev/null
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
    pip uninstall --yes $module
  done
  rm -rf ${pkg_prefix}/lib/python3.6/site-packages/pip*
  rm -rf ${pkg_prefix}/lib64/python3.6/site-packages/pip*
  rm -rf ${pkg_prefix}/lib/python3.6/site-packages/setuptools*
  rm -rf ${pkg_prefix}/lib64/python3.6/site-packages/setuptools*
  rm -rf ${pkg_prefix}/bin/pip*
  return $?
}
