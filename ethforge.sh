#!/bin/bash

VERSION="1.4.8"
BASE_DIR=$HOME/git/ethforge

# Load functions
source $BASE_DIR/functions.sh && cd $BASE_DIR

menuMain() {

  # Define the options for the main menu
  OPTIONS=(
    1 "View Logs (Exit: CTRL+B D)"
    - ""
    3 "Execution Client"
    4 "Consensus Client"
  )
  test -f /etc/systemd/system/validator.service && OPTIONS+=(5 "Validator Client")
  test -f /etc/systemd/system/mevboost.service && OPTIONS+=(6 "MEV-Boost")
  OPTIONS+=(
    - ""
    7 "Start all clients"
    8 "Stop all clients"
    9 "Restart all clients"
    - ""
    10 "System Administration"
    11 "Tools"
    99 "Quit"
  )

  while true; do
    getBackTitle
    # Display the main menu and get the user's choice
    CHOICE=$(whiptail --clear --cancel-button "Quit" \
      --backtitle "$BACKTITLE" \
      --title "ethforge - Node Menu $VERSION" \
      --menu "Choose a category:" \
      0 42 0 \
      "${OPTIONS[@]}" \
      3>&1 1>&2 2>&3)
    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice
    case $CHOICE in
    1)
      runScript view_logs.sh
      ;;
    3)
      submenuExecution
      ;;
    4)
      submenuConsensus
      ;;
    5)
      submenuValidator
      ;;
    6)
      submenuMEV-Boost
      ;;
    7)
      sudo service execution start
      sudo service consensus start
      test -f /etc/systemd/system/validator.service && sudo service validator start
      test -f /etc/systemd/system/mevboost.service && sudo service mevboost start
      ;;
    8)
      sudo service execution stop
      sudo service consensus stop
      test -f /etc/systemd/system/validator.service && sudo service validator stop
      test -f /etc/systemd/system/mevboost.service && sudo service mevboost stop
      ;;
    9)
      sudo service execution restart
      sudo service consensus restart
      test -f /etc/systemd/system/validator.service && sudo service validator restart
      test -f /etc/systemd/system/mevboost.service && sudo service mevboost restart
      ;;
    10)
      submenuAdminstrative
      ;;
    11)
      submenuTools
      ;;
    99)
      break
      ;;
    esac
  done
}

submenuExecution() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "View logs"
      2 "Start execution"
      3 "Stop execution"
      4 "Restart execution"
      5 "Edit configuration"
      6 "Update to latest release"
      7 "Resync execution client"
      - ""
      8 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "Execution Client" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      sudo bash -c 'journalctl -fu execution | ccze'
      ;;
    2)
      sudo service execution start
      ;;
    3)
      sudo service execution stop
      ;;
    4)
      sudo service execution restart
      ;;
    5)
      sudo nano /etc/systemd/system/execution.service
      if whiptail --title "Reload daemon and restart services" --yesno "Do you want to restart execution client?" 8 78; then
        sudo systemctl daemon-reload && sudo service execution restart
      fi
      ;;
    6)
      runScript update_execution.sh
      ;;
    7)
      runScript resync_execution.sh
      ;;
    8)
      break
      ;;
    esac
  done
}

submenuConsensus() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "View logs"
      2 "Start consensus"
      3 "Stop consensus"
      4 "Restart consensus"
      5 "Edit configuration"
      6 "Update to latest release"
      7 "Resync consensus client"
      - ""
      8 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "Consensus Client" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      sudo bash -c 'journalctl -fu consensus | ccze'
      ;;
    2)
      sudo service consensus start
      ;;
    3)
      sudo service consensus stop
      ;;
    4)
      sudo service consensus restart
      ;;
    5)
      sudo nano /etc/systemd/system/consensus.service
      if whiptail --title "Reload daemon and restart services" --yesno "Do you want to restart consensus client?" 8 78; then
        sudo systemctl daemon-reload && sudo service consensus restart
      fi
      ;;
    6)
      runScript update_consensus.sh
      ;;
    7)
      runScript resync_consensus.sh
      ;;
    8)
      break
      ;;
    esac
  done
}

