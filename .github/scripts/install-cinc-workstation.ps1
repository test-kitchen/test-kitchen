$ErrorActionPreference = "Stop"

. { iwr -useb https://omnitruck.cinc.sh/install.ps1 } | iex
install -project cinc-workstation -version 26

$embeddedGemDir = & "C:\cinc-project\cinc-workstation\embedded\bin\ruby.exe" -e "puts Gem.default_dir"
& "C:\cinc-project\cinc-workstation\embedded\bin\gem.bat" install chef-cli `
  -v 6.1.30 `
  --install-dir $embeddedGemDir `
  --bindir "C:\cinc-project\cinc-workstation\embedded\bin" `
  --no-user-install `
  --clear-sources `
  --source https://rubygems.cinc.sh `
  --source https://rubygems.org `
  --no-document

$wrapperDir = Join-Path $env:RUNNER_TEMP "cinc-workstation-bin"
New-Item -ItemType Directory -Force -Path $wrapperDir | Out-Null

$wrapper = @'
@echo off
set BUNDLE_BIN=
set BUNDLE_BIN_PATH=
set BUNDLE_GEMFILE=
set BUNDLE_PATH=
set BUNDLE_APP_CONFIG=
set BUNDLER_VERSION=
set BUNDLE_WITHOUT=
set RUBYGEMS_GEMDEPS=
set RUBYOPT=
set RUBYLIB=
set GEM_HOME=
set GEM_PATH=
"C:\cinc-project\cinc-workstation\bin\cinc-cli.bat" %*
'@

Set-Content -Path (Join-Path $wrapperDir "cinc-cli.cmd") -Value $wrapper -Encoding ASCII
$wrapperDir | Out-File -FilePath $env:GITHUB_PATH -Append
