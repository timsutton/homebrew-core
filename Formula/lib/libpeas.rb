class Libpeas < Formula
  desc "GObject plugin library"
  homepage "https://wiki.gnome.org/Projects/Libpeas"
  url "https://download.gnome.org/sources/libpeas/2.0/libpeas-2.0.1.tar.xz"
  sha256 "9ddc1d51f38663da4df52163051b7b2cea3a242cfaee9f5a7e140f0784c8aa77"
  license "LGPL-2.1-or-later"
  revision 1

  bottle do
    sha256 arm64_sonoma:   "249a30363c03546d15f68df7d8c3f0fe102effb6bac4b5ee3af6c1c57266eef5"
    sha256 arm64_ventura:  "6665b8a64464d0af0bc1a4bfb7f12e8437a163dc76d6f85c0dde4e25e2a35ccd"
    sha256 arm64_monterey: "33937a96502980298f719024ce5b4ab328e491fc2aca16a1ca65632360e31591"
    sha256 sonoma:         "625a76fc14d1ded3604b981c1a5464dd5173943b4798292dbf288730863f551a"
    sha256 ventura:        "0aa535e04f1759c3e6b8de5ca7caf178437149643481e1a2d24ee13b23993ce8"
    sha256 monterey:       "1d2456328df18f6ab771a2aa3f866078f73cd2be07c07b246baae5c05c773488"
    sha256 x86_64_linux:   "baa8d94412cd5d63a202de7a2935cfc8aba6879563077f676b59655e2d42bb5a"
  end

  depends_on "cmake" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "gjs"
  depends_on "glib"
  depends_on "gobject-introspection"
  depends_on "gtk+3"
  depends_on "pygobject3"
  depends_on "python@3.12"
  # need distutils but maybe only for build? it's due to python scripts as part of gobject-introspection
  # tasks
  depends_on "python-setuptools" => :build

  # resource "setuptools" do
  #   url "https://files.pythonhosted.org/packages/fc/c9/b146ca195403e0182a374e0ea4dbc69136bad3cd55bc293df496d625d0f7/setuptools-69.0.3.tar.gz"
  #   sha256 "be1af57fc409f93647f2e8e4573a142ed38724b8cdd389706a867bb4efcf1e78"
  # end

  def install
    pyver = Language::Python.major_minor_version "python3.12"
    # Help pkg-config find python as we only provide `python3-embed` for aliased python formula
    inreplace "meson.build", "'python3-embed'", "'python-#{pyver}-embed'"

    args = %w[
      -Dpython3=true
      -Dintrospection=true
      -Dvapi=true
      -Dlua51=false
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libpeas/peas.h>

      int main(int argc, char *argv[]) {
        PeasObjectModule *mod = peas_object_module_new("test", "test", FALSE);
        return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gobject_introspection = Formula["gobject-introspection"]
    libffi = Formula["libffi"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gobject_introspection.opt_include}/gobject-introspection-1.0
      -I#{include}/libpeas-1.0
      -I#{libffi.opt_lib}/libffi-3.0.13/include
      -D_REENTRANT
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gobject_introspection.opt_lib}
      -L#{lib}
      -lgio-2.0
      -lgirepository-1.0
      -lglib-2.0
      -lgmodule-2.0
      -lgobject-2.0
      -lpeas-1.0
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