submenuValidator() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "View logs"
      2 "Start validator"
      3 "Stop validator"
      4 "Restart validator"
      5 "Edit configuration"
      - ""
      6 "Generate / Import Validator Keys"
      7 "View validator pubkeys and indices"
      - ""
      8 "Generate Voluntary Exit Messages (VEM) with ethdo"
      9 "Broadcast Voluntary Exit Messages (VEM) with ethdo"
      10 "Check Validator Status by Index with ethdo"
      - ""
      11 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "Validator" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      sudo bash -c 'journalctl -fu validator | ccze'
      ;;
    2)
      sudo service validator start
      ;;
    3)
      sudo service validator stop
      ;;
    4)
      sudo service validator restart
      ;;
    5)
      sudo nano /etc/systemd/system/validator.service
      if whiptail --title "Reload daemon and restart services" --yesno "Do you want to restart validator?" 8 78; then
        sudo systemctl daemon-reload && sudo service validator restart
      fi
      ;;
    6)
      runScript manage_validator_keys.sh
      ;;
    7)
      getPubKeys && getIndices
      viewPubkeyAndIndices
      ;;
    8)
      installEthdo
      generateVoluntaryExitMessage
      ;;
    9)
      installEthdo
      broadcastVoluntaryExitMessageLocally
      ;;
    10)
      installEthdo
      checkValidatorStatus
      ;;
    11)
      break
      ;;
    esac
  done
}

submenuMEV-Boost() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "View logs"
      2 "Start MEV-Boost"
      3 "Stop MEV-Boost"
      4 "Restart MEV-Boost"
      5 "Edit configuration"
      6 "Update to latest release"
      7 "Check relay registration"
      - ""
      8 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "MEV-Boost" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      sudo bash -c 'journalctl -fu mevboost | ccze'
      ;;
    2)
      sudo service mevboost start
      ;;
    3)
      sudo service mevboost stop
      ;;
    4)
      sudo service mevboost restart
      ;;
    5)
      sudo nano /etc/systemd/system/mevboost.service
      if whiptail --title "Reload daemon and restart services" --yesno "Do you want to restart MEV-Boost" 8 78; then
        sudo systemctl daemon-reload && sudo service mevboost restart
      fi
      ;;
    6)
      runScript update_mevboost.sh
      ;;
    7)
      checkRelayRegistration
      ;;
    8)
      break
      ;;
    esac
  done
}

submenuAdminstrative() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "Update system"
      2 "Restart system"
      3 "Shutdown system"
      - ""
      4 "View software versions"
      5 "View cpu/ram/disk/net (btop)"
      6 "View general node information"
      - ""
      10 "Update ethforge"
      11 "About ethforge"
      - ""
      20 "Configure autostart"
      21 "Uninstall node"
      - ""
      99 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "System Administration" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
      ;;
    2)
      if whiptail --title "Reboot" --defaultno --yesno "Are you sure you want to reboot?" 8 78; then sudo reboot now; fi
      ;;
    3)
      if whiptail --title "Shutdown" --defaultno --yesno "Are you sure you want to shutdown?" 8 78; then sudo shutdown now; fi
      ;;
    4)
      CL=$(curl -s -X GET "${API_BN_ENDPOINT}/eth/v1/node/version" -H "accept: application/json" | jq -r '.data.version')
      EL=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":2}' ${EL_RPC_ENDPOINT} | jq -r '.result')
      MB=$(if systemctl is-active --quiet mevboost; then printf "$(mev-boost --version | sed 's/.*\s\([0-9]*\.[0-9]*\).*/\1/')"; elif [ -f /etc/systemd/system/mevboost.service ]; then printf "Offline"; else printf "Not Installed"; fi)
      if [[ ! $CL ]]; then
        CL="Not running or still starting up."
      fi
      if [[ ! $EL ]]; then
        EL="Not running or still starting up."
      fi
      whiptail --title "Installed versions" --msgbox "Consensus client: $CL\nExecution client: $EL\nMev-boost: $MB" 10 78
      ;;
    5)
      # Install btop process monitoring
      if ! command -v btop &>/dev/null; then
        sudo apt-get install btop -y
      fi
      btop
      ;;
    6)
      print_node_info
      ;;
    10)
      cd $BASE_DIR
      git fetch origin main
      git checkout main
      git pull --ff-only
      git reset --hard
      git clean -xdf
      whiptail --title "Updated ethforge" --msgbox "Restart ethforge for latest version." 10 78
      ;;
    11)
      MSG_ABOUT="🔧 Developed as an open-source project by Naviat for Ethereum staking since its inception.
                  \n🛠️ We welcome improvements and suggestions on GitHub: https://github.com/naviat/EthForge" 20 78
      ;;
    20)
      configureAutoStart
      ;;
    21)
      runScript uninstall.sh
      ;;
    99)
      break
      ;;
    esac
  done
}

