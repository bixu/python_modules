pkg_maintainer="smartB Engineering <dev@smartb.eu>"
pkg_lib_dirs=(lib)
python_major_version="3.7"
python_minor_version="0"
pkg_build_deps=(
  core/inetutils
  core/curl
  core/gcc
  core/jq-static
  core/libffi
  core/python/${python_major_version}.${python_minor_version}
)

do_before() {
  update_pkg_version
}

do_setup_environment() {
  push_runtime_env   PYTHONPATH      "${pkg_prefix}/lib/python${python_major_version}/site-packages"
  push_buildtime_env LD_LIBRARY_PATH "$(pkg_path_for core/gcc)/lib"
  push_buildtime_env LD_LIBRARY_PATH "$(pkg_path_for core/libffi)/lib"
  push_buildtime_env LD_LIBRARY_PATH "$(pkg_path_for core/pcre)/lib"
  return $?
}

do_prepare() {
  python -m venv "${pkg_prefix}"
  source "${pkg_prefix}/bin/activate"
  pip install --upgrade pip
  return $?
}

do_build() {
  return 0
}

do_install() {
  pip install --quiet --no-cache-dir "${pkg_name}==${pkg_version}"
  export module_version=$(python -c "import ${pkg_name}; print(${pkg_name}.__version__)")
  build_line "${pkg_name} version: ${module_version}"
  return $?
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
