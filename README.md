# Homebrew Local

Personal Homebrew tap for GnuCOBOL development tools on macOS.

The tap currently provides:

* **VBISAM** – indexed sequential file access library
* **GnuCOBOL SVN** – current GnuCOBOL development version built from the SourceForge SVN trunk
* **esqlOC** – Embedded SQL preprocessor for GnuCOBOL using ODBC

## Add the Tap

```bash
brew tap ssulser/local
```

---

## VBISAM

VBISAM provides an ISAM-compatible indexed file backend for GnuCOBOL.

The formula builds the development version from:

`opensourcecobol/vbisam-osscons-patch`

It also applies a small source compatibility fix in `libvbisam/ischeck.c` required by modern C compilers.

Install:

```bash
brew install ssulser/local/vbisam --HEAD
```

---

## GnuCOBOL SVN

Builds GnuCOBOL directly from the current SourceForge SVN trunk.

The formula automatically installs VBISAM from this tap and builds GnuCOBOL with:

```text
--with-vbisam
```

The build also contains the necessary compatibility adjustments for current macOS/Homebrew development tools, including Autotools, GNU libtool, gettext and C17.

Install:

```bash
brew install ssulser/local/gnucobol-svn --HEAD
```

Check the installation:

```bash
cobc --version
```

### Indexed file support

Verify the configured ISAM backend with:

```bash
cobc -info
```

GnuCOBOL should report VBISAM as the indexed file handler.

---

## esqlOC

esqlOC is an Embedded SQL preprocessor for GnuCOBOL.

It is built from the GnuCOBOL contrib SVN repository and uses ODBC for database access.

The formula automatically installs:

* GnuCOBOL SVN from this tap
* unixODBC
* required build tools

Install:

```bash
brew install ssulser/local/esqloc --HEAD
```

The resulting `esqlOC` executable can be checked with:

```bash
which esqlOC
```

ODBC configuration can be inspected with:

```bash
odbcinst -j
```

---

## Install Everything

The components can simply be installed through esqlOC:

```bash
brew install ssulser/local/esqloc --HEAD
```

Homebrew resolves the dependencies automatically:

```text
esqlOC
  |
  +-- GnuCOBOL SVN
  |     |
  |     +-- VBISAM
  |
  +-- unixODBC
```

---

## Updating

Update Homebrew and this tap:

```bash
brew update
```

Since these formulae track development repositories, rebuild a HEAD installation to get the current sources:

```bash
brew reinstall ssulser/local/vbisam --HEAD
brew reinstall ssulser/local/gnucobol-svn --HEAD
brew reinstall ssulser/local/esqloc --HEAD
```

---

## Uninstalling

```bash
brew uninstall esqloc
brew uninstall gnucobol-svn
brew uninstall vbisam
```

Remove the tap:

```bash
brew untap ssulser/local
```

---

## Notes

`gnucobol-svn` and `esqloc` are built directly from their current SVN development sources. They should therefore be considered development builds rather than fixed stable releases.

The formulae are primarily intended for macOS systems using Homebrew.

