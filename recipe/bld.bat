setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

:: for cuda build, the PATH variable gets too long resultung in commands that are to long
:: to be executed
:: we use a simple python oneliner and a temporary file to remove duplicate entries from PATH to make it shorter
python -c "import os;print(';'.join(list(dict.fromkeys(os.environ['PATH'].split(';')))))">sanitized_path.txt
for /f "delims=" %%x in (sanitized_path.txt) do set PATH=%%x

:: Configure using the CMakeFiles
if NOT "%cuda_compiler_version%"=="None" (
    set EXTRA_CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=all"
)

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
