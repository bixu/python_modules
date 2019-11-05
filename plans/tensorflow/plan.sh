pkg_origin=pip
pkg_name=tensorflow
pkg_version=1.11.0
source $PLAN_CONTEXT/../../functions/callbacks.sh
python_major_version="3.6"
python_major_version_stripped="$(echo -n ${python_major_version} | tr -d .)"
python_minor_version="6"
pkg_build_deps=(
  "bixu/cacher"
  "core/curl"
  "core/gcc"
  "core/inetutils"
  "core/jq-static"
  "core/jq-static"
  "core/libffi"
  "core/pcre"
  "core/python${python_major_version_stripped}/${python_major_version}.${python_minor_version}"
)

do_build() {
	pip install \
    --quiet \
    --no-dependencies "https://storage.googleapis.com/tensorflow/linux/cpu/\
${pkg_name}-${pkg_version}-cp${python_major_version_stripped}-\
cp${python_major_version_stripped}m-manylinux2010_x86_64.whl"
  return $?
}
