# plex-docker
Easy to run Plex in Docker (host or bridge mode) with flexible configuration.  A nice benefit, it allows you to change the slideshow speed, and to run multiple Plex servers on one host.

![Plex](https://i1.wp.com/softsfile.info/wp-content/uploads/2019/10/plex-pms-icon.png?fit=256%2C256)

## Getting started

Clone or download this repository, the `cd` to it and follow the instructions below.

## Docker
If you don't have Docker, install it per your OS instructions and [add yourself](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user) to the `docker` group so that `sudo` is not required to use Docker.

## Configuring media folders
The `conf` file is where you customize your Plex server installation.
First configure your media folders.  In `conf` you will see:
```
media_folders=(media media1 media2 media3)
media=""
media1=""
media2=""
media3=""
```
Set these up however you like.  For example, if you are starting from scratch, you might just do:
```
media_folders=(music pix videos)
music="/home/user/Music"
pix="/home/user/Pictures"
videos="/home/user/Videos"
```
Then in Plex when you go to add a folder, your music will be in `/music`, pictures in `/pix`, and videos in `/videos'.

If you have an existing non-Dockerized Plex setup, and want to keep your existing meta-data, you might do:
```
media_folders=(home)
home="/home"
```
Then in Plex when you go to add a folder, your music will be in `/home/user/Music`, pictures in `/home/user/Pictures`, and videos in `/home/user/Videos`.

## Other settings
Other settings in `conf` may be configured as follows:

### `config`
This is where Plex maintains its media database and configuration.

If you already have a Plex media database, enter the full path name,
otherwise leave this blank (unless you want the Plex database in a particular location).

If you don't change the value of `config`, by default a new directory named `config` will be created in directory `database` under the current working directory.

### `transcode`
This is where Plex keeps temporary files during transcoding.  You probably do not need to change this, however you can change the value of `transcode` to the full path name of a transcode temporary space.

If you don't change the value of `transcode`, by default a new directory named `transcode` will be created in directory `database` under the current working directory.

### `servername`
The name of your Plex server as displayed in Plex.  Defaults to `Plex Server`.

### `containername`
The name of the container that Plex runs in.  Defaults to `plex`.

### `port`
The port on which Plex will listen for incoming HTTP traffic.  Plex's normal port is `32400`, but if you are running two or more Plex servers, each will need a different HTTP port. `port` should be greater than `1024`.

### `mode`
The mode to run Docker in, `host`, `bridged`, or `http-only`.  `host` and `bridged` modes expose all the normal Plex network ports.  See [What network ports do I need to allow through my firewall?](https://support.plex.tv/articles/201543147-what-network-ports-do-i-need-to-allow-through-my-firewall/).  You can only run one Plex server in either `host` or `bridged` mode on a given host machine.

`http-only` runs in bridged mode and only exposes the HTTP `port` defined above.  You can run one Plex server in either `host`, `bridged`, or `http-only` modes, and add additional Plex server(s) in `http-only` mode.  Ensure that each Plex server has a unique `port`.

`mode` defaults to `host`.  In `host` mode the `port` is always `32400`.

### `plexlogin`
Indicates whether you plan to "claim" this server by logging it in.  Defaults to `true`.  Set `plexlogin` to `false` if you don't plan to access this server from https://app.plex.tv/.

### `slideshow_speed_ms`
The number of milliseconds a slide remains on-screen before switching to the next slide.  
Since this relies on a change to the Javascript of the Plex Web Interface, it is only applicable when viewing the slideshow in Plex's web interface, from your local server (for example from http://10.0.1.15:34200/web, not from https://app.plex.tv).  Defaults to 5000 milliseconds (Plex's default).

Since this feature relies on undocumented information, it could stop working any time there is a Plex upgrade.

### `tz`
Set this to your time zone so that Plex's time for running scheduled tasks reflects your time zone.  By default `tz` is set to `America/New_York`.

See https://linuxize.com/post/how-to-set-or-change-timezone-in-linux/ and https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for more info.

### `uid` and `gid`
By default Plex runs in the container under the user `plex` with your uid and gid.  If your uid or gid doesn't have read/write privileges to your media directories, set `uid` and/or `gid` to a value which does have read/write permissions in the media directories.

### `hostip`
The IP address of the host machine that Docker is running on.  Normally leave this blank unless the `start` script can't figure out the correct host IP address.

### `docker-network`
Docker's bridge network address range.  Normally you won't need to change this.

### `image`
This is the Docker image that is used to run Plex.  By default it is `plexinc/pms-docker:public`.  This image will update to the latest version of Plex Media Server every time the container is run.  If you want the beta version of Plex, change `public` to `beta`.  Note, beta versions are only available to Plex Pass subscribers.

### `restart-policy`
The restart policy for the Plex container.  Defaults to `always`.  If you don't want the container to restart on reboot, set it to `no`.

## Starting the Plex container
After configuring settings (see above), run:
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

Plex Server started in container plex at http://10.0.1.15:34200/web
If this is the first time running this Plex server, do initial setup at http://localhost:34200/web
using an incognito browser on the Docker host machine.
Slideshow speed set to 4000 milliseconds.
```
Plex should be up and running!  To go to its browser interface, note the "Plex server started" line in the log output, and browse to the web address. For example, browse to `http://10.0.1.15:32400/web`

When you start a new container, it's a good idea to do initial setup by browsing to it using `localhost` from the local Docker host machine in an incognito browser, as described near the end of the output above.

To have Plex automatically restart when the system reboots, you need to enable Docker to [start on boot](https://docs.docker.com/install/linux/linux-postinstall/#configure-docker-to-start-on-boot).  In Ubuntu, do:
```
sudo systemctl enable docker
```

## Stopping the Plex container
To stop Plex, run:
```
./stop
```
After you stop Plex, it will not restart again until you restart it with `./start` as described above.

## Finishing up
Once the server is up and running, go to its settings pages to finsh configuring it. If you are a Plex Pass subscriber, pay particular attention to the `LAN Networks` setting on the `Network` settings page.

The `plexlogin` setting, described above, directly affects the values of these `Network` settings:
### `Custom server access URLs`
If `plexlogin` is `true`, and `mode` is `bridged` or `http-only`, this will be set to `http://ip:port/` where `ip` is the ip address of your host machine and `port` is as you configured it in `conf`.  Otherwise this will be set to blank.

### `List of IP addresses and networks that are allowed without auth`
If `plexlogin` is `false`, this will be set to `ip/24,docker-network` where `ip` is the ip address of your host machine, and `docker-network ` is as you configured it in `conf`.
Otherwise this will be set to blank.

## Plex updates
If you get a server update notice, just `./stop` then `./start` the server to get the update.

## Running more than one Plex server
You can run zero or one Plex server(s) in `host` or `bridged` mode on a given host machine.  You can run zero or more Plex server(s) in `http-only` mode. 

To run a second Plex server, make a copy of these Github files in another directory and configure the `conf` file for the additional server.  Be sure to give the server a different `servername`, `containername`, and `port`.  Set `mode` as well.

## More info
For more information, see the [Official Docker container for Plex Media Server](https://github.com/plexinc/pms-docker) documentation.
