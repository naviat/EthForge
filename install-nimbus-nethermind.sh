# Acknowledgments
# validator-install is branched from validator-install written by Accidental-green: https: //github.com/accidental-green/validator-install

#!/bin/bash
set -u

# enable  command completion
set -o history -o histexpand

python="python3"

abort() {
  printf "%s\n" "$1"
  exit 1
}

getc() {
  local save_state
  save_state=$(/bin/stty -g)
  /bin/stty raw -echo
  IFS= read -r -n 1 -d '' "$@"
  /bin/stty "$save_state"
}

exit_on_error() {
  exit_code=$1
  last_command=${@:2}
  if [ $exit_code -ne 0 ]; then
    echo >&2 "\"${last_command}\" command failed with exit code ${exit_code}."
    exit $exit_code
  fi
}

wait_for_user() {
  local c
  echo
  echo "Press RETURN to continue or any other key to abort"
  getc c
  # we test for \r and \n because some stuff does \r instead
  if ! [[ "$c" == $'\r' || "$c" == $'\n' ]]; then
    exit 1
  fi
}

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

# string formatters
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

linux_install_pre() {
  sudo apt-get update
  sudo apt-get install --no-install-recommends --no-install-suggests -y curl git ccze jq tmux bc
  exit_on_error $?
}

linux_install_python() {
  which $python
  if [[ $? != 0 ]]; then
    ohai "Installing python"
    sudo apt-get install --no-install-recommends --no-install-suggests -y $python
  else
    ohai "Updating python"
    sudo apt-get install --only-upgrade $python
  fi
  exit_on_error $?
  ohai "Installing python tools"
  sudo apt-get install --no-install-recommends --no-install-suggests -y $python-pip $python-tk $python-venv
  ohai "Creating venv"
  $python -m venv ~/.local --system-site-packages
  ohai "Installing pip requirements"
  ~/.local/bin/pip install requests console-menu python-dotenv
  exit_on_error $?
}

linux_update_pip() {
  PYTHONPATH=$(which $python)
  ohai "You are using python@ $PYTHONPATH$"
  ohai "Installing python tools"
  $python -m pip install --upgrade pip
}

linux_install_validator-install() {
  ohai "Cloning ethforge into ~/git/ethforge"
  mkdir -p ~/git/ethforge
  git clone https://github.com/naviat/ethforge.git ~/git/ethforge 2>/dev/null || (
    cd ~/git/ethforge
    git fetch origin master
    git checkout master
    git pull --ff-only
    git reset --hard
  )
  ohai "Installing validator-install"
  $python ~/git/ethforge/deploy-nimbus-nethermind.py
  ohai "Allowing user to view journalctl logs"
  sudo usermod -a -G systemd-journal $USER
  ohai "Install complete!"
  exit_on_error $?
}

# Do install.
OS="$(uname)"
if [[ "$OS" == "Linux" ]]; then
  echo """
██╗   ██╗ █████╗ ██╗     ██╗██████╗  █████╗ ████████╗ ██████╗ ██████╗ 
██║   ██║██╔══██╗██║     ██║██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
██║   ██║███████║██║     ██║██║  ██║███████║   ██║   ██║   ██║██████╔╝
╚██╗ ██╔╝██╔══██║██║     ██║██║  ██║██╔══██║   ██║   ██║   ██║██╔══██╗
 ╚████╔╝ ██║  ██║███████╗██║██████╔╝██║  ██║   ██║   ╚██████╔╝██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
                                                                      
██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗                     
██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║                     
██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║                     
██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║                     
██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗                
╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝                
                                                                      
    """
  ohai "This script will install a Nimbus-Nethermind Ethereum node:"
  echo "git jq curl ccze tmux bc"
  echo "python3-tk python3-pip python3-venv"
  echo "validator-install"

  wait_for_user
  linux_install_pre
  linux_install_python
  linux_update_pip
  linux_install_validator-install
  echo ""
  echo ""
  echo "######################################################################"
  echo "##                                                                  ##"
  echo "##      VALIDATOR INSTALL COMPLETE   To manage, use \"ethforge\"     ##"
  echo "##                                                                  ##"
  echo "######################################################################"
  echo ""
  echo ""
fi
