class Sqlc < Formula
  desc "Generate type safe Go from SQL"
  homepage "https://sqlc.dev/"
  url "https://github.com/sqlc-dev/sqlc/archive/v1.20.0.tar.gz"
  sha256 "65d1897709da9691ffad49211b2fa29ee86d10e0ab215f54fc80c5c3080e439c"
  license "MIT"
  head "https://github.com/sqlc-dev/sqlc.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "58c9279136fb24daa52555bb1c946c901ebba2ec4981a8cb94977e97d1aa8ce0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "3c3c757e9bdb4bdeee332c2cefa5890f46ac1bdb1143ff2a2d9a4e73f522d6d3"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "5e3d9135e95f85eab41fad52190619c059cfdf4db116dc1dd1a9b3680cd7e217"
    sha256 cellar: :any_skip_relocation, ventura:        "54bfab127cccccde6fb7359b481baf598d92abc1b522064ce33a8e9168ef2975"
    sha256 cellar: :any_skip_relocation, monterey:       "9d98d37f13bdac57fc5a18a9da4d3a8a43cda45808cd84053a865ed150fffe58"
    sha256 cellar: :any_skip_relocation, big_sur:        "a7a3716add0749bbd289dbcd943e256f4fb668400d5a61f1bddfe4e511597193"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "053a666a798b75a674051355d248de830a98e79936f5c14cc355e9371e6e6f85"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/sqlc"

    generate_completions_from_executable(bin/"sqlc", "completion")
  end

  test do
    (testpath/"sqlc.json").write <<~SQLC
      {
        "version": "1",
        "packages": [
          {
            "name": "db",
            "path": ".",
            "queries": "query.sql",
            "schema": "query.sql",
            "engine": "postgresql"
          }
        ]
      }
    SQLC

    (testpath/"query.sql").write <<~EOS
      CREATE TABLE foo (bar text);

      -- name: SelectFoo :many
      SELECT * FROM foo;
    EOS

    system bin/"sqlc", "generate"
    assert_predicate testpath/"db.go", :exist?
    assert_predicate testpath/"models.go", :exist?
    assert_match "// Code generated by sqlc. DO NOT EDIT.", File.read(testpath/"query.sql.go")
  end
end
