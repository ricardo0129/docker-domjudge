#!/bin/bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

set -e

DEFAULT_VERSION=8.2.3
VERSION=$1
if [ -z ${VERSION} ]
then
  echo "Falling back to default version $DEFAULT_VERSION"
	echo "Usage: $0 domjudge-version"
	echo "	For example: $0 5.3.0"
	VERSION=${DEFAULT_VERSION}
fi

# To add packages in chroot we need to run in privileged mode and this can't be done in a docker file.
docker build -t domjudge/judgehost-extended:${VERSION}-build -f Dockerfile  --build-arg VERSION=${VERSION} .
docker rm -f domjudge-judgehost-extended-${VERSION}-build 2>&1 || true
docker run -it --name domjudge-judgehost-extended-${VERSION}-build --privileged domjudge/judgehost-extended:${VERSION}-build /install_languages.sh
docker commit -c "CMD [\"/scripts/start.sh\"]" domjudge-judgehost-extended-${VERSION}-build domjudge/judgehost-extended:${VERSION}
docker rm domjudge-judgehost-extended-${VERSION}-build 2>&1 || true
echo "Succesfull created image domjudge/judgehost-extended:${VERSION}"
exit 0
