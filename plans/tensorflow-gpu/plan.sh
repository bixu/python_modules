pkg_origin=pip
pkg_name=tensorflow-gpu
module_name=tensorflow_gpu
pkg_version=1.11.0
source $PLAN_CONTEXT/../../functions/callbacks.sh
python_major_version="3.6"
python_minor_version="6"
pkg_build_deps=(
  bixu/cacher
  core/cuda
  core/curl
  core/gcc
  core/inetutils
  core/jq-static
  core/jq-static
  core/libffi
  core/python36/"${python_major_version}"."${python_minor_version}"
)

do_build() {
  unset DO_CHECK # we cannot attempt to import this module in our tests without GPU hardware
  pip install --quiet --no-dependencies "https://storage.googleapis.com/tensorflow/linux/gpu/${module_name}-${pkg_version}-cp36-cp36m-linux_x86_64.whl"

  # remove references to enum34 to work around https://github.com/tensorflow/tensorflow/issues/15136
  pip_prefix="${pkg_prefix}/lib/python${python_major_version}/site-packages"
  sed -i '/enum34/d' ${pip_prefix}/${module_name}-${pkg_version}.dist-info/METADATA
  return $?
}
