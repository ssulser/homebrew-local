# Homebrew Local

Personal Homebrew tap for software and development tools not available in the standard Homebrew repositories.

## Installation

Add the tap:

```bash
brew tap ssulser/local
```

## Available Formulae

### VBISAM

VBISAM is an indexed sequential access method (ISAM) library that can be used as a file handler backend for GnuCOBOL.

The formula builds the current development version from:

`opensourcecobol/vbisam-osscons-patch`

It also applies a small compatibility fix to `libvbisam/ischeck.c` required by modern C compilers.

Install with:

```bash
brew install ssulser/local/vbisam --HEAD
```

### GnuCOBOL SVN

Builds GnuCOBOL directly from the current SourceForge SVN trunk.

The build process:

1. Checks out the current GnuCOBOL SVN trunk
2. Generates the build system
3. Configures GnuCOBOL with VBISAM support
4. Builds and installs GnuCOBOL using Homebrew

VBISAM from this tap is installed automatically as a dependency.

Install with:

```bash
brew install ssulser/local/gnucobol-svn --HEAD
```

Check the installation:

```bash
cobc --version
```

## Updating

Update Homebrew and the tap:

```bash
brew update
```

Rebuild the current GnuCOBOL SVN version:

```bash
brew reinstall ssulser/local/gnucobol-svn --HEAD
```

## Uninstalling

```bash
brew uninstall gnucobol-svn
brew uninstall vbisam
```

Remove the tap completely:

```bash
brew untap ssulser/local
```

## Notes

`gnucobol-svn` tracks the GnuCOBOL development trunk and should therefore be considered a development build rather than a stable release.

VBISAM is used as the indexed-file backend for this GnuCOBOL build.