submenuMonitoring() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "View Logs"
      2 "Start Monitoring"
      3 "Stop Monitoring"
      4 "Restart Monitoring"
      5 "Edit configuration"
      6 "Edit Prometheus.yml configuration"
      7 "Update to latest release"
      8 "Uninstall monitoring"
      - ""
      9 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "Monitoring - Ethereum Metrics Exporter" \
      --menu "\nAccess Grafana at: http://127.0.0.1:3000 or http://$ip_current:3000\n\nChoose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      sudo bash -c 'journalctl -fu grafana-server -fu prometheus -fu ethereum-metrics-exporter -fu prometheus-node-exporter -n 100 | ccze'
      ;;
    2)
      sudo systemctl start grafana-server prometheus ethereum-metrics-exporter prometheus-node-exporter
      ;;
    3)
      sudo systemctl stop grafana-server prometheus ethereum-metrics-exporter prometheus-node-exporter
      ;;
    4)
      sudo systemctl restart grafana-server prometheus ethereum-metrics-exporter prometheus-node-exporter
      ;;
    5)
      sudo nano /etc/systemd/system/ethereum-metrics-exporter.service
      if whiptail --title "Reload daemon and restart services" --yesno "Do you want to restart ethereum metrics exporter?" 8 78; then
        sudo systemctl daemon-reload && sudo service ethereum-metrics-exporter restart
      fi
      ;;
    6)
      sudo nano /etc/prometheus/prometheus.yml
      if whiptail --title "Restart services" --yesno "Do you want to restart prometheus?" 8 78; then
        sudo service prometheus restart
      fi
      ;;
    7)
      runScript ethereum-metrics-exporter.sh -u
      ;;
    8)
      runScript ethereum-metrics-exporter.sh -r
      ;;
    9)
      break
      ;;
    esac
  done
}

submenuEthduties() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "View duties"
      2 "Wait for 90.0% of attestation duties to be executed in 90 sec. or later"
      3 "Update to latest release"
      4 "Uninstall eth-duties"
      - ""
      9 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "eth-duties" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      getNetwork && getPubKeys && getIndices
      /usr/local/bin/eth-duties --validators ${INDICES[@]} --beacon-nodes $API_BN_ENDPOINT
      ;;
    2)
      getNetwork && getPubKeys && getIndices
      /usr/local/bin/eth-duties --validators ${INDICES[@]} --beacon-nodes $API_BN_ENDPOINT --max-attestation-duty-logs 60 --mode cicd-wait --mode-cicd-attestation-time 90 --mode-cicd-attestation-proportion 0.90
      ohai "Ready! Press ENTER to continue."
      read
      ;;
    3)
      runScript eth-duties.sh -u
      ;;
    4)
      runScript eth-duties.sh -r
      ;;
    9)
      break
      ;;
    esac
  done
}

submenuEthdo() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "Check Validator Status by Index"
      2 "Generate Voluntary Exit Messages (VEM)"
      3 "Broadcast Voluntary Exit Messages (VEM)"
      4 "Update to latest release"
      5 "Uninstall ethdo"
      - ""
      9 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "ethdo" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      checkValidatorStatus
      ;;
    2)
      generateVoluntaryExitMessage
      ;;
    3)
      broadcastVoluntaryExitMessageLocally
      ;;
    4)
      runScript ethdo.sh -u
      ;;
    5)
      runScript ethdo.sh -r
      ;;
    9)
      break
      ;;
    esac
  done
}

