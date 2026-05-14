#!/usr/bin/env bash
#################################################
# CPU‑only install script for Stable Diffusion   #
# Optimized for lightweight environments + TCMalloc
#################################################

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Defaults
install_dir="$SCRIPT_DIR"
clone_dir="stable-diffusion-webui"
python_cmd="python3.10"
venv_dir="venv"
LAUNCH_SCRIPT="launch.py"

# Fallback if python3.10 not found
if [[ ! -x "$(command -v "${python_cmd}")" ]]; then
  python_cmd="python3"
fi

delimiter="################################################################"
printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mCPU‑only Install Script for Stable Diffusion WebUI (Linux)\e[0m\n"
printf "%s\n" "${delimiter}"

# Check prerequisites
for preq in git "${python_cmd}"; do
  if ! hash "${preq}" &>/dev/null; then
    printf "\e[1m\e[31mERROR: %s is not installed, aborting...\e[0m\n" "${preq}"
    exit 1
  fi
done

# Clone your fork if missing
cd "${install_dir}" || exit 1
if [[ ! -d "${clone_dir}" ]]; then
  printf "Cloning your fork...\n"
  git clone https://github.com/Akul-af/stable-diffusion-webui.git "${clone_dir}"
fi
cd "${clone_dir}" || exit 1

# Create venv if missing
if [[ ! -d "${venv_dir}" ]]; then
  "${python_cmd}" -m venv "${venv_dir}"
  "${venv_dir}"/bin/python -m pip install --upgrade pip
fi

# Activate venv
source "${venv_dir}"/bin/activate || { echo "Cannot activate venv"; exit 1; }

# Install CPU‑only PyTorch wheels
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu

# Install other requirements
pip install -r requirements-cpu.txt

# Prepare TCMalloc
prepare_tcmalloc() {
    TCMALLOC=$(ldconfig -p | grep -E 'libtcmalloc(_minimal|)?\.so\.[0-9]+' | head -n 1)
    if [[ -n "${TCMALLOC}" ]]; then
        export LD_PRELOAD=$(echo "${TCMALLOC}" | awk '{print $NF}')
    else
        echo "TCMalloc not found. Install google-perftools for better CPU memory usage."
    fi
}

prepare_tcmalloc
python "${LAUNCH_SCRIPT}" "$@"
