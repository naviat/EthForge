#!/bin/bash

BASE_DIR=$HOME/git/ethforge

# Load functions
source $BASE_DIR/functions.sh

function getCurrentVersion() {
	CL_INSTALLED=$(curl -s -X GET "${API_BN_ENDPOINT}/eth/v1/node/version" -H "accept: application/json" | jq '.data.version')
	#Find version in format #.#.#
	if [[ $CL_INSTALLED ]]; then
		VERSION=$(echo $CL_INSTALLED | sed 's/.*v\([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')
	else
		VERSION="Client not running or still starting up. Unable to query version."
	fi
}

function getClient() {
	CL=$(cat /etc/systemd/system/consensus.service | grep Description= | awk -F'=' '{print $2}' | awk '{print $1}')
}

function promptYesNo() {
	if whiptail --title "Update Consensus Client - $CL" --yesno "Installed Version is: $VERSION\nLatest Version is:    $TAG\n\nReminder: Always read the release notes for breaking changes: $CHANGES_URL\n\nDo you want to update $CL to $TAG?" 15 78; then
		updateClient
		promptViewLogs
	fi
}

function promptViewLogs() {
	if whiptail --title "Update complete - $CL" --yesno "Would you like to view logs and confirm everything is running properly?" 8 78; then
		sudo bash -c 'journalctl -fu consensus | ccze'
	fi
}

function getLatestVersion() {
	case $CL in
	Lighthouse)
		TAG_URL="https://api.github.com/repos/sigp/lighthouse/releases/latest"
		CHANGES_URL="https://github.com/sigp/lighthouse/releases"
		;;
	Lodestar)
		TAG_URL="https://api.github.com/repos/ChainSafe/lodestar/releases/latest"
		CHANGES_URL="https://github.com/ChainSafe/lodestar/releases"
		;;
	Teku)
		TAG_URL="https://api.github.com/repos/ConsenSys/teku/releases/latest"
		CHANGES_URL="https://github.com/ConsenSys/teku/releases"
		;;
	Nimbus)
		TAG_URL="https://api.github.com/repos/status-im/nimbus-eth2/releases/latest"
		CHANGES_URL="https://github.com/status-im/nimbus-eth2/releases"
		;;
	esac
	#Get tag name and remove leading 'v'
	TAG=$(curl -s $TAG_URL | jq -r .tag_name | sed 's/.*v\([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')
}

function updateClient() {
	case $CL in
	Lighthouse)
		RELEASE_URL="https://api.github.com/repos/sigp/lighthouse/releases/latest"
		BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep x86_64-unknown-linux-gnu.tar.gz$)"
		echo Downloading URL: $BINARIES_URL
		cd $HOME
		wget -O lighthouse.tar.gz $BINARIES_URL
		tar -xzvf lighthouse.tar.gz -C $HOME
		rm lighthouse.tar.gz
		sudo systemctl stop consensus
		test -f /etc/systemd/system/validator.service && sudo service validator stop
		sudo rm /usr/local/bin/lighthouse
		sudo mv $HOME/lighthouse /usr/local/bin/lighthouse
		sudo systemctl start consensus
		test -f /etc/systemd/system/validator.service && sudo service validator start
		;;
	Lodestar)
		cd ~/git/lodestar
		git checkout stable && git pull
		yarn clean:nm && yarn install
		yarn run build
		sudo systemctl stop consensus
		test -f /etc/systemd/system/validator.service && sudo service validator stop
		sudo rm -rf /usr/local/bin/lodestar
		sudo cp -a $HOME/git/lodestar /usr/local/bin/lodestar
		sudo systemctl start consensus
		test -f /etc/systemd/system/validator.service && sudo service validator start
		;;
	Teku)
		RELEASE_URL="https://api.github.com/repos/ConsenSys/teku/releases/latest"
		LATEST_TAG="$(curl -s $RELEASE_URL | jq -r ".tag_name")"
		BINARIES_URL="https://artifacts.consensys.net/public/teku/raw/names/teku.tar.gz/versions/${LATEST_TAG}/teku-${LATEST_TAG}.tar.gz"
		echo Downloading URL: $BINARIES_URL
		cd $HOME
		wget -O teku.tar.gz $BINARIES_URL
		tar -xzvf teku.tar.gz -C $HOME
		mv teku-* teku
		rm teku.tar.gz
		sudo systemctl stop consensus
		test -f /etc/systemd/system/validator.service && sudo service validator stop
		sudo rm -rf /usr/local/bin/teku
		sudo mv $HOME/teku /usr/local/bin/teku
		sudo systemctl start consensus
		test -f /etc/systemd/system/validator.service && sudo service validator start
		;;
	Nimbus)
		RELEASE_URL="https://api.github.com/repos/status-im/nimbus-eth2/releases/latest"
		BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep _Linux_amd64.*.tar.gz$)"
		echo Downloading URL: $BINARIES_URL
		cd $HOME
		wget -O nimbus.tar.gz $BINARIES_URL
		tar -xzvf nimbus.tar.gz -C $HOME
		mv nimbus-eth2_Linux_amd64_* nimbus
		sudo systemctl stop consensus
		test -f /etc/systemd/system/validator.service && sudo service validator stop
		sudo rm /usr/local/bin/nimbus_beacon_node
		sudo rm /usr/local/bin/nimbus_validator_client
		sudo mv nimbus/build/nimbus_beacon_node /usr/local/bin
		sudo mv nimbus/build/nimbus_validator_client /usr/local/bin
		sudo systemctl start consensus
		test -f /etc/systemd/system/validator.service && sudo service validator start
		rm -r nimbus
		rm nimbus.tar.gz
		;;
	esac
}

setWhiptailColors
getClient
getCurrentVersion
getLatestVersion
promptYesNo
