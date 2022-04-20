# Docker-Rootless Full Setup
A tutorial for setting up rootless docker. Extention of https://docs.docker.com/engine/security/rootless/.

## Install

### Install packages
```
apt update
apt install uidmap
```

### Install docker rootless with it's own script
As user(will be referred to as [user]), move into the home directory
```
su [user]
cd
```

Install the rootless shell script in the [user]'s home directory.
```
curl -fsSL https://get.docker.com/rootless | sh
```
Insert the 3 ENV variables into the .bashrc file of the [user]
(Listen to the install scripts output, ignore the systemd parts.)

### Create systemd unit
As root, create a systemd unit based on the [user]-docker.service file in this repo.
Then refresh the unit list, and start the service.
```
systemctl daemon-reload
systemctl start [user]-docker.service
systemctl status [user]-docker.service
```

## Testing
Test with the following command if [user] can have root permissions using docker:
```
docker run -it -v /root:/root ubuntu touch /root/file_created_by_docker
```

## Usage
As [user]:
```
docker ps
```
As root:
```
DOCKER_HOST=unix:///home/<user>/.docker/run/docker.sock docker ps
```

## Additional information
If you wish to specify a ***/etc/docker/daemon.json*** you can do it here: ***/home/[user]/.config/docker/daemon.json***
