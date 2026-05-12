
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

# Safety checks
delimiter="################################################################"
printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mCPU‑only Install Script for Stable Diffusion WebUI\e[0m\n"
printf "%s\n" "${delimiter}"

for preq in git "${python_cmd}"; do
  if ! hash "${preq}" &>/dev/null; then
    printf "\e[1m\e[31mERROR: %s is not installed, aborting...\e[0m\n" "${preq}"
    exit 1
  fi
done

if [[ $(id -u) -eq 0 ]]; then
  printf "\e[1m\e[31mERROR: Do not run as root, aborting...\e[0m\n"
  exit 1
fi

# Clone repo if missing
cd "${install_dir}" || exit 1
if [[ ! -d "${clone_dir}" ]]; then
  printf "\n%s\n" "${delimiter}"
  printf "Cloning Stable Diffusion WebUI repo...\n"
  printf "%s\n" "${delimiter}"
  git clone https://github.com/Akul-af/stable-diffusion-cpu.git "${clone_dir}"
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
    if [[ "${OSTYPE}" == "linux"* ]] && [[ -z "${NO_TCMALLOC}" ]] && [[ -z "${LD_PRELOAD}" ]]; then
        LIBC_VER=$(echo $(ldd --version | awk 'NR==1 {print $NF}') | grep -oP '\d+\.\d+')
        echo "glibc version is $LIBC_VER"
        TCMALLOC="$(PATH=/sbin:/usr/sbin:$PATH ldconfig -p | grep -E 'libtcmalloc(_minimal|)?\.so\.[0-9]+' | head -n 1)"
        TC_INFO=(${TCMALLOC//=>/})
        if [[ ! -z "${TC_INFO}" ]]; then
            echo "Found TCMalloc: ${TC_INFO}"
            export LD_PRELOAD="${TC_INFO[2]}"
        else
            echo "TCMalloc not found. Install google-perftools for better CPU memory usage."
        fi
    fi
}

# Launch WebUI with TCMalloc preload if available
printf "\n%s\n" "${delimiter}"
printf "Launching WebUI...\n"
printf "%s\n" "${delimiter}"
prepare_tcmalloc
python "${LAUNCH_SCRIPT}" "$@"
