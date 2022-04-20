# Docker-Rootless Full Setup
A tutorial for setting up rootless docker. Extention of https://docs.docker.com/engine/security/rootless/.

## Install

### Install packages
```
apt install -y uidmap
```

### Install docker rootless with it's own script
Log in as the user(will be referred to as [user]) and move into it's home directory
```
su [user]
cd
```

Install the rootless shell script in the [user]'s home directory.
```
curl -fsSL https://get.docker.com/rootless | sh
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
