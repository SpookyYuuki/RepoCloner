FROM ubuntu:22.04

# Peform initial OS upgrade
RUN apt update -y && apt upgrade -y

# Install package cloner
RUN apt install -y aptly

# Add docker repository for cloning
RUN apt install -y apt-transport-https ca-certificates curl software-properties-common && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
	apt update && \
	apt-cache policy docker-ce

# Generate the GPG key used for signing repos, and load existing repo certs
RUN gpg --batch --passphrase '' --quick-gen-key RepoCloner DSA default 0 && \
 	gpg --no-default-keyring --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import --yes --always-trust && \
	gpg --no-default-keyring --keyring /usr/share/keyrings/docker-archive-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import --yes --always-trust && \
	gpg --no-default-keyring --keyring /usr/share/keyrings/ubuntu-master-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import --yes --always-trust

COPY resources/sync.sh /sync.sh

CMD aptly serve
