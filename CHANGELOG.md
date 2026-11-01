# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.0.0] - Unreleased

### Changed

- **Breaking:** scripts now use [txiki.js](https://github.com/saghul/txiki.js) instead of Nushell - the bfren platform
  overlay is the txiki.js `bfren/alpine` (5.0.0), so install scripts are JavaScript (`/tmp/install.js`) and the `bf`
  module is imported with `import * as bf from "bf"`. See the
  [Alpine README](https://github.com/bfren/docker-alpine#how-it-works).
- `bf.pkg` and `bf.tz` are the only Debian-specific modules: `bf.clean()` now takes its default cache paths from
  `bf.pkg.CACHES`, so it is no longer replaced.

## [6.0.0] - Unreleased

### Changed

- **Breaking:** the bfren platform overlay is updated to `bfren/alpine` 4.0.0 - see the
  [Alpine changelog](https://github.com/bfren/docker-alpine/blob/main/CHANGELOG.md). This includes a security fix:
  the environment store `/etc/bf/env.d` is no longer writable by every user, so `bf env set` must now run as root.
- The install stage now uses `quay.io/bfren-bin/debian` instead of `debian` from Docker Hub.
- Images are built and published by the shared `bfren/docker` build workflow (`build.yml`), replacing the separate
  `dev.yml` and `publish.yml` workflows.

[7.0.0]: https://github.com/bfren/docker-debian/compare/v6.0.0...v7.0.0
[6.0.0]: https://github.com/bfren/docker-debian/compare/v5.4.3...v6.0.0
