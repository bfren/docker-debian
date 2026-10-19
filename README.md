# Debian

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-debian) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fdebian) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fdebian) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-debian/dev.yml?branch=main)

[Docker Hub](https://hub.docker.com/r/bfren/debian) - [Quay.io](https://quay.io/repository/bfren/debian) - [bfren ecosystem](https://github.com/bfren/docker)

## Introduction

This is the [bfren ecosystem](https://github.com/bfren/docker) base image for software that needs [Debian](https://www.debian.org) - glibc, or packages that are not available (or not reliable) on Alpine.

It is the same platform as [Alpine](https://github.com/bfren/docker-alpine) - the Alpine image's overlay is copied in when this image is built - so everything you know about the `bf` module, `bf-install`, the saved environment and `/test` works identically. This page only covers what is different on Debian.

It is Debian (slim) with:

* [Nushell](https://www.nushell.sh) and the `bf` module, exactly as in the Alpine image
* [Busybox](https://busybox.net), so the same small utilities (`ln`, `wget`, `adduser`, …) behave the same on both
* `apt` configured not to install recommended or suggested packages, to keep images small
* `ca-certificates` and `figlet` pre-installed

Use it as the `FROM` line for images that run a single command or tool. For images that run a long-lived service, use [Debian + S6](https://github.com/bfren/docker-debian-s6) instead. If you don't need Debian, prefer [Alpine](https://github.com/bfren/docker-alpine) - it is smaller.

## Quickstart

```plain
my-image/
├── Dockerfile
└── overlay/
    └── tmp/
        └── install
```

`Dockerfile`:

```dockerfile
FROM quay.io/bfren/debian:debian13

ARG BF_IMAGE=my-image
ARG BF_VERSION=1.0.0

COPY ./overlay /
RUN bf-install
```

`overlay/tmp/install` - your installation script, run by `bf-install`:

```nu
#!/usr/bin/nu

use bf

# Install my-image
def main [] {
    bf pkg install [curl jq]
    bf write ok "my-image installed."
}
```

Build it and open a shell:

```sh
docker build -t my-image . && docker run --rm -it my-image nu
```

Inside the container, `bf image` shows the image name and version.

## Features

* 🌀 Debian 12 and 13 - choose with the image tag
* 🐚 Nushell, with the `bf` module loaded in every shell
* 🧱 `bf-install` - one standard build step for every image
* 🌍 Container environment saved at start-up and available to every script
* 🛠️ Helper executables (`bf-env`, `bf-write`, `bf-wget`, …) for shell scripts
* 📝 [esh](https://github.com/jirutka/esh) for generating files from templates
* 📦 `bf pkg` works with `apt`, so your install scripts read the same as on Alpine
* 🕐 Timezone set to `Europe/London`
* 🧪 Built-in test runner that checks its tests really execute
* 🖥️ Built for `linux/amd64`, `linux/arm64` and `linux/arm/v7`

## Tags

Images are published to Docker Hub (`bfren/debian`) and Quay.io (`quay.io/bfren/debian`).

| Tag                           | Example                | Use when                                              |
| ----------------------------- | ---------------------- | ----------------------------------------------------- |
| `debianX`                     | `debian13`             | You want the latest image for a Debian version        |
| `debianX-MAJOR`               | `debian13-5`           | You want updates, but not breaking changes            |
| `debianX-MINOR`               | `debian13-5.4`         | You want fixes only - **recommended for building on** |
| `debianX-VERSION`             | `debian13-5.4.0`       | You want to pin this image exactly                    |
| `debianX.Y`                   | `debian13.7`           | You want an exact Debian point release                |
| `debianX.Y-VERSION`           | `debian13.7-5.4.0`     | You want to pin both                                  |
| `NAME`, `NAME-MAJOR` …        | `trixie`, `trixie-5.4` | As above, using the Debian release name               |
| `latest`, `5`, `5.4`, `5.4.0` |                        | As above, on the newest Debian version                |

| Debian        | Security support ends | Community LTS ends |
| ------------- | --------------------- | ------------------ |
| 13 (trixie)   | 2028-08-09            | 2030-06-30         |
| 12 (bookworm) | ended 2026-07-11      | 2028-06-30         |

Debian 12 has moved to Debian's volunteer-run LTS. Use Debian 13 for anything new. [Source: endoflife.date](https://endoflife.date/debian)

## Configuration

### Environment Variables

| Variable   | Values   | Description                             | Default |
| ---------- | -------- | --------------------------------------- | ------- |
| `BF_DEBUG` | `0`, `1` | Show detailed output from `bf` scripts. | `0`     |

### Build Arguments

| Argument        | Description                                                                   |
| --------------- | ----------------------------------------------------------------------------- |
| `BF_IMAGE`      | **Required by `bf-install`.** The image name, saved to `/etc/bf/IMAGE`.       |
| `BF_VERSION`    | **Required by `bf-install`.** The image version, saved to `/etc/bf/VERSION`.  |
| `BF_PUBLISHING` | Set to `1` for release builds - removes the test files and preinstall script. |

## How It Works

Building, starting, the saved environment and the `bf` module work exactly as they do in the [Alpine image](https://github.com/bfren/docker-alpine#how-it-works) - read that for the full guide. The differences are below.

### What is different from Alpine

| Area                 | Alpine                             | Debian                                                                                                                  |
| -------------------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Package manager      | `apk`                              | `apt-get` - `bf pkg install`, `remove` and `upgrade` run `apt-get update` first, then the action, non-interactively     |
| Recommended packages | n/a                                | Not installed (`Install-Recommends` and `Install-Suggests` are `0`)                                                     |
| C library            | musl                               | glibc                                                                                                                   |
| Utilities            | Alpine's own Busybox               | Busybox replaces the Debian equivalents (except `dpkg`, `grep`, `find` and a few others that Debian's packages rely on) |
| `bf clean`           | Removes the `apk` cache            | Removes `/var/lib/apt/lists` and `/usr/share/man`                                                                       |
| `bf tz`              | Installs `tzdata`, then removes it | Uses the `tzdata` already in Debian                                                                                     |

Everything else - `bf env`, `bf write`, `bf fs`, `bf ch`, `bf esh`, `bf http`, `bf user`, `bf test` and the rest - is the same code, so scripts you write for one image work on the other apart from package names.

## Testing

`/test` runs the Nushell tests in `/etc/nu/scripts/tests`, as in Alpine. Tests are removed from published images, so run them on your own builds.

```sh
./test.sh        # builds the Debian 13 image and runs /test
./test.sh 12     # the same for Debian 12
```

## Troubleshooting

### Package not found

`bf pkg install` runs `apt-get update` each time, so a "not found" error usually means the package name is Debian's and not Alpine's (e.g. `libpq-dev`, not `postgresql-dev`; `build-essential`, not `build-base`).

### Setting `BF_TZ` does nothing

In this image the timezone is set when the image is built. Call `bf tz Europe/Paris` (for example) in your `/tmp/install`, or use [Debian + S6](https://github.com/bfren/docker-debian-s6), which applies `BF_TZ` every time the container starts.

### The container exits straight away

The image has no default command. Give it one, e.g. `docker run --rm -it bfren/debian nu`.

## FAQs

### Should I use Debian or Alpine?

Alpine, unless something you need requires glibc or a Debian package - it is smaller. Choose Debian for software that needs glibc, or that is only packaged or supported for Debian ([`bfren/mariadb`](https://github.com/bfren/docker-mariadb) offers both Alpine and Debian variants).

### Should I use this image or Debian + S6?

Use this one for images that run a single command - a CLI tool, a build step. Use [Debian + S6](https://github.com/bfren/docker-debian-s6) for long-running services, especially if they need scheduled tasks or start-up checks.

### Why does this repository contain so little?

The platform is shared. When this image is built, the [Alpine overlay](https://github.com/bfren/docker-alpine) is cloned at the version set in `generate-dockerfiles.sh` and copied in, then the Debian-specific files in this repository replace the ones that differ (`bf pkg`, `bf clean`, `bf tz`).

## Licence

> [MIT](https://mit.bfren.dev/2022)

## Copyright

> Copyright (c) 2022-2026 [bfren](https://bfren.dev) (unless otherwise stated)
