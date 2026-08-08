class Vbisam < Formula
  desc "VBISAM indexed sequential access method library"
  homepage "https://github.com/opensourcecobol/vbisam-osscons-patch"

  head "https://github.com/opensourcecobol/vbisam-osscons-patch.git",
       branch: "develop"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    inreplace "libvbisam/ischeck.c",
            "static int\nipreamble (ihandle)\n{",
            "static int\nipreamble (int ihandle)\n{"

    system "autoreconf", "-fi"

    system "./configure",
           "--prefix=#{prefix}",
           "--disable-dependency-tracking"

    system "make"
    system "make", "install"
  end

  test do
    assert_path include/"vbisam.h"
    assert_path lib/"libvbisam.dylib"
  end
end
