# subsonic-docker
Easy to run Subsonic in Docker with flexible configuration.
![Subsonic by Sindre Mehus](http://www.subsonic.org/pages/inc/img/subsonic_logo.png)

Thanks to Sindre Mehus at [subsonic.org](http://www.subsonic.org/pages/index.jsp) for making the best home music serving solution!

## Getting started

After cloning or downloading this repository, `cd` to it and follow the instructions below.

### `build`
If you don't have Docker, install it per your OS instructions and [add yourself](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user) to the `docker` group so that `sudo` is not required to use Docker. Then run:
```
./build
```
This will build the Subsonic container, based on Subsonic 6.1.6.

### `start`
After configuring settings (see `conf` section below), run:
```
./start
```
to start Subsonic.  You will see some log output similar to:
```
$ ./start
416bb53f3c6e39f0641e2f9f7099d892e6ab637290c3cb89119a2207a81d71dd

Starting Subsonic on Mon Mar 23 09:49:30 EDT 2020

initializing container
setting locale to en_US.UTF-8
Generating locales (this might take a while)...
  en_US.UTF-8... done
Generation complete.
setting timezone to America/New_York
creating user subsonic with uid 1000

updating transcode files
total 105068
-rwxr-xr-x 1 subsonic subsonic 32495668 Nov 10 13:32 ffmpeg
-rwxr-xr-x 1 subsonic subsonic   372787 Nov 10 13:32 lame

starting Subsonic with args --host=10.0.1.15  --port=4040 --https-port=0 --context-path=/ --max-memory=250
Started Subsonic [PID 66, /var/subsonic/subsonic_sh.log]
   66 ?        R      0:00 java -Xmx250m -Dsubsonic.home=/var/subsonic -Dsubsonic.host=10.0.1.15 -Dsubsonic.port=4040 -Dsubsonic.httpsPort=0 -Dsubsonic.contextPath=/ -Dsubsonic.db= -Dsubsonic.defaultMusicFolder=/var/music -Dsubsonic.defaultPodcastFolder=/var/music/Podcast -Dsubsonic.defaultPlaylistFolder=/var/playlists -Djava.awt.headless=true -verbose:gc -jar subsonic-booter-jar-with-dependencies.jar
```
Subsonic should be up and running!  To go to its browser interface, note the `--host=<ip>`, `--port=<port>`, and `--context-path=<path>` settings in the log output, and browse to `<ip>:<port><context-path>`. For example, browse to `10.0.1.15:4040/`

To have Subsonic automatically restart when the system reboots, you need to enable Docker to [start on boot](https://docs.docker.com/install/linux/linux-postinstall/#configure-docker-to-start-on-boot).  In Ubuntu, do:
```
sudo systemctl enable docker
```

### `stop`
To stop Subsonic, run:
```
./stop
```
If you stop Subsonic, it will not restart again until you restart it with `./start` as above.

### `conf`
The `conf` file is where you customize your installation as required. `conf` contains the following configurable settings:

#### `subsonic_dir`
Directory where you downloaded this repo.  You should not need to change this unless the auto-detect fails for some reason.

#### `music`
Directory containing your music files.

Defaults to `music` in `subsonic_dir`.  You can change `music` to point directly to your music directory, or alternatively you can create a symbolic link in `subsonic_dir` from `music` to your music directory:
```
ln -s /your-music/ music
```
If you don't change `music`, a new directory called `music` will be created in `subsonic_dir`.

#### `videos`
Directory containing your video files.

Defaults to `videos` in `subsonic_dir`.  You can change `videos` to point directly to your videos directory, or alternatively you can create a symbolic link in `subsonic_dir` from `videos` to your videos directory:
```
ln -s /your-videos/ videos
```
If you don't change `videos`, a new directory called `videos` will be created in `subsonic_dir`.

**Note:** Unlike the `music` folder, the `videos` folder is not automatically added for you in Subsonic.  In the Subsonic browser interface, go to `Settings...Media Folders` and add it as a media folder with name `Videos` in folder `/var/videos`.

#### `playlists`
Directory containing your playlist files.

Defaults to `playlists` in `subsonic_dir`.  You can change `playlists` to point directly to your playlists directory, or alternatively you can create a symbolic link in `subsonic_dir` from `playlists` to your playlists directory:
```
ln -s /your-playlists/ playlists
```
If you don't change `playlists`, a new directory called `playlists` will be created in `subsonic_dir`.

#### `podcasts`
Directory containing your podcasts.

Defaults to `podcasts` in `subsonic_dir`.  You can change `podcasts` to point directly to your podcasts directory, or alternatively you can create a symbolic link in `subsonic_dir` from `podcasts` to your podcasts directory:
```
ln -s /your-podcasts/ podcasts
```
If you don't change `podcasts`, a new directory called `podcasts` will be created in `subsonic_dir`.

#### `data`
This is where Subsonic maintains its database and configuration.

Defaults to `data` in `subsonic_dir`.  You can change `data` to point directly to your Subsonic data directory, or alternatively you can create a symbolic link in `subsonic_dir` from `data` to your Subsonic data directory:
```
ln -s /your-subsonic-data/ data
```
If you don't change `data`, a new directory called `data` will be created in `subsonic_dir`.

#### `mem`
The memory limit (max Java heap size) in megabytes.  Defaults to `250`. Unless your music collection is huge, this should be fine.

#### `port`
The port on which Subsonic will listen for incoming HTTP traffic.  Subsonic's default port is `4040`, but you may prefer to set it to something else since it is a well known port.
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

#### `args`
Defaults to blank (no args).
You probably won't need to add any args, as most are configured already above.
For reference here is the list of Subsonic arguments:
```
Usage: subsonic.sh [options]
  --help               This small usage guide.
  --home=DIR           The directory where Subsonic will create files.
                       Make sure it is writable. Default: /var/subsonic
  --host=HOST          The host name or IP address on which to bind Subsonic.
                       Only relevant if you have multiple network interfaces and want
                       to make Subsonic available on only one of them. The default value
                       will bind Subsonic to all available network interfaces. Default: 0.0.0.0
  --port=PORT          The port on which Subsonic will listen for
                       incoming HTTP traffic. Default: 4040
  --https-port=PORT    The port on which Subsonic will listen for
                       incoming HTTPS traffic. Default: 0 (disabled)
  --context-path=PATH  The context path, i.e., the last part of the Subsonic
                       URL. Typically '/' or '/subsonic'. Default '/'
  --db=JDBC_URL        Use alternate database. MySQL, PostgreSQL and MariaDB are currently supported.
  --max-memory=MB      The memory limit (max Java heap size) in megabytes.
                       Default: 100
  --pidfile=PIDFILE    Write PID to this file. Default not created.
  --quiet              Don't print anything to standard out. Default false.
  --default-music-folder=DIR    Configure Subsonic to use this folder for music.  This option 
                                only has effect the first time Subsonic is started. Default '/var/music'
  --default-podcast-folder=DIR  Configure Subsonic to use this folder for Podcasts.  This option 
                                only has effect the first time Subsonic is started. Default '/var/music/Podcast'
  --default-playlist-folder=DIR Configure Subsonic to use this folder for playlist imports.  This option 
                                only has effect the first time Subsonic is started. Default '/var/playlists'
```
