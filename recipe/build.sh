#!/bin/bash
set -ex

mkdir build
cd build

if [[ ${cuda_compiler_version:-None} != "None" ]]; then
  EXTRA_CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=all"
fi

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DSKIP_DOCS=TRUE \
    ${EXTRA_CMAKE_ARGS} \
    ${SRC_DIR}

cmake --build . --target install --verbose 

if [[ ${CONDA_BUILD_CROSS_COMPILATION:-0} -ne 1 ]]; then
    ctest -VV
else
  echo "Cross-compiling. Skipping ctest."
fi
