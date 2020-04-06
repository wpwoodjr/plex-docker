# plex-docker
Easy to run Plex in Docker (host or bridge mode) with flexible configuration.  A nice benefit, it allows you to change the slideshow speed on the local web instance of Plex, and to run more than one Plex server on a given host.

![Plex](https://i1.wp.com/softsfile.info/wp-content/uploads/2019/10/plex-pms-icon.png?fit=256%2C256)

## Getting started

After cloning or downloading this repository, `cd` to it and follow the instructions below.

### `Docker`
If you don't have Docker, install it per your OS instructions and [add yourself](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user) to the `docker` group so that `sudo` is not required to use Docker.

### `./start`
After configuring settings (see `conf` section below), run:
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
Slideshow speed set to 4000
Plex Server started in container plex at http://10.0.1.15:32400/web
```
Plex should be up and running!  To go to its browser interface, note the last line in the log output, and browse to the web address. For example, browse to `10.0.1.15:32400/web`

To have Plex automatically restart when the system reboots, you need to enable Docker to [start on boot](https://docs.docker.com/install/linux/linux-postinstall/#configure-docker-to-start-on-boot).  In Ubuntu, do:
```
sudo systemctl enable docker
```

### `./stop`
To stop Plex, run:
```
./stop
```
If you stop Plex, it will not restart again until you restart it with `./start` as above.

### `conf`
The `conf` file is where you customize your installation as required. `conf` contains the following configurable settings:

#### `plex_dir`
Directory where Plex's database will reside.  Defaults to `<current directory>/database`. You should not need to change this.

#### `media`
Directory containing your media files.

Defaults to `media` in `plex_dir`.  You can change `media` to point directly to your media directory, or alternatively you can create a symbolic link in `plex_dir` from `media` to your media directory:
```
ln -s /your-media/ database/media
```
You could also copy all your media to `database/media`.

If you don't change, copy, or create a symbolic link for `media`, by default a new directory called `media` will be created in `plex_dir`.

#### `database`
This is where Plex maintains its database and configuration.

Defaults to `database` in `plex_dir`.  You can change `database` to point directly to your Plex database directory, or alternatively you can create a symbolic link in `plex_dir` from `data` to your Plex database directory:
```
ln -s /your-plex-database/ database/database
```
If you don't change or create a symbolic link for `database`, by default a new directory called `database` will be created in `plex_dir`.

#### `transcode`
This is where Plex puts temporary files during transcoding.  You should not need to change this.

Defaults to `transcode` in `plex_dir`.  You can change `transcode` to point directly to your transcode temporary space, or alternatively you can create a symbolic link in `plex_dir` from `transcode`:
```
ln -s /your-plex-transcode-area/ database/transcode
```
If you don't change or create a symbolic link for `transcode`, by default a new directory called `transcode` will be created in `plex_dir`.

#### `port`
The port on which Plex will listen for incoming HTTP traffic.  Plex's normal port is `32400`, but if you are running two or more Plex servers, each will need a different port. `port` should be greater than `1024`.

#### `mode`
The mode to run Docker in, `host`, `bridged`, or `http-only`.  `host` and `bridged` modes expose all the normal Plex network ports.  See [What network ports do I need to allow through my firewall?](https://support.plex.tv/articles/201543147-what-network-ports-do-i-need-to-allow-through-my-firewall/).  You can only run one Plex server in either `host` or `bridged` modes on a given host.

`http-only` runs in bridged mode and only exposes Plex's HTTP port.  You can run one Plex server in either `host`, `bridged`, or `http-only` modes, and add additional Plex server(s) in `http-only` mode.  Ensure that each Plex server has a unique `port`.

Defaults to `host`.  In `host` mode the port is always 32400.

#### `servername`
The name of your Plex server as displayed in Plex.  Defaults to "Plex Server".

#### `containername`
The name of the container that Plex runs in.  Defaults to `plex`.

#### `plexlogin`
Whether to require users to log in to access Plex.  Defaults to `true`.  Set to `false` to allow access to the Plex server from your local network without logging in.

#### `slideshow_speed_ms`
The number of milliseconds a slide remains on-screen before switching to the next slide.  Only applicable when viewing the slideshow in Plex's local web interface, from your local server (ie not from `app.plex.tv`).  Defaults to 5000 milliseconds (Plex's default).

#### `tz`
Set this to your time zone so that Plex's scheduled time for running scheduled tasks reflects your time zone.  By default time zone is set to `America/New_York`.

See https://linuxize.com/post/how-to-set-or-change-timezone-in-linux/ and https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for more info.

#### `uid` and `gid`
By default Plex runs in the container under the user `plex` with your uid and gid.  If your uid or gid doesn't have read/write privileges to your media directories, set `uid` and/or `gid` to a value which will grant user `plex` read/write permissions in the media directories.

#### `hostip`
The IP address of the host that Docker is running on.  Normally leave this blank unless the `start` script can't figure out the correct host IP address.

#### `docker-network`
Docker's bridge network address range.  Normally you won't need to change this.

#### `image`
This is the Docker image that is used to run Plex.  By default it is `plexinc/pms-docker:public`.  This image will update itself to the latest version of Plex Media Server every time it is started.  If you don't want auto updates, you can use the `build` command (see below) to build a local Docker image named `plex` and run that instead.  It's faster to start up too.

### `./build`
This will build a local Plex image, based on the latest version of Plex Media Server, and upgrade other system packages.  You can run this instead of the "public" Docker image if you don't want Plex to update itself every time it starts:
```
./build
```
Then set the `image` setting in `conf` to `plex` and start Plex with the `start` script.

## Running more than one Plex server
You can run one Plex server in `host`, `bridged`, or `http-only` modes on a given host.  You can add additional Plex server(s), but only in `http-only` mode.  When running more than one, ensure each one has a unique `port`.  

To run another Plex server, make a copy of these files in another directory and configure the `conf` file for the additional server.  Configure the `media`, `database`, and `transcode` directories, and give it a different `port`, `containername`, and `servername`.

## More info
For more information, see the [Official Docker container for Plex Media Server](https://github.com/plexinc/pms-docker) documentation.
