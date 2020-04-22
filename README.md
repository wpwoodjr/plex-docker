# plex-docker
I was in the position early on with Plex that I wanted to try it out quickly and see if I liked it.  In the end I had to spend hours learning how to configure it.  Long story short, I rolled up everything I learned here so others could benefit (and because it was fun).  In contrast to other "Plex in Docker" projects, this one attempts to take a high-level view of what you are trying to accomplish and automatically configure Docker and Plex to achieve that.

![Plex](https://i1.wp.com/softsfile.info/wp-content/uploads/2019/10/plex-pms-icon.png?fit=256%2C256)

## Getting started

Clone or [download](https://github.com/wpwoodjr/plex-docker/archive/master.zip) this repository, then `cd` to it and follow the instructions below.

### Docker
If you don't have Docker, [install it](https://docs.docker.com/engine/install/) per your OS instructions and [add yourself](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user) to the `docker` group so that `sudo` is not required to use Docker.

To have Plex automatically restart when the system reboots, you need to enable Docker to [start on boot](https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot).  In Ubuntu, do:
```
sudo systemctl enable docker
```

### Configuring media folders
You edit the `conf` file to customize your Plex server installation.
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

## Other settings (optional)
At this point you can proceed to [Starting the Plex container](https://github.com/wpwoodjr/plex-docker#starting-the-plex-container) below, or you can tweak these settings in `conf`:

### `config`
This is where Plex maintains its media database and configuration.  Default is `database/config` under the current working directory.  If you already have a Plex media database, or want to specify a different location, change `config` to the full path name.

### `transcode`
This is where Plex keeps temporary files during transcoding.  Default is `database/transcode` under the current working directory. If you want to specify a different location, change `transcode` to the full path name.

### `servername`
The name of your Plex server as displayed in Plex.  Defaults to `Plex Server`.

### `containername`
The name of the container that Plex runs in.  Defaults to `plex`.

### `port`
The port on which Plex will listen for incoming HTTP traffic.  Plex's normal port is `32400`, but if you are running two or more Plex servers, each will need a different HTTP port. `port` should be greater than `1024`.

### `mode`
The mode to run Docker in, `host`, `bridged`, or `http-only`.  `host` and `bridged` modes expose all the normal Plex network ports.  See [What network ports do I need to allow through my firewall?](https://support.plex.tv/articles/201543147-what-network-ports-do-i-need-to-allow-through-my-firewall/).  You can only run one Plex server in either `host` or `bridged` mode on a given host machine.

`http-only` runs in bridged mode and only exposes the HTTP `port` defined above.  You can run one Plex server in either `host`, `bridged`, or `http-only` modes, and add additional Plex server(s) in `http-only` mode.  Ensure that each Plex server has a unique `port`, `servername`, and `containername`; and that `mode` is set appropriately.

`mode` defaults to `host`.  In `host` mode the `port` is always `32400`.

### `plexlogin`
Indicates whether you plan to "claim" this server by logging it in.  Defaults to `true`.  Set `plexlogin` to `false` if you don't plan to access this server from https://app.plex.tv/.

### `slideshow_speed_ms`
The number of milliseconds a slide remains on-screen before switching to the next slide.  Since this relies on a change to the Javascript of the Plex Web Interface, it is only applicable when viewing the slideshow from your local Plex server (for example from http://10.0.1.15:34200/web, not from https://app.plex.tv).  See [Opening Plex Web App](https://support.plex.tv/articles/200288666-opening-plex-web-app/) for more info. Defaults to 5000 milliseconds (Plex's default).

Since this feature relies on undocumented information, it could stop working any time there is a Plex upgrade.

### `tz`
Set this to your time zone so that Plex's time for running scheduled tasks reflects your time zone.  By default `tz` is set to `America/New_York`.

See https://linuxize.com/post/how-to-set-or-change-timezone-in-linux/ and https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for more info.

### `uid` and `gid`
By default Plex runs in the container under the user `plex` with your uid and gid.  If your uid or gid doesn't have read/write privileges to your media directories, set `uid` and/or `gid` to a value which does have read/write permissions in the media directories.

### `hostip`
The IP address of the host machine that Docker is running on.  Normally leave this blank unless the `start` script can't figure out the correct host IP address.

### `docker_network`
Docker's bridge network address range.  Normally you won't need to change this.

### `image`
This is the Docker image that is used to run Plex.  By default it is `plexinc/pms-docker:public`.  This image will update to the latest version of Plex Media Server every time the container is run.  If you want the beta version of Plex, change `public` to `beta`.  Note, beta versions are only available to Plex Pass subscribers.

### `restart_policy`
The restart policy for the Plex container.  Defaults to `always`.  If you don't want the container to restart on reboot, set it to `no`.

### `hardware_transcoding_device`
If your Docker host has access to a supported CPU with the Intel Quick Sync feature set and you are a current Plex Pass subscriber, you can enable hardware transcoding.  Set `hardware_transcoding_device` to the name of the kernel device, for example:
```
hardware_transcoding_device="/dev/dri:/dev/dri"
```
See [Intel Quick Sync Hardware Transcoding Support](https://github.com/plexinc/pms-docker/blob/master/README.md#intel-quick-sync-hardware-transcoding-support) for more info.

### `plex_claim_token`
The claim token for the Plex server to be automatically logged in to your Plex account. If the server is already logged in, this is ignored. You can obtain a claim token by visiting https://www.plex.tv/claim.

## Starting the Plex container
After configuring settings in `conf`, run:
```
./start
```
to start Plex.  You will see some log output similar to:
```
$ ./start
36f7cbac3839852bcef92efdf834e8cb2f7a29e30f353812162cf37915abc986
[s6-init] making user provided files available at /var/run/s6/etc...exited 0.
[s6-init] ensuring user provided files have correct perms...exited 0.
[fix-attrs.d] applying ownership & permissions fixes...
[fix-attrs.d] done.
[cont-init.d] executing container initialization scripts...
[cont-init.d] 40-plex-first-run: executing... 
Plex Media Server first run setup complete
[cont-init.d] 40-plex-first-run: exited 0.
[cont-init.d] 45-plex-hw-transcode-and-connected-tuner: executing... 
[cont-init.d] 45-plex-hw-transcode-and-connected-tuner: exited 0.
[cont-init.d] 50-plex-update: executing... 
Attempting to upgrade to: 1.18.9.2578-513b381af
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   190    0   190    0     0    307      0 --:--:-- --:--:-- --:--:--   307
100 86.2M  100 86.2M    0     0  14.3M      0  0:00:06  0:00:06 --:--:-- 16.7M
Selecting previously unselected package plexmediaserver.
(Reading database ... 7569 files and directories currently installed.)
Preparing to unpack /tmp/plexmediaserver.deb ...
PlexMediaServer install: Pre-installation Validation.  
PlexMediaServer install: Docker detected. Preinstallation validation not required.  
Unpacking plexmediaserver (1.18.9.2578-513b381af) ...
Setting up plexmediaserver (1.18.9.2578-513b381af) ...
PlexMediaServer install: Docker detected. Postinstallation tasks not required. Continuing.   
Processing triggers for libc-bin (2.23-0ubuntu11) ...
[cont-init.d] 50-plex-update: exited 0.
[cont-init.d] done.
[services.d] starting services
[services.d] done.
Starting Plex Media Server.

Plex Server started in container plex (http-only mode) at http://10.0.1.15:34200/web
First time setup (see README.md for more info):
  o Using an incognito browser on the Docker host machine,
    do initial setup at http://localhost:34200/web
  o On the Remote Access settings page,
    you can Manually specify public port as 34200 (or another port of your choosing)
  o If you are a Plex Pass subscriber, on the Network settings page
    set LAN Networks to 10.0.1.15/24,172.16.0.0/12
Slideshow speed set to 4000 milliseconds
```
Plex should be up and running!  To go to its browser interface, note the line starting with "Plex server started" in the log output, and browse to the web address. For example, browse to `http://10.0.1.15:32400/web`

### Initial startup tips
When you start a new Plex server, it's a good idea to do initial setup by first browsing to `localhost` on the Docker host machine in an incognito browser, as described in the `First time setup` instructions in the output above.  If your server is headless you can try [this](https://github.com/plexinc/pms-docker#running-on-a-headless-server-with-container-using-host-networking). Follow these steps for best results:

1) Before starting the server, delete all of its config files that may be left over from previous attempts to run it.

2) After starting the server, during initial setup, use an incognito browser that is on the same machine as the server. Clear cache in the browser for good luck, then go to http://localhost:port/web, where `port` is as configured above. Don’t use the machine’s actual IP address. This will give you the option at the app.plex.tv login screen to sign in (do this if `plexlogin` in the `conf` file is `true`) or to skip logging in by clicking on “What’s this?” (do this if `plexlogin` is `false`).

3) At the first Server Setup screen, if running in `bridged` or `http-only` mode, uncheck `Allow me to access my media outside my home`.  You will have to configure this manually later, see [Remote Access settings page](https://github.com/wpwoodjr/plex-docker#remote-access-settings-page) below.

4) If you did not log in at app.plex.tv during step 2, you ***must*** add a library during initial setup. If you don’t, the browser just sits there with a spinner at a link that ends with `client-setup`.

5) If you did log in, you should see the new server listed under **MORE** on the left side.

## Stopping the Plex container
To stop Plex, run:
```
./stop
```
After you stop Plex, it will not restart again until you restart it with `./start` as described above.

## Finishing up
Once the server is up and running, go to its settings pages and finish configuring it. 

### Remote Access settings page
If the server is logged in, on this screen you will be able to manually enter the `port` (as configured in `conf`) for remote access.  You may also need to configure your router to pass that port through.

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
