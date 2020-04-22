# Plextini - plex in docker for Crostini
Why do we run Plex Media Server in Crostini?  Because we can!

Plex can be up and running in under half an hour on Crostini.

## Getting started

Clone or download this repository, then `cd` to it and follow the instructions below, which have been customized for Crostini.

### Docker
If you don't have Docker, [install it](https://docs.docker.com/engine/install/):
```
sudo apt-get install docker.io
```

Then [add yourself](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user) to the `docker` group so that `sudo` is not required to use Docker.
```
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

To have Plex automatically restart when the system reboots, you need to enable Docker to [start on boot](https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot):
```
sudo systemctl enable docker
```

### Configuring media folders
The `conf` file is where you customize your Plex server installation.
First configure your media folders.  In `conf` you will see:
```
media_folders=(media media1 media2 media3)
media=""
media1=""
media2=""
media3=""
```
Set these up however you like.  For example, if you are starting from scratch, you might do:
```
media_folders=(music pix videos)
music="/home/user/Music"
pix="/home/user/Pictures"
videos="/home/user/Videos"
```
Then in Plex when you go to add a library folder, your music will be in `/music`, pictures in `/pix`, and videos in `/videos`.

If you have an existing non-Dockerized Plex setup, and want to keep your existing meta-data without re-scanning all your media, you might do:
```
media_folders=(home)
home="/home"
```
Then in Plex your music will still be in `/home/user/Music`, pictures in `/home/user/Pictures`, and videos in `/home/user/Videos`.

## Other settings
Make these changes in `conf` which are particular to Crostini:
```
servername="Plextini"
containername="plextini"
mode="http-only"
hostip=<ip of your Chrome OS device>
```

## Crostini notes
### Port forwarding
The Crostini container runs in a VM under Chrome OS, and is not directly accessible on your network. If you want to reach Plex from other devices (that's the whole point, right?) you must set up a port forward from Chrome OS to Crostini.  First install the great [Connection Forwarder](https://chrome.google.com/webstore/detail/connection-forwarder/ahaijnonphgkgnkbklchdhclailflinn?hl=en-US) Chrome extension in Chrome.  Then click `Create Rule` and configure it to forward traffic to Plex's port 32400 on your Chrome OS device to port 32400 in Crostini:

![Crostini port forwarding](https://github.com/wpwoodjr/plex-docker/blob/master/crostini-port-forward.png)

You can also configure it to `Auto Start on Login` or `Run in Background`.

### Installing Firefox
When you start up Plex for the first time, you need a browser running in Crostini to do initial configuration of Plex. You can install Firefox for this purpose.  From Crostini, do:
```
sudo apt install firefox-esr
```
If you're running Ubuntu instead of the default Debian penguin, do:
```
sudo apt install firefox
```

### Sleep mode
To keep Chrome OS from going to sleep in the middle of `Terminator 2`, go to `Chrome OS Settings...Device...Power` and change `When idle` to `Turn off display` or `Keep display on`.

## Next steps
At this point you can proceed to [Starting the Plex container](https://github.com/wpwoodjr/plex-docker#starting-the-plex-container), or to [Other settings (optional)](https://github.com/wpwoodjr/plex-docker#other-settings-optional) to tweak other configuration settings.