submenuUFW() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "View ufw status"
      2 "Allow incoming traffic on a port"
      3 "Deny incoming traffic on a port"
      4 "Delete a rule"
      - ""
      5 "Enable firewall with default settings"
      6 "RPC Node: Allow local network access to RPC port 8545"
      7 "Monitoring: Allow local network access to Grafana port 3000"
      8 "Disable firewall"
      9 "Reset firewall rules"
      - ""
      10 "Whitelist an IP address: Allow full access to this node"
      - ""
      99 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "UFW Firewall" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      sudo ufw status numbered
      ohai "Press ENTER to continue."
      read
      ;;
    2)
      read -p "Enter the port number to allow: " port_number
      sudo ufw allow $port_number
      ohai "Port allowed."
      sleep 2
      ;;
    3)
      read -p "Enter the port number to deny: " port_number
      sudo ufw deny $port_number
      ohai "Port denied."
      sleep 2
      ;;
    4)
      sudo ufw status numbered
      read -p "Enter the rule number to delete: " rule_number
      sudo ufw delete $rule_number
      ohai "Rule deleted."
      sleep 2
      ;;
    5)
      # Default ufw settings
      sudo ufw default deny incoming
      sudo ufw default allow outgoing
      echo "${tty_bold}Allow SSH access? [y|n]${tty_reset}"
      read -rsn1 yn
      if [[ ${yn} = [Yy]* ]]; then
        read -r -p "Enter your SSH port. Press Enter to use default '22': " _ssh_port
        _ssh_port=${_ssh_port:-22}
        sudo ufw allow ${_ssh_port}/tcp comment 'Allow SSH port'
      fi
      sudo ufw allow 30303 comment 'Allow execution client port'
      sudo ufw allow 9000 comment 'Allow consensus client port'
      sudo ufw enable
      sudo ufw status numbered
      ohai "UFW firewall enabled."
      sleep 3
      ;;
    6)
      sudo ufw allow from ${network_current} to any port 8545 comment 'Allow local network to access RPC'
      ohai "Local network ${network_current} can access RPC port 8545"
      sleep 2
      ;;
    7)
      sudo ufw allow from ${network_current} to any port 3000 comment 'Allow local network to access Grafana'
      ohai "Local network ${network_current} can access RPC port 3000"
      sleep 2
      ;;
    8)
      sudo ufw disable
      ohai "UFW firewall disabled."
      sleep 2
      ;;
    9)
      sudo ufw disable
      sudo ufw --force reset
      ohai "UFW firewall reset."
      sleep 2
      ;;
    10)
      read -p "Enter the IP address to whitelist: " ip_whitelist
      sudo ufw allow from $ip_whitelist
      ohai "IP address whitelisted."
      sleep 2
      ;;
    99)
      break
      ;;
    esac
  done
}

