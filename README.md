Shanocast is a Google Chromecast receiver which works with the Google Chrome browser. Demo:



https://github.com/rgerganov/shanocast/assets/271616/51886018-d6be-4d56-beb7-de1c6ad7e284



# Usage

Shanocast runs on Linux and is available as docker image:

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

# Building

Build [Openscreen](https://chromium.googlesource.com/openscreen/) (commit 2a4dbe65) with this [patch](shanocast.patch)

# How it works

Shanocast is based on [Openscreen](https://chromium.googlesource.com/openscreen/) which is an open-source implementation of the Google Cast protocol.
The device authentication is performed with precomputed signatures taken from AirReceiver.
You can find more information in this [blog post](https://xakcop.com/post/shanocast/).

# What does "shano" mean?

Shano (шано) is a Bulgarian slang word meaning shady or illegal.
