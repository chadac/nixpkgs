{ lib
, nix-update-script
, rustPlatform
, fetchFromGitHub
, installShellFiles
, stdenv
, coreutils
, bash
, pkg-config
, openssl
, direnv
, Security
, SystemConfiguration
, mise
, testers
}:

rustPlatform.buildRustPackage rec {
  pname = "mise";
  version = "2024.1.0";

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "mise";
    rev = "v${version}";
    hash = "sha256-v8GQzDMyCGfFEsxG0H7myGTWDX+O8S8C9L0KJ267r9U=";
  };

  cargoHash = "sha256-mwV12QA4Fe+ueu8Z6GU0f0siETQqWUMc2eUEURT2Lok=";

  nativeBuildInputs = [ installShellFiles pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security SystemConfiguration ];

  postPatch = ''
    patchShebangs --build ./test/data/plugins/**/bin/* ./src/fake_asdf.rs ./src/cli/reshim.rs

    substituteInPlace ./src/env_diff.rs \
      --replace '"bash"' '"${bash}/bin/bash"'

    substituteInPlace ./src/cli/direnv/exec.rs \
      --replace '"env"' '"${coreutils}/bin/env"' \
      --replace 'cmd!("direnv"' 'cmd!("${direnv}/bin/direnv"'
  '';

  checkFlags = [
    # Requires .git directory to be present
    "--skip=cli::plugins::ls::tests::test_plugin_list_urls"
  ];
  cargoTestFlags = [ "--all-features" "--bin mise" ];
  # some tests access the same folders, don't test in parallel to avoid race conditions
  dontUseCargoParallelTests = true;

  postInstall = ''
    installManPage ./man/man1/mise.1

    installShellCompletion \
      --bash ./completions/mise.bash \
      --fish ./completions/mise.fish \
      --zsh ./completions/_mise
  '';

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = mise; };
  };

  meta = {
    homepage = "https://github.com/jdx/mise";
    description = "dev tools, env vars, task runner";
    changelog = "https://github.com/jdx/mise/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ konradmalik ];
    mainProgram = "mise";
  };
}
