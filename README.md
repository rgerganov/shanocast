Shanocast is a Google Chromecast receiver which works with the Google Chrome browser. Demo:

https://github.com/rgerganov/shanocast/assets/271616/51886018-d6be-4d56-beb7-de1c6ad7e284

# Usage

Shanocast runs on Linux and is reproducible via a Nix Flake or Docker.

## Using Nix

Get Nix and enable flakes, for example via the DetSys Nix installer

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Or if you prefer a single 21M~ file, get a statically compiled Nix binary

```
curl -L https://hydra.nixos.org/job/nix/master/buildStatic.x86_64-linux/latest/download-by-type/file/binary-dist > nix
chmod +x ./nix
```

```bash
$ nix run .#shanocast lo
```

the final argument `lo` specifies the network interface where the cast_receiver runs.

## Using Docker

Shanocast can also be built and run using Docker. For detailed instructions, see the [Docker README](docker/README.md).

Basic usage:

```bash
# Build the Docker images
./docker/build-images.sh

# Run shanocast (will prompt for network interface)
./docker/run-shanocast.sh
```

Finally, start Google Chrome and Shanocast should be listed as available for casting.

# Building

## Using Nix or Docker

See the Usage section above for building with Nix or Docker.

## Manual Build

Build [Openscreen](https://chromium.googlesource.com/openscreen/) (commit 2a4dbe65) with this [patch](shanocast.patch)

# How it works

Shanocast is based on [Openscreen](https://chromium.googlesource.com/openscreen/) which is an open-source implementation of the Google Cast protocol.
The device authentication is performed with precomputed signatures taken from AirReceiver.
You can find more information in this [blog post](https://xakcop.com/post/shanocast/).

# What does "shano" mean?

Shano (шано) is a Bulgarian slang word meaning shady or illegal.
