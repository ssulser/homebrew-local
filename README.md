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

### VBISAM runtime loading on macOS

GnuCOBOL 4 loads the underlying ISAM implementation dynamically. Because of this, VBISAM currently does not work out of the box on macOS when installed through Homebrew.

Inspecting `libcob.dylib` with:

```bash
otool -L "$(brew --prefix gnucobol-svn)/lib/libcob.dylib"
```

shows that `libcob` is not directly linked against the VBISAM library:

```text
libcob.dylib:
    /opt/homebrew/opt/gnucobol-svn/lib/libcob.8.dylib
    /opt/homebrew/opt/gmp/lib/libgmp.10.dylib
    /opt/homebrew/opt/readline/lib/libreadline.8.dylib
    /opt/homebrew/opt/gettext/lib/libintl.8.dylib
    /usr/lib/libiconv.2.dylib
    /opt/homebrew/opt/libxml2/lib/libxml2.16.dylib
    /opt/homebrew/opt/json-c/lib/libjson-c.5.dylib
    /opt/homebrew/opt/ncurses/lib/libncursesw.6.dylib
    /opt/homebrew/opt/ncurses/lib/libpanelw.6.dylib
    /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
    /System/Library/Frameworks/CoreServices.framework/Versions/A/CoreServices
    /usr/lib/libSystem.B.dylib
```

Instead, GnuCOBOL builds a separate `libcobvb.dylib` module which acts as the interface between `libcob` and VBISAM.

This can be verified with:

```bash
otool -L "$(brew --prefix gnucobol-svn)/lib/libcobvb.dylib"
```

which shows, among other dependencies:

```text
libcobvb.dylib:
    /opt/homebrew/opt/gnucobol-svn/lib/libcobvb.1.dylib
    /opt/homebrew/Cellar/gnucobol-svn/HEAD-5690/lib/libcob.8.dylib
    /opt/homebrew/opt/vbisam/lib/libvbisam.1.dylib
    /opt/homebrew/opt/ncurses/lib/libpanelw.6.dylib
    /usr/lib/libSystem.B.dylib
```

The important part is:

```text
/opt/homebrew/opt/vbisam/lib/libvbisam.1.dylib
```

Thus, the runtime dependency chain is effectively:

```text
libcob.dylib
      |
      |  dynamically loads
      v
libcobvb.dylib
      |
      |  linked against
      v
libvbisam.1.dylib
```

The current problem on macOS is that `libcob` attempts to dynamically load the module simply as:

```text
libcobvb.dylib
```

macOS does not automatically search the Homebrew GnuCOBOL library directory for this file. This results in an error such as:

```text
libcob: error: I/O routine VB-ISAM cannot be loaded:
dlopen(libcobvb.dylib, ...): no such file

libcob: error: ERROR I/O routine VBISAM is not present
```

#### Temporary workaround

Until the GnuCOBOL `libcob` source or its macOS library loading mechanism is adjusted, the GnuCOBOL library directory can be added to the dynamic loader search path:

```bash
DYLD_LIBRARY_PATH="$(brew --prefix gnucobol-svn)/lib" ./seq2idx
```

Alternatively, for the current shell:

```bash
export DYLD_LIBRARY_PATH="$(brew --prefix gnucobol-svn)/lib"
```

Programs using VBISAM can then be started normally.

This is currently intended as a temporary workaround. The preferred long-term solution is to adjust the GnuCOBOL runtime so that `libcobvb.dylib` can be located correctly on macOS without requiring `DYLD_LIBRARY_PATH`.

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

