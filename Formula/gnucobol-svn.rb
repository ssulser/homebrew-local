class GnucobolSvn < Formula
  desc "GnuCOBOL compiler built from the current SVN trunk"
  homepage "https://gnucobol.sourceforge.io/"
  license "GPL-3.0-or-later"

  head "https://svn.code.sf.net/p/gnucobol/code/trunk", using: :svn

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison" => :build
  depends_on "flex" => :build
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
    # Ensure bootstrap and build use the same Homebrew GNU libtool.
    ENV.prepend_path "PATH", Formula["libtool"].opt_bin
    ENV["LIBTOOL"] = Formula["libtool"].opt_bin/"glibtool"
    ENV["LIBTOOLIZE"] = Formula["libtool"].opt_bin/"glibtoolize"

    # Generate configure and the remaining Autotools infrastructure.
    system "build_aux/bootstrap"

    # Use Homebrew ncurses and explicitly link the panel library.
    ENV.append "CPPFLAGS", "-I#{Formula["ncurses"].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula["ncurses"].opt_lib}"
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
