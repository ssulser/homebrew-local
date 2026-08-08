class GnucobolSvn < Formula
  desc "GnuCOBOL compiler built from the current SVN trunk"
  homepage "https://gnucobol.sourceforge.io/"
  license "GPL-3.0-or-later"

  head "https://svn.code.sf.net/p/gnucobol/code/trunk", using: :svn

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "help2man" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "subversion" => :build
  depends_on "texinfo" => :build

  depends_on "gettext"
  depends_on "gmp"
  depends_on "json-c"
  depends_on "libxml2"
  depends_on "ncurses"
  depends_on "ssulser/local/vbisam"

  def install
    libtool = Formula["libtool"]
    gettext = Formula["gettext"]
    ncurses = Formula["ncurses"]

    # Force a consistent Homebrew GNU libtool toolchain.
    ENV.prepend_path "PATH", libtool.opt_bin
    ENV["LIBTOOL"] = libtool.opt_bin/"glibtool"
    ENV["LIBTOOLIZE"] = libtool.opt_bin/"glibtoolize"

    # Make Homebrew gettext tools available during regeneration
    # of the autotools/gettext infrastructure.
    ENV.prepend_path "PATH", gettext.opt_bin

    # Recreate libtool files using the same libtool version that
    # will later be used by the build.
    system libtool.opt_bin/"glibtoolize",
           "--force",
           "--copy"

    # Recreate gettext infrastructure so po/Makefile.in.in and
    # the gettext autoconf macros use the same gettext version.
    system gettext.opt_bin/"gettextize",
           "--force",
           "--copy",
           "--no-changelog"

    # Generate configure and the remaining autotools files.
    system "autoreconf", "-fi"

    # Current GnuCOBOL SVN sources do not compile cleanly as C23.
    # C17 retains compatibility with the older unspecified-argument
    # function declarations still present in the source tree.
    ENV["CFLAGS"] = "-O2 -std=gnu17"

    # Use Homebrew ncurses explicitly.
    ENV.append "CPPFLAGS", "-I#{ncurses.opt_include}"
    ENV.append "LDFLAGS", "-L#{ncurses.opt_lib}"

    # GnuCOBOL screen I/O uses functions from the ncurses panel library.
    ENV.append "LIBS", "-lpanel"

    system "./configure",
           "--prefix=#{prefix}",
           "--disable-dependency-tracking",
           "--with-vbisam"

    system "make"
    system "make", "install"
  end

  test do
    (testpath/"hello.cob").write <<~COBOL
             IDENTIFICATION DIVISION.
             PROGRAM-ID. HELLO.
             PROCEDURE DIVISION.
                 DISPLAY "Hello from GnuCOBOL".
                 STOP RUN.
    COBOL

    system bin/"cobc", "-x", "hello.cob"
    assert_match "Hello from GnuCOBOL", shell_output("./hello")
  end
end
