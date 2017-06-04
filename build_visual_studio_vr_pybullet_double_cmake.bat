@echo off
for /f "delims=" %%a in ('where python') Do @set python_exe_path=%%a && Goto:found_python_exe
:found_python_exe


FOR /F "delims=" %%i IN ('python -c "import sys;print(sys.maxsize > 2**32)"') DO set is_x64_python=%%i

for %%a in (%python_exe_path%) do set python_dir_path=%%~dpa
echo Found python at %python_dir_path%
echo.

echo Looking for vcvarsall.bat, make sure you've got visual studio installed, otherwise this will fail

echo import os;print([os.path.join(dp, f) for dp, dn, filenames in os.walk("C:\Program Files (x86)\Microsoft Visual Studio") for f in filenames if f=="vcvarsall.bat"][0]) > find_vc.bat.py
FOR /F "delims=" %%i IN ('python find_vc.bat.py') DO set vcvarsall_path=%%i
del find_vc.bat.py

echo executing %vcvarsall_path%
call "%vcvarsall_path%" x86_amd64

If NOT "%is_x64_python%"=="%is_x64_python:True=%" (
    echo you seem to be using 64 bit python, generating 64 bit solution
    set cmake_options=Visual Studio 14 2015 Win64
) else (
    set cmake_options=Visual Studio 14 2015
)

mkdir build_cmake
cd build_cmake
cmake -DBUILD_PYBULLET=ON -DUSE_DOUBLE_PRECISION=ON -DCMAKE_BUILD_TYPE=Release -DPYTHON_INCLUDE_DIR=%python_dir_path%\include -DPYTHON_LIBRARY=%python_dir_path%\libs\python35.lib -DPYTHON_DEBUG_LIBRARY=%python_dir_path%\libs\python35_d.lib -G "%cmake_options%" ..



