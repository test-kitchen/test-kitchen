$ErrorActionPreference = "Stop"

. { iwr -useb https://omnitruck.cinc.sh/install.ps1 } | iex
install -project cinc-workstation -version 26

& "C:\cinc-project\cinc-workstation\embedded\bin\gem.bat" install chef-cli `
  -v 6.1.30 `
  --clear-sources `
  --source https://rubygems.cinc.sh `
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
"C:\cinc-project\cinc-workstation\bin" | Out-File -FilePath $env:GITHUB_PATH -Append
