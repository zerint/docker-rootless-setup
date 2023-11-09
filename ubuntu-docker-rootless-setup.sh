#!/bin/bash
if [ -z "$1" ]
then
	echo "Usage: $0 <user>"
	exit 0
fi

USER="$1"

if ! id "$USER" >/dev/null 2>&1; then
	useradd -s /bin/bash -m "$USER"
	echo "Created user $USER"
fi


#
# Update before running
#
echo "Updateing package lists before installing requirements"
apt -qq update


#
# Install required packages
#
echo "Installing requirements"
PACKAGES_NEEDED=("slirp4netns" "uidmap" "dbus-user-session" "ca-certificates" "curl" "gnupg" "systemd-container")
for REQUIRED_PKG in ${PACKAGES_NEEDED[@]}
do
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	if [ "" = "$PKG_OK" ]; then
	        apt install -qq --yes $REQUIRED_PKG
	        echo "Installed $REQUIRED_PKG"
	fi
done


#
# Setup docker gpg key
#
echo "Setting up docker gpg key"
DOCKER_GPG="/etc/apt/keyrings/docker.gpg"
if ! [ -f "$DOCKER_GPG" ]
then
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "${DOCKER_GPG}"
	sudo chmod a+r /etc/apt/keyrings/docker.gpg
	echo "Set up $DOCKER_GPG"
fi


#
# Setup docker sources list
#
echo "Setting up docker sources list"
DOCKER_SOURCES_LIST="/etc/apt/sources.list.d/docker.list"
if ! [ -f "$DOCKER_SOURCES_LIST" ]
then
	echo \
	  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	apt update -qq -o Dir::Etc::sourcelist="${DOCKER_SOURCES_LIST}"
fi


#
# Installing docker packages
#
echo "Installing docker packages"
DOCKER_PACKAGES=("docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin")

for REQUIRED_PKG in ${DOCKER_PACKAGES[@]}
do
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	if [ "" = "$PKG_OK" ]; then
	        apt install -qq --yes $REQUIRED_PKG
	        echo "Installed $REQUIRED_PKG"
	fi
done


#
# Setting up user and it's own docker
#
echo "Setting up user's own docker"
machinectl shell "${USER}@" /usr/bin/dockerd-rootless-setuptool.sh install
echo "Installed rootless docker"
loginctl enable-linger "${USER}"
echo "Enabled docker rootless of $USER to start after reboot"

echo "Done."
