class CaptainsLog < Formula
  desc "Pirate-themed macOS menu bar app that gamifies dev velocity"
  homepage "https://github.com/JungHoonGhae/captains-log"
  url "https://github.com/JungHoonGhae/captains-log/releases/download/v0.1.0/captains-log-macos.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on :macos

  def install
    bin.install "CaptainsLog"
  end

  def caveats
    <<~EOS
      Captain's Log is a menu bar app.
      Launch it from the terminal:
        CaptainsLog

      Or add it to Login Items for auto-start.
    EOS
  end

  test do
    assert_predicate bin/"CaptainsLog", :exist?
  end
end
