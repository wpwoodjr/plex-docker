# Plextini - plex in docker for Crostini
Why do we run Plex Media Server in Crostini?  Because we can!

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
The Crostini container runs in a VM under Chrome OS, and is not directly accessible on your network. If you want to reach Plex from other devices (that's the whole point, right?) you must set up a port forward from Chrome OS to Crostini.  First install the great [Connection Forwarder](https://chrome.google.com/webstore/detail/connection-forwarder/ahaijnonphgkgnkbklchdhclailflinn?hl=en-US) Chrome extension in Chrome.  Then click `Create Rule` and configure it as follows:

![Crostini port forwarding](https://github.com/wpwoodjr/plex-docker/blob/master/crostini-port-forward.png)

You can also configure it to `Auto Start on Login` or `Run in Background`.

### Initial startup tips
When you start a new Plex server, it's a good idea to do initial setup by first browsing to `localhost` on the Docker host machine in an incognito browser, as described near the end of the output above (if your server is headless you can try [this](https://github.com/plexinc/pms-docker#running-on-a-headless-server-with-container-using-host-networking)). Follow these steps for best results:

1) Before starting the server, delete all of its config files that may be left over from previous attempts to run it.

2) After starting the server, during initial setup, use an incognito browser that is on the same machine as the server. Clear cache in the browser for good luck, then go to http://127.0.0.1:port/web, where `port` is as configured above. Don’t use the machine’s actual IP address. This will give you the option at the app.plex.tv login screen to sign in (do this if `plexlogin` is `true`) or to skip logging in by clicking on “What’s this?” (do this if `plexlogin` is `false`).

3) At the first Server Setup screen, if running in `bridged` or `http-only` mode, uncheck `Allow me to access my media outside my home`.  You will have to configure this manually later, see [Remote Access settings page](https://github.com/wpwoodjr/plex-docker#remote-access-settings-page) below.

4) If you did not log in at app.plex.tv during step 2, you ***must*** add a library during initial setup. If you don’t, the browser just sits there with a spinner at a link that ends with `client-setup`.

5) If you did log in, you should see the new server listed under **MORE** on the left side.


## Next steps
At this point you can proceed to [Other settings](https://github.com/wpwoodjr/plex-docker#other-settings-optional) to tweak other settings, or to [Starting the Plex container](https://github.com/wpwoodjr/plex-docker#starting-the-plex-container) in the README.md.

## Stopping the Plex container
To stop Plex, run:
```
./stop
```
After you stop Plex, it will not restart again until you restart it with `./start` as described above.

## Finishing up
Once the server is up and running, go to its settings pages and finish configuring it. 

### Remote Access settings page
If the server is logged in, on this screen you will be able to manually enter the `port` (as configured in `conf`) for remote access (if not enabled already).  You may also need to configure your router to pass that port through.

### Networks settings page
#### LAN Networks
If `mode` is `bridged` or `http-only`, and you are a Plex Pass subscriber, pay particular attention to the `LAN Networks` setting.  Set it to `ip/24,docker_network`, where `ip` is the ip address of your host machine, and `docker_network` is as configured in `conf`.

#### Effect of `plexlogin` on network settings
The `plexlogin` setting, described above, directly affects the values of these `Network` settings:
##### `Custom server access URLs`
If `plexlogin` is `true`, and `mode` is `bridged` or `http-only`, this will be set to `http://ip:port/` where `ip` is the ip address of your host machine and `port` is as configured in `conf`.  Otherwise this will be set to blank.

##### `List of IP addresses and networks that are allowed without auth`
If `plexlogin` is `false`, this will be set to `ip/24,docker_network` where `ip` is the ip address of your host machine, and `docker_network` is as configured in `conf`.
Otherwise this will be set to blank.

## Plex updates
If you get a server update notice, just `./stop` then `./start` the server to get the update.

## Running more than one Plex server
You can run zero or one Plex server(s) in `host` or `bridged` mode on a given host machine.  You can also run zero or more Plex server(s) in `http-only` mode. 

To run a second Plex server, make a copy of these Github files in another directory and configure the `conf` file for the additional server.  Be sure to give the server a different `servername`, `containername`, and `port`.  Set `mode` as well.

## More info
For more information, or to help debug any issues, see the [Official Docker container for Plex Media Server](https://github.com/plexinc/pms-docker) documentation.
