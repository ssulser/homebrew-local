class Esqloc < Formula
  desc "Embedded SQL preprocessor for GnuCOBOL using ODBC"
  homepage "https://sourceforge.net/p/gnucobol/contrib/HEAD/tree/trunk/esql/"
  license "GPL-3.0-or-later"

  head "https://svn.code.sf.net/p/gnucobol/contrib/trunk/esql",
       using: :svn

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "subversion" => :build

  depends_on "unixodbc"
  depends_on "ssulser/local/gnucobol-svn"

  def install
    libtool = Formula["libtool"]

    # Use Homebrew GNU libtool consistently.
    ENV.prepend_path "PATH", libtool.opt_bin
    ENV["LIBTOOL"] = libtool.opt_bin/"glibtool"
    ENV["LIBTOOLIZE"] = libtool.opt_bin/"glibtoolize"

    # esqlOC is C++, therefore ensure a C++ compiler is used.
    ENV["CXX"] = ENV.cxx

    system libtool.opt_bin/"glibtoolize",
           "--force",
           "--copy"

    system "autoreconf", "-fi"

    system "./configure",
           "--prefix=#{prefix}",
           "--disable-dependency-tracking"

    system "make"
    system "make", "install"
  end

  test do
    assert_predicate bin/"esqlOC", :executable?
  end
end
