setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

echo "####################################################"
echo "####################################################"
echo "####### cuda_compiler_version#######################"
echo "%cuda_compiler_version%"
echo "####################################################"
echo "####################################################"
echo "####################################################"


if "%cuda_compiler_version%"=="None" (
    set EXTRA_CMAKE_ARGS="-DSKIP_CUDA_LIB=TRUE"
) else (
    set EXTRA_CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=all"
)

echo "####################################################"
echo "####################################################"
echo "####### CMAKE EXTRA ARGS ###########################"
echo %EXTRA_CMAKE_ARGS%
echo "####################################################"
echo "####################################################"
echo "####################################################"



:: Configure using the CMakeFiles
cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DSKIP_DOCS=TRUE ^
    %EXTRA_CMAKE_ARGS% ^
    %SRC_DIR%
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --target install --verbose 
ctest -VV
if %ERRORLEVEL% neq 0 exit 1
