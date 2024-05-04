#!/bin/bash

BASE_DIR=$HOME/git/ethforge

# Load functions
source $BASE_DIR/functions.sh

function getCurrentVersion() {
	INSTALLED=$(mev-boost --version)
	#Find version in format #.#.#
	if [[ $INSTALLED ]]; then
		VERSION=$(echo $INSTALLED | sed 's/.*\s\([0-9]*\.[0-9]*\).*/\1/')
	else
		VERSION="Client not installed."
	fi
}

function promptYesNo() {
	if whiptail --title "Update mevboost" --yesno "Installed Version is: $VERSION\nLatest Version is:    $TAG\n\nReminder: Always read the release notes for breaking changes: $CHANGES_URL\n\nDo you want to update to $TAG?" 15 78; then
		updateClient
		promptViewLogs
	fi
}

function promptViewLogs() {
	if whiptail --title "Update complete" --yesno "Would you like to view logs and confirm everything is running properly?" 8 78; then
		sudo bash -c 'journalctl -fu mevboost | ccze'
	fi
}

function getLatestVersion() {
	TAG_URL="https://api.github.com/repos/flashbots/mev-boost/releases/latest"
	#Get tag name and remove leading 'v'
	TAG=$(curl -s $TAG_URL | jq -r .tag_name | sed 's/.*v\([0-9]*\.[0-9]*\).*/\1/')
	CHANGES_URL="https://github.com/flashbots/mev-boost/releases"
}

function updateClient() {
	RELEASE_URL="https://api.github.com/repos/flashbots/mev-boost/releases/latest"
	BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux_amd64.tar.gz$)"

	echo Downloading URL: $BINARIES_URL

	cd $HOME
	# Download
	wget -O mev-boost.tar.gz $BINARIES_URL
	# Untar
	tar -xzvf mev-boost.tar.gz -C $HOME
	# Cleanup
	rm mev-boost.tar.gz LICENSE README.md
	sudo systemctl stop mevboost
	sudo mv $HOME/mev-boost /usr/local/bin
	sudo systemctl start mevboost
}

setWhiptailColors
getCurrentVersion
getLatestVersion
promptYesNo
