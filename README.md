# plex-docker
Easy to run Plex in Docker (host or bridge mode) with flexible configuration.  A nice benefit, it allows you to change the slideshow speed on the local web instance of Plex.

![Plex](https://i1.wp.com/softsfile.info/wp-content/uploads/2019/10/plex-pms-icon.png?fit=256%2C256)

## Getting started

After cloning or downloading this repository, `cd` to it and follow the instructions below.

### Docker
If you don't have Docker, install it per your OS instructions and [add yourself](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user) to the `docker` group so that `sudo` is not required to use Docker.

### `start`
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

### `stop`
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
The port on which Plex will listen for incoming HTTP traffic.  Plex's default port is `32400`, but you may prefer to set it to something else if you are running in Docker `bridged` mode.

`port` should be greater than `1024`.

#### `https_port`
The port on which Subsonic will listen for incoming HTTPS traffic. Default is 0 (disabled).
`https_port` should be greater than `1024`.

#### `hostip`
Sonos requires that the container use the host's ip address, not a container ip address.
By default `hostip` is blank, which tells the container to figure out the ip address of the host.  If it fails for some reason, then if your host ip is fixed, set `hostip` to that ip address. Otherwise, set hostip to `0.0.0.0` (Sonos may not work with Subsonic in this case).

Thanks to [uilkoenig](https://github.com/ulikoenig/subsonic-patched#run-container) for the info on Sonos.

#### `context_path`
The context path, i.e., the last part of the Subsonic URL. Typically "/" or "/subsonic". Default is "/".

#### `locale`
Default locale is `en_US.UTF-8`.

See https://www.tecmint.com/set-system-locales-in-linux/ for more info.

#### `tz`
Default time zone is `America/New_York`.  Set this to your time zone so that Subsonic's scheduled time for "Scan media folders" reflects your time zone.

See https://linuxize.com/post/how-to-set-or-change-timezone-in-linux/ for more info.

#### `user` and `uid`
By default Subsonic runs in the container under the user `subsonic` with uid `1000`.
Set `uid` to your uid to grant user `subsonic` write permissions in the music directories, otherwise changing album art and tags will fail.

If problems persist, you can try changing `user` to `root`, although from a security perspective it is better to run as a non-root user.

### `build`
This will build the Plex container, based on the latest version.  You can run this instead of the "public" Docker image if you don't want Plex to update itself every time it starts:
```
./build
```
