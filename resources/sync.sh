#!/usr/bin/env bash

# Build the package strings (packages has a trailing |)
PACKAGES=$(cat /packages.txt | tr -d '\r' | tr '\n' '|' | sed 's/|/ | /g')
FILTER="$PACKAGES Priority (required) | Priority (important) | Priority (standard)"

# Get the ubuntu version name (jammy, etc.)
VER=$(lsb_release -cs)

# Check if any "jammy" packages have been added
if ! aptly publish list | grep -c $VER >> /dev/null; then

	echo "[INFO] Building repository for the first time..."

	# Create the mirrors for main, updates, and security
	aptly mirror create -architectures=amd64 -with-sources=true -with-udebs=true -filter="$FILTER" -filter-with-deps $VER-main http://archive.ubuntu.com/ubuntu/ $VER main
	aptly mirror create -architectures=amd64 -with-sources=true -with-udebs=true -filter="$FILTER" -filter-with-deps $VER-security http://security.ubuntu.com/ubuntu/ $VER-security main
	aptly mirror create -architectures=amd64 -with-sources=true -with-udebs=true -filter="$FILTER" -filter-with-deps $VER-backports http://security.ubuntu.com/ubuntu/ $VER-backports main
	aptly mirror create -architectures=amd64 -with-sources=true -with-udebs=true -filter="$FILTER" -filter-with-deps $VER-updates http://archive.ubuntu.com/ubuntu/ $VER-updates main

	# Copy everything from the docker repo
	aptly mirror create -architectures=amd64 docker-stable https://download.docker.com/linux/ubuntu/ $VER stable

	# Perform the initial repo clone
	aptly mirror update $VER-main
	aptly mirror update $VER-security
	aptly mirror update $VER-backports
	aptly mirror update $VER-updates
	aptly mirror update docker-stable

	# Take and merge snapshots
	SNAPNAME=$(date +'%Y%m%d-%H%M%S')
	aptly snapshot create $VER-main-$SNAPNAME from mirror $VER-main
	aptly snapshot create $VER-security-$SNAPNAME from mirror $VER-security
	aptly snapshot create $VER-backports-$SNAPNAME from mirror $VER-backports
	aptly snapshot create $VER-updates-$SNAPNAME from mirror $VER-updates
	aptly snapshot create docker-stable-$SNAPNAME from mirror docker-stable
	aptly snapshot merge -latest merged-$SNAPNAME $VER-main-$SNAPNAME $VER-updates-$SNAPNAME $VER-security-$SNAPNAME $VER-backports-$SNAPNAME docker-stable-$SNAPNAME

	# Publish the first snapshot (only run once)
	aptly publish snapshot -distribution=$VER merged-$SNAPNAME

else

	echo "[INFO] Performing incremental update..."

	# Update the mirror filters in case any packages were added since first run
	aptly mirror edit -filter="$FILTER" -filter-with-deps $VER-main
	aptly mirror edit -filter="$FILTER" -filter-with-deps $VER-security
	aptly mirror edit -filter="$FILTER" -filter-with-deps $VER-backports
	aptly mirror edit -filter="$FILTER" -filter-with-deps $VER-updates

	# Perform the update
	aptly mirror update $VER-main
	aptly mirror update $VER-security
	aptly mirror update $VER-backports
	aptly mirror update $VER-updates
	aptly mirror update docker-stable

	# Take and merge snapshots
	SNAPNAME=$(date +'%Y%m%d-%H%M%S')
	aptly snapshot create $VER-main-$SNAPNAME from mirror $VER-main
	aptly snapshot create $VER-security-$SNAPNAME from mirror $VER-security
	aptly snapshot create $VER-backports-$SNAPNAME from mirror $VER-backports
	aptly snapshot create $VER-updates-$SNAPNAME from mirror $VER-updates
	aptly snapshot create docker-stable-$SNAPNAME from mirror docker-stable
	aptly snapshot merge -latest merged-$SNAPNAME $VER-main-$SNAPNAME $VER-updates-$SNAPNAME $VER-security-$SNAPNAME $VER-backports-$SNAPNAME docker-stable-$SNAPNAME

	# Replace the deployed packages
	aptly publish switch $VER merged-$SNAPNAME

	# Remove unreferenced packages
	aptly db cleanup

fi
