class Srecord < Formula
  desc "Tools for manipulating EPROM load files"
  homepage "https://srecord.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/srecord/srecord/1.65/srecord-1.65.0-Source.tar.gz"
  sha256 "81c3d07cf15ce50441f43a82cefd0ac32767c535b5291bcc41bd2311d1337644"
  license all_of: ["GPL-3.0-or-later", "LGPL-3.0-or-later"]

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "c186ebd2fbae37d03b5971565ece7491391e9fec94f23fccfc2d3e55d32b4712"
    sha256 cellar: :any,                 arm64_ventura:  "1e62d98c025da186f7de2347a0339eba7f8028133503ff17d263b2c1c8f69fb7"
    sha256 cellar: :any,                 arm64_monterey: "ea6f0e094cd533b6e4a1edd1be1dca4ccfb1386203fbde1e50d9868cd6145793"
    sha256 cellar: :any,                 arm64_big_sur:  "2531dde4b69ae50e0cb15b498b2729862e64d00b98be831e581989d9e907f36a"
    sha256 cellar: :any,                 sonoma:         "7eeebc269caf282c9e0b0b77d25209e0b6bd32cf2b632a499c2813aedb9ac133"
    sha256 cellar: :any,                 ventura:        "979ba3f127c770c9ccc53559a8605683c89301ad1c031e854eeefad3a59ca245"
    sha256 cellar: :any,                 monterey:       "00588bcdaa60466ebedf0f60caec0c94c21447640b6df81c0dac9b83e9f63057"
    sha256 cellar: :any,                 big_sur:        "5c5129ae228ef644b5ed2a26516295feabd198aea270eab03c5c6d3e418980b1"
    sha256 cellar: :any,                 catalina:       "cc4e1e89835954876853f5f7bcccbfd172adbb5651c1f2790ea3da10e4347845"
    sha256 cellar: :any,                 mojave:         "6b3b825b501d1ea1635d107fb62021dde713f6da375f53f1a1fdcb59070df63a"
    sha256 cellar: :any,                 high_sierra:    "f6341ba9022e6cbc057c519fcdc7c7518247c850025777b80d2463341315d88c"
    sha256 cellar: :any,                 sierra:         "0601896fc392a13f7ef861fc3840fadfc7ddc7313763c1d374555129f4301c0d"
    sha256 cellar: :any,                 el_capitan:     "6a0df3e5fb40699d9b1198562b3b3a4e1745c3a0d12923c461246b7784b8324c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "2ccca42765c5c335dd26b2be5ad0a30b95d279e59958c89950d8cdbb5321816f"
  end

  # depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "libtool" => :build
  # depends_on "doxygen" => :build
  depends_on "libgcrypt"

  patch :DATA
  # on_sonoma :or_newer do
  #   depends_on "ghostscript" => :build # for ps2pdf
  # end

  # on_ventura :or_newer do
  #   depends_on "groff" => :build
  # end

  # on_linux do
  #   depends_on "ghostscript" => :build # for ps2pdf
  #   depends_on "groff" => :build
  # end

  # Use macOS's pstopdf
  # patch do
  #   on_sonoma :or_older do
  #     url "https://raw.githubusercontent.com/Homebrew/formula-patches/85fa66a9/srecord/1.64.patch"
  #     sha256 "140e032d0ffe921c94b19145e5904538233423ab7dc03a9c3c90bf434de4dd03"
  #   end
  # end

  def install
    # system "./configure", *std_configure_args, "LIBTOOL=glibtool"
    # system "make", "install"
    system "cmake", "-S", ".", "-B", "build",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    rm lib/'libgcrypt.20.dylib'
    rm lib/'libgpg-error.0.dylib'
    rm lib/'libintl.8.dylib'
  end

  test do
    (testpath/"test.srec").write <<~EOS
      S012000068656C6C6F5F737265632E73726563F2
      S1130000303132333435363738396162636465668A
      S11300104142434445464748494A4B4C4D4E4F5054
      S10C002041414141424242420ABD
      S9030000FC
    EOS

    expected = <<~EOS
      Format: Motorola S-Record
      Header: "hello_srec.srec"
      Execution Start Address: 00000000
      Data:   0000 - 0028
    EOS

    output = shell_output("#{bin}/srec_info #{testpath}/test.srec")
    assert_equal expected, output

    assert_match version.major_minor.to_s, shell_output("#{bin}/srec_info --version")
  end
end
__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index ea7f41e6..e4467982 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -29,11 +29,11 @@ include(InstallRequiredSystemLibraries)
 # Support standard install locations
 include(GNUInstallDirs)
 
-# FHS compliant paths for Linux installation
-if(NOT WIN32 AND CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
-#  set(CMAKE_INSTALL_PREFIX "/opt/${PROJECT_NAME}")
-  set(CMAKE_INSTALL_PREFIX "/usr")
-endif()
+# # FHS compliant paths for Linux installation
+# if(NOT WIN32 AND CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
+# #  set(CMAKE_INSTALL_PREFIX "/opt/${PROJECT_NAME}")
+#   set(CMAKE_INSTALL_PREFIX "/usr")
+# endif()
 
 # Pull in the rest of the pieces
 list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/etc")
@@ -55,7 +55,7 @@ enable_testing()
 add_subdirectory(test)
 
 # Documentation & Man Pages
-add_subdirectory(doc)
+# add_subdirectory(doc)
 
 # Package SRecord
 include(CPack)
diff --git a/etc/configure.cmake b/etc/configure.cmake
index 343a70a2..955fafc1 100644
--- a/etc/configure.cmake
+++ b/etc/configure.cmake
@@ -104,7 +104,7 @@ option(_TANDEM_SOURCE ON)
 option(__EXTENSIONS__ ON)
 
 # Doxygen configuration
-find_package(Doxygen REQUIRED doxygen dot)
+find_package(Doxygen REQUIRED doxygen)
 
 set(DOXYGEN_DOT_GRAPH_MAX_NODES 150)
 set(DOXYGEN_ALPHABETICAL_INDEX NO)
