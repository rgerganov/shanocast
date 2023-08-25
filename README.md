Shanocast is a Google Chromecast receiver which works with the Google Chrome browser. Demo:



https://github.com/rgerganov/shanocast/assets/271616/51886018-d6be-4d56-beb7-de1c6ad7e284



# Usage

Shanocast runs only on Linux and is available as docker image:

```bash
$ docker pull rgerganov/shanocast
```

As Shanocast runs in a container, you need to enable access to your X11 server (use with caution, this has security implications):
```
$ xhost +
```

The container can be started like this, the last parameter specifies the network interface where the server runs:
```bash
$ docker run --network host --device /dev/snd --device /dev/dri -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix shanocast lo
```

Finally, start Google Chrome and Shanocast should be listed as available for casting.

