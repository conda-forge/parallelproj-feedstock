#!/bin/bash
set -ex

#######################
# patch nvcc according to jaimergp
cat <<"EOF" > $BUILD_PREFIX/bin/nvcc
#!/bin/bash

for arg in "${@}" ; do
  case ${arg} in -ccbin | --compiler-bindir)
    # If -ccbin argument is already provided, don't add an additional one.
    exec "${CUDA_HOME}/bin/nvcc" "${@}"
  esac
done
exec "${CUDA_HOME}/bin/nvcc" -ccbin "${CXX}" "${@}"
EOF
#######################


mkdir build
cd build

if [[ ${cuda_compiler_version:-None} != "None" ]]; then
  EXTRA_CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=all"
else
  EXTRA_CMAKE_ARGS="-DSKIP_CUDA_LIB=TRUE"
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
