#!/usr/bin/env bash
#################################################
# CPU‑only install script for Stable Diffusion   #
# Optimized for macOS environments + TCMalloc    #
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
printf "\e[1m\e[32mCPU‑only Install Script for Stable Diffusion WebUI (macOS)\e[0m\n"
printf "%s\n" "${delimiter}"

# Check prerequisites
for preq in git "${python_cmd}"; do
  if ! hash "${preq}" &>/dev/null; then
    printf "\e[1m\e[31mERROR: %s is not installed, aborting...\e[0m\n" "${preq}"
    exit 1
  fi
done

# Clone repo if missing
cd "${install_dir}" || exit 1
if [[ ! -d "${clone_dir}" ]]; then
  printf "\n%s\n" "${delimiter}"
  printf "Cloning Stable Diffusion WebUI repo...\n"
  printf "%s\n" "${delimiter}"
  git clone https://github.com/Akul-af/stable-diffusion-cpu.git"${clone_dir}"
fi
cd "${clone_dir}" || exit 1

# Create venv if missing
if [[ ! -d "${venv_dir}" ]]; then
  printf "\n%s\n" "${delimiter}"
  printf "Creating Python venv...\n"
  printf "%s\n" "${delimiter}"
  "${python_cmd}" -m venv "${venv_dir}"
  "${venv_dir}"/bin/python -m pip install --upgrade pip
fi

# Activate venv
source "${venv_dir}"/bin/activate || { echo "Cannot activate venv"; exit 1; }

# Install CPU‑only PyTorch wheels
printf "\n%s\n" "${delimiter}"
printf "Installing CPU‑only PyTorch...\n"
printf "%s\n" "${delimiter}"
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu

# Install other requirements
printf "\n%s\n" "${delimiter}"
printf "Installing project requirements...\n"
printf "%s\n" "${delimiter}"
pip install -r requirements-cpu.txt

# Prepare TCMalloc (optional performance boost)
prepare_tcmalloc() {
    if [[ "$(uname)" == "Darwin" ]] && [[ -z "${NO_TCMALLOC}" ]] && [[ -z "${DYLD_INSERT_LIBRARIES}" ]]; then
        TCMALLOC=$(find /usr/local/lib /opt/homebrew/lib -name "libtcmalloc*.dylib" 2>/dev/null | head -n 1)
        if [[ -n "${TCMALLOC}" ]]; then
            echo "Found TCMalloc: ${TCMALLOC}"
            export DYLD_INSERT_LIBRARIES="${TCMALLOC}"
        else
            echo "TCMalloc not found. Install google-perftools via Homebrew for better CPU memory usage:"
            echo "  brew install google-perftools"
        fi
    fi
}

# Launch WebUI with TCMalloc preload if available
printf "\n%s\n" "${delimiter}"
printf "Launching WebUI...\n"
printf "%s\n" "${delimiter}"
prepare_tcmalloc
python "${LAUNCH_SCRIPT}" "$@"

