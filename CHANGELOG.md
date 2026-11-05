# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.0.0] - 2026-11-05

### Changed

- **Breaking:** the bfren platform overlay is updated to `bfren/alpine` 4.0.0 - see the
  [Alpine changelog](https://github.com/bfren/docker-alpine/blob/main/CHANGELOG.md). This includes a security fix:
  the environment store `/etc/bf/env.d` is no longer writable by every user, so `bf env set` must now run as root.
- The install stage now uses `quay.io/bfren-bin/debian` instead of `debian` from Docker Hub.
- Images are built and published by the shared `bfren/docker` build workflow (`build.yml`), replacing the separate
  `dev.yml` and `publish.yml` workflows.
- `bf clean` comes from the Alpine overlay instead of a Debian copy - its default cache directories (the apt lists and
  man pages) are now `bf pkg caches`.
- BusyBox applets are installed as symlinks instead of hard links, so they cannot be split from `/bin/busybox` when
  layers are copied or cached.

[6.0.0]: https://github.com/bfren/docker-debian/compare/v5.4.3...v6.0.0
