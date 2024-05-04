#!/bin/bash

# Load functions
source $BASE_DIR/functions.sh

function getClient() {
	CL=$(cat /etc/systemd/system/consensus.service | grep Description= | awk -F'=' '{print $2}' | awk '{print $1}')
}

function promptYesNo() {
	if whiptail --title "Resync Consensus - $CL" --yesno "This will only take a minute or two.\nAre you sure you want to resync $CL?" 9 78; then
		resyncClient
		promptViewLogs
	fi
}

function promptViewLogs() {
	if whiptail --title "Resync $CL complete" --yesno "Would you like to view logs and confirm everything is running properly?" 8 78; then
		sudo bash -c 'journalctl -fu consensus | ccze'
	fi
}

function getNetwork() {
	# Get network name from execution client
	result=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":67}' ${EL_RPC_ENDPOINT} | jq -r '.result')
	case $result in
	17000)
		NETWORK="Holesky"
		;;
	11155111)
		NETWORK="Sepolia"
		;;
	esac
}

function resyncClient() {
	case $CL in
	Lighthouse)
		sudo systemctl stop consensus
		sudo rm -rf /var/lib/lighthouse/beacon
		sudo systemctl restart consensus
		;;
	Lodestar)
		sudo systemctl stop consensus
		sudo rm -rf /var/lib/lodestar/chain-db
		sudo systemctl restart consensus
		;;
	Teku)
		sudo systemctl stop consensus
		sudo rm -rf /var/lib/teku/beacon
		sudo systemctl restart consensus
		;;
	Nimbus)
		getNetwork
		case $NETWORK in
		Holesky)
			URL="https://holesky.beaconstate.ethstaker.cc"
			;;
		Sepolia)
			URL="https://sepolia.beaconstate.info"
			;;
		esac

		sudo systemctl stop consensus
		sudo rm -rf /var/lib/nimbus/db

		sudo -u consensus /usr/local/bin/nimbus_beacon_node trustedNodeSync \
			--network=$(echo $NETWORK | tr '[:upper:]' '[:lower:]') \
			--trusted-node-url=$URL \
			--data-dir=/var/lib/nimbus \
			--backfill=false

		sudo systemctl restart consensus
		;;
	esac
}

function setWhiptailColors() {
	export NEWT_COLORS='root=,black
border=green,black
title=green,black
roottext=red,black
window=red,black
textbox=white,black
button=black,green
compactbutton=white,black
listbox=white,black
actlistbox=black,white
actsellistbox=black,green
checkbox=green,black
actcheckbox=black,green'
}

setWhiptailColors
getClient
promptYesNo
