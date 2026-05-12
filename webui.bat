@echo off
REM #################################################
REM CPU-only install script for Stable Diffusion WebUI
REM Optimized for lightweight environments + TCMalloc
REM #################################################

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set INSTALL_DIR=%SCRIPT_DIR%
set CLONE_DIR=stable-diffusion-webui
set PYTHON_CMD=python
set VENV_DIR=venv
set LAUNCH_SCRIPT=launch.py

echo #################################################
echo CPU-only Install Script for Stable Diffusion WebUI
echo #################################################

REM Check prerequisites
where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: git is not installed, aborting...
    exit /b 1
)

where %PYTHON_CMD% >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed, aborting...
    exit /b 1
)

REM Clone repo if missings
if not exist "%INSTALL_DIR%\%CLONE_DIR%" (
    echo Cloning Stable Diffusion WebUI repo...
    git clone https://github.com/Akul-af/stable-diffusion-cpu.git "%CLONE_DIR%"
)

cd "%INSTALL_DIR%\%CLONE_DIR%" || exit /b 1

REM Create venv if missing
if not exist "%VENV_DIR%" (
    echo Creating Python venv...
    %PYTHON_CMD% -m venv %VENV_DIR%
    call "%VENV_DIR%\Scripts\activate.bat"
    python -m pip install --upgrade pip
) else (
    call "%VENV_DIR%\Scripts\activate.bat"
)

REM Install CPU-only PyTorch wheels
echo Installing CPU-only PyTorch...
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu

REM Install other requirements
echo Installing project requirements...
pip install -r requirements-cpu.txt

REM Prepare TCMalloc (Windows note)
REM On Windows, TCMalloc is not commonly available.
REM If you have installed Google Perftools manually, set PATH to include it.
REM Example:
REM set PATH=%PATH%;C:\path\to\tcmalloc

echo Launching WebUI...
python %LAUNCH_SCRIPT% %*
