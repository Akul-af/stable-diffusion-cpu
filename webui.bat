@echo off
REM #################################################
REM CPU-only install script for Stable Diffusion WebUI
REM Optimized for lightweight environments
REM #################################################

set SCRIPT_DIR=%~dp0
set INSTALL_DIR=%SCRIPT_DIR%
set CLONE_DIR=stable-diffusion-webui
set PYTHON_CMD=python
set VENV_DIR=venv
set LAUNCH_SCRIPT=launch.py

echo #################################################
echo CPU-only Install Script for Stable Diffusion WebUI (Windows)
echo #################################################

where git >nul 2>&1 || (echo ERROR: git not installed & exit /b 1)
where %PYTHON_CMD% >nul 2>&1 || (echo ERROR: Python not installed & exit /b 1)

if not exist "%INSTALL_DIR%\%CLONE_DIR%" (
    echo Cloning your fork...
    git clone https://github.com/Akul-af/stable-diffusion-webui.git "%CLONE_DIR%"
)

cd "%INSTALL_DIR%\%CLONE_DIR%" || exit /b 1

if not exist "%VENV_DIR%" (
    %PYTHON_CMD% -m venv %VENV_DIR%
    call "%VENV_DIR%\Scripts\activate.bat"
    python -m pip install --upgrade pip
) else (
    call "%VENV_DIR%\Scripts\activate.bat"
)

pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
pip install -r requirements-cpu.txt

echo Launching WebUI...
python %LAUNCH_SCRIPT% %*
