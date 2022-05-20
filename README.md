# Ubuntu Repository Cloner

This container will clone patches for Ubuntu 22.04 along with user-specified
packages.  It uses [Aptly](https://www.aptly.info/) to perform incremental
updates and bundling.  By default, downloaded packages will be stored in a
folder called */repo* which can be re-mounted to a later run of the container to
prevent re-downloading the same patches.

## Docker

Docker is a container platform which allows us to run Ubuntu on a variety of
host operating systems.  Installation instructions can be found here:
https://docs.docker.com/get-docker/

## Helper Scripts

In the */bin* folder are a number of helper scripts for Windows:

- **BUILD.bat**: Builds and tags the Repository Cloner container (only needed once)
- **SYNC.bat**: Synchronize the repositories (incrementally if performed previously)
- **kill.bat**: Kills the synchronization container if it stops responding
- **serve.bat**: Serves downloaded patches to the test instances
- **test.bat**: Spins up an unpatched instance, pointed to repo_clone for updates (run *serve.bat* first)
- **shell.bat**: Opens up an interactive shell to the cloner for troubleshooting

## Usage

By default, only critical OS patches are included in the synchronization.  You
can add custom packages by editing the *resources/packages.txt* prior to running
*SYNC.bat* (one package per line).

At the conclusion of *SYNC.bat*, **./repo** on the host OS will now contain
the latest versions of all requested packages and dependencies.  This can be
moved to the target machine and delivered to clients with **aptly serve**.  

To get clients to connect to Aptly for updates, overwrite their
*/etc/apt/sources.list* with contents similar to the one in
*resources/sources.list*.  
