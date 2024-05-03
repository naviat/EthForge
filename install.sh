#!/bin/bash
set -u

# enable  command completion
set -o history -o histexpand

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
  sudo apt-get install --no-install-recommends --no-install-suggests -y curl git ccze bc tmux jq
  exit_on_error $?
}

linux_install_installer() {
  ohai "Cloning ethforge into ~/git/ethforge"
  mkdir -p ~/git/ethforge
  git clone https://github.com/naviat/ethforge.git ~/git/ethforge/ 2>/dev/null || (
    cd ~/git/ethforge
    git fetch origin main
    git checkout main
    git pull --ff-only
    git reset --hard
  )
  chmod +x ~/git/ethforge/*.sh
  ohai "Installing ethforge"
  if [ -f /usr/local/bin/ethforge ]; then
    sudo rm /usr/local/bin/ethforge
  fi
  sudo ln -s ~/git/ethforge/ethforge.sh /usr/local/bin/ethforge
  exit_on_error $?
}

# Do install.
OS="$(uname)"
if [[ "$OS" == "Linux" ]]; then
  echo """
 _______  _________  ___  ___  ________ ________  ________  ________  _______      
|\  ___ \|\___   ___\\  \|\  \|\  _____\\   __  \|\   __  \|\   ____\|\  ___ \     
\ \   __/\|___ \  \_\ \  \\\  \ \  \__/\ \  \|\  \ \  \|\  \ \  \___|\ \   __/|    
 \ \  \_|/__  \ \  \ \ \   __  \ \   __\\ \  \\\  \ \   _  _\ \  \  __\ \  \_|/__  
  \ \  \_|\ \  \ \  \ \ \  \ \  \ \  \_| \ \  \\\  \ \  \\  \\ \  \|\  \ \  \_|\ \ 
   \ \_______\  \ \__\ \ \__\ \__\ \__\   \ \_______\ \__\\ _\\ \_______\ \_______\
    \|_______|   \|__|  \|__|\|__|\|__|    \|_______|\|__|\|__|\|_______|\|_______|
                                                                                   
                                                                                   
    """
  ohai "This script will install a node management tool called 'ethforge'"

  wait_for_user
  linux_install_pre
  linux_install_installer

  echo ""
  echo ""
  echo "######################################################################"
  echo "##                                                                  ##"
  echo "##           INSTALL COMPLETE - To run, type \"ethforge\"            ##"
  echo "##                                                                  ##"
  echo "######################################################################"
  echo ""
  echo ""
fi
