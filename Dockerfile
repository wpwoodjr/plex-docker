FROM plex:upgraded

RUN apt-get update && apt-get -y upgrade && apt-get -y install less htop nano

ARG slideshow_speed_ms
RUN test "$slideshow_speed_ms" = "default" \
|| sed -i -e "s/this.onSlideShowAdvance,5e3/this.onSlideShowAdvance,$slideshow_speed_ms/g" \
  /usr/lib/plexmediaserver/Resources/Plug-ins*/WebClient.bundle/Contents/Resources/js/chunk*.js