submenuTools() {
  while true; do
    getBackTitle
    # Define the options for the submenu
    SUBOPTIONS=(
      1 "eth-duties: Show upcoming block proposals, attestations, sync duties"
      2 "Monitoring: Observe Ethereum Metrics. Explore Dashboards."
      3 "NCDU: Find large files. Analyze disk usage."
      4 "Port Checker: Test for Incoming Connections"
      5 "ethdo: Conduct Common Validator Tasks"
      6 "Peer Count: Show # peers connected to EL & CL"
      7 "Beaconcha.in Validator Dashboard: Create a link for my validators"
      - ""
      9 "EL: Switch Execution Clients"
      - ""
      10 "Timezone: Update machine's timezone"
      11 "Locales: Fix terminal formatting issues"
      12 "Privacy: Clear bash shell history"
      13 "Swapfile: Use disk space as extra RAM"
      14 "UFW Firewall: Control network traffic against unauthorized access"
      15 "Speedtest: Test internet bandwidth using speedtest.net"
      - ""
      99 "Back to main menu"
    )

    # Display the submenu and get the user's choice
    SUBCHOICE=$(whiptail --clear --cancel-button "Back" \
      --backtitle "$BACKTITLE" \
      --title "Tools" \
      --menu "Choose one of the following options:" \
      0 0 0 \
      "${SUBOPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    if [ $? -gt 0 ]; then # user pressed <Cancel> button
      break
    fi

    # Handle the user's choice from the submenu
    case $SUBCHOICE in
    1)
      # Skip if no validators installed
      if [[ ! -f /etc/systemd/system/validator.service ]]; then
        echo "No validator(s) installed. Press ENTER to continue."
        read
        break
      fi

      # Install eth-duties if not yet installed
      if [[ ! -f /usr/local/bin/eth-duties ]]; then
        if whiptail --title "Install eth-duties" --yesno "Do you want to install eth-duties?\n\neth-duties shows upcoming validator duties." 8 78; then
          runScript eth-duties.sh -i
        fi
      fi
      submenuEthduties
      ;;
    2)
      # Install monitoring if not yet installed
      if [[ ! -f /etc/systemd/system/ethereum-metrics-exporter.service ]]; then
        if whiptail --title "Install Monitoring" --yesno "Do you want to install Monitoring?\nIncludes: Ethereum Metrics Exporter, grafana, prometheus" 8 78; then
          runScript ethereum-metrics-exporter.sh -i
        fi
      fi
      submenuMonitoring
      ;;
    3)
      findLargestDiskUsage
      ;;
    4)
      checkOpenPorts
      ;;
    5)
      installEthdo
      submenuEthdo
      ;;
    6)
      getPeerCount
      ;;
    7)
      createBeaconChainDashboardLink
      ;;
    9)
      sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/naviat/el-switcher/master/install.sh)"
      ;;
    10)
      sudo dpkg-reconfigure tzdata
      ohai "Timezone updated. Press ENTER to continue."
      read
      ;;
    11)
      sudo update-locale "LANG=en_US.UTF-8"
      sudo locale-gen --purge "en_US.UTF-8"
      sudo dpkg-reconfigure --frontend noninteractive locales
      ohai "Updated locale to en_US.UTF-8"
      ohai "Logout and login for terminal locale updates to take effect. Press ENTER to continue."
      read
      ;;
    12)
      history -c && history -w
      ohai "Cleared bash history"
      read
      ;;
    13)
      addSwapfile
      ;;
    14)
      submenuUFW
      ;;
    15)
      testBandwidth
      ;;
    99)
      break
      ;;
    esac
  done
}

function getBackTitle() {
  getNetwork
  getClient
  # Latest block
  latest_block_number=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' ${EL_RPC_ENDPOINT} | jq -r '.result')
  LB=$(printf '%d' "$latest_block_number")
  if [[ ! $LB ]]; then
    LB="N/A"
  fi

  # Latest slot
  LS=$(curl -s -X GET "${API_BN_ENDPOINT}/eth/v1/node/syncing" -H "accept: application/json" | jq -r '.data.head_slot')
  if [[ ! $LS ]]; then
    LS="N/A"
  fi

  # Format gas price
  latest_gas_price=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":73}' ${EL_RPC_ENDPOINT} | jq -r '.result')
  if [[ $latest_gas_price ]]; then
    WEI=$(printf '%d' "$latest_gas_price")
    GP=$(echo "scale=3; $WEI / 1000000000" | bc) #convert to Gwei
  else
    GP="N/A"
  fi

  # Format backtitle
  EL_TEXT=$(if systemctl is-active --quiet execution; then printf "Block $LB | Gas $GP Gwei"; else printf "Offline EL"; fi)
  CL_TEXT=$(if systemctl is-active --quiet consensus; then printf "Slot $LS"; else printf "Offline CL"; fi)
  VC_TEXT=$(if systemctl is-active --quiet validator && systemctl is-enabled --quiet validator; then printf " | VC $VC"; fi)
  NETWORK_TEXT=$(if systemctl is-active --quiet execution; then printf "$NETWORK |"; fi)
  BACKTITLE="$NETWORK_TEXT $EL_TEXT | $CL_TEXT | $CL-$EL$VC_TEXT | Toolset for ETH"
}

function checkV1StakingSetup() {
  if [[ -f /etc/systemd/system/eth1.service ]]; then
    echo "Ethforge is only compatible with V2 Staking Setups. Using ethforge, build a new node in minutes after wiping system or uninstalling V1."
    exit
  fi
}

# If no consensus client service is installed, ask to install
function askInstallNode() {
  if [[ ! -f /etc/systemd/system/consensus.service ]]; then
    if whiptail --title "Install Node" --yesno "Would you like to install an Ethereum node (Nimbus CL & Nethermind EL)?" 8 78; then
      runScript install-nimbus-nethermind.sh
    fi
  fi
}

checkV1StakingSetup
setWhiptailColors
askInstallNode
menuMain
