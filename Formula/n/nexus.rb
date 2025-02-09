class Nexus < Formula
  desc "Repository manager for binary software components"
  homepage "https://www.sonatype.org/"
  url "https://github.com/sonatype/nexus-public/archive/refs/tags/release-3.77.1-01.tar.gz"
  sha256 "dd31a34ffed2d50aa703551113847b9abd7c015bba2f6d09d46f176a25d5ab5c"
  license "EPL-1.0"

  # As of writing, upstream is publishing both v2 and v3 releases. The "latest"
  # release on GitHub isn't reliable, as it can point to a release from either
  # one of these major versions depending on which was published most recently.
  livecheck do
    url :stable
    regex(/^(?:release[._-])?v?(\d+(?:[.-]\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, sonoma:       "1ef405d468f02b4d97e3e61d83d36341e7550642ac097bdfba458f515ad04e78"
    sha256 cellar: :any_skip_relocation, ventura:      "9114db0415c4582f0d1e97e8d7cb8758a1bd2d8094222eae33119f189a3dc85d"
    sha256 cellar: :any_skip_relocation, monterey:     "2d4e904050b210d103b36b47aaed37dcef075aa24b3713d54f040203308cf0e3"
    sha256 cellar: :any_skip_relocation, big_sur:      "ebcc0f030b0c84158344636dc0884d511ad386df587d92725f251725066c7151"
    sha256 cellar: :any_skip_relocation, catalina:     "abc68c0f85091cfd502bf0d4d8b87be1281e63a2350dcaf24b4a407317b14d35"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "dcbe0eea411e6b44a8a86d0ee9ede0b8a1ba15aaeef69cecfb0185b9629f1ac6"
  end

  depends_on "maven" => :build
  depends_on "yarn" => :build
  depends_on "openjdk@17"

  uses_from_macos "unzip" => :build

  def install
    ENV["JAVA_HOME"] = Formula["openjdk@17"].opt_prefix

    # HACK: should have a better way to get the groovy-eclipse-batch dependency
    # https://github.com/sonatype/nexus-public/issues/504 and https://github.com/sonatype/nexus-public/issues/525
    inreplace "pom.xml", "3.0.13-02", "3.0.8-01"

    # TODO: npm dependencies also can't install properly: https://github.com/sonatype/nexus-public/issues/417

    system "mvn", "install", "-DskipTests"
    system "unzip", "-o", "-d", "target", "assemblies/nexus-base-template/target/nexus-base-template-#{version}.zip"

    rm(Dir["target/nexus-base-template-#{version}/bin/*.bat"])
    rm_r("target/nexus-base-template-#{version}/bin/contrib")
    libexec.install Dir["target/nexus-base-template-#{version}/*"]

    env = {
      JAVA_HOME:  Formula["openjdk@17"].opt_prefix,
      KARAF_DATA: "${NEXUS_KARAF_DATA:-#{var}/nexus}",
      KARAF_LOG:  "#{var}/log/nexus",
      KARAF_ETC:  "#{etc}/nexus",
    }

    (bin/"nexus").write_env_script libexec/"bin/nexus", env
  end

  def post_install
    mkdir_p "#{var}/log/nexus" unless (var/"log/nexus").exist?
    mkdir_p "#{var}/nexus" unless (var/"nexus").exist?
    mkdir "#{etc}/nexus" unless (etc/"nexus").exist?
  end

  service do
    run [opt_bin/"nexus", "start"]
  end

  test do
    mkdir "data"
    fork do
      ENV["NEXUS_KARAF_DATA"] = testpath/"data"
      exec bin/"nexus", "server"
    end
    sleep 100
    assert_match "<title>Nexus Repository Manager</title>", shell_output("curl --silent --fail http://localhost:8081")
  end
end
