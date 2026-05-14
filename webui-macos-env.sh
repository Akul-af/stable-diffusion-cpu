#!/usr/bin/env bash
#################################################
# CPU‑only install script for Stable Diffusion   #
# Optimized for macOS environments + TCMalloc    #
#################################################

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

install_dir="$SCRIPT_DIR"
clone_dir="stable-diffusion-webui"
python_cmd="python3.10"
venv_dir="venv"
LAUNCH_SCRIPT="launch.py"

if [[ ! -x "$(command -v "${python_cmd}")" ]]; then
  python_cmd="python3"
fi

delimiter="################################################################"
printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mCPU‑only Install Script for Stable Diffusion WebUI (macOS)\e[0m\n"
printf "%s\n" "${delimiter}"

for preq in git "${python_cmd}"; do
  if ! hash "${preq}" &>/dev/null; then
    printf "\e[1m\e[31mERROR: %s not installed, aborting...\e[0m\n" "${preq}"
    exit 1
  fi
done

cd "${install_dir}" || exit 1
if [[ ! -d "${clone_dir}" ]]; then
  printf "Cloning your fork...\n"
  git clone https://github.com/Akul-af/stable-diffusion-webui.git "${clone_dir}"
fi
cd "${clone_dir}" || exit 1

if [[ ! -d "${venv_dir}" ]]; then
  "${python_cmd}" -m venv "${venv_dir}"
  "${venv_dir}"/bin/python -m pip install --upgrade pip
fi

source "${venv_dir}"/bin/activate || { echo "Cannot activate venv"; exit 1; }

pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
pip install -r requirements-cpu.txt

prepare_tcmalloc() {
    TCMALLOC=$(find /usr/local/lib /opt/homebrew/lib -name "libtcmalloc*.dylib" 2>/dev/null | head -n 1)
    if [[ -n "${TCMALLOC}" ]]; then
        export DYLD_INSERT_LIBRARIES="${TCMALLOC}"
    else
        echo "TCMalloc not found. Install google-perftools via Homebrew:"
        echo "  brew install google-perftools"
    fi
}

prepare_tcmalloc
python "${LAUNCH_SCRIPT}" "$@"
