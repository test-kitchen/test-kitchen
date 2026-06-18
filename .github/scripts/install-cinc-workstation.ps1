$ErrorActionPreference = "Stop"

. { iwr -useb https://omnitruck.cinc.sh/install.ps1 } | iex
install -project cinc-workstation -version 26

$embeddedBinDir = "C:\cinc-project\cinc-workstation\embedded\bin"

if (!(Test-Path (Join-Path $embeddedBinDir "cinc-cli.bat"))) {
  $embeddedGemDir = & (Join-Path $embeddedBinDir "ruby.exe") -e "puts Gem.default_dir"
  & (Join-Path $embeddedBinDir "gem.bat") install chef-cli `
    -v 6.1.30 `
    --install-dir $embeddedGemDir `
    --bindir $embeddedBinDir `
    --no-user-install `
    --clear-sources `
    --source https://rubygems.cinc.sh `
    --source https://rubygems.org `
    --no-document
}

$wrapperDir = Join-Path $env:RUNNER_TEMP "cinc-workstation-bin"
New-Item -ItemType Directory -Force -Path $wrapperDir | Out-Null

$wrapper = @'
@echo off
for /f "tokens=1 delims==" %%v in ('set BUNDLE 2^>NUL') do set %%v=
for /f "tokens=1 delims==" %%v in ('set BUNDLER 2^>NUL') do set %%v=
set RUBYGEMS_GEMDEPS=
set RUBYOPT=
set RUBYLIB=
set GEM_HOME=
set GEM_PATH=
if exist "C:\cinc-project\cinc-workstation\embedded\bin\cinc-cli.bat" (
  "C:\cinc-project\cinc-workstation\embedded\bin\cinc-cli.bat" %*
  exit /b %ERRORLEVEL%
)
if exist "C:\cinc-project\cinc-workstation\embedded\bin\chef-cli.bat" (
  "C:\cinc-project\cinc-workstation\embedded\bin\chef-cli.bat" %*
  exit /b %ERRORLEVEL%
)
if exist "C:\cinc-project\cinc-workstation\embedded\bin\chef.bat" (
  "C:\cinc-project\cinc-workstation\embedded\bin\chef.bat" %*
  exit /b %ERRORLEVEL%
)
echo Could not find a Cinc Workstation Policyfile CLI 1>&2
exit /b 127
'@

Set-Content -Path (Join-Path $wrapperDir "cinc-cli.cmd") -Value $wrapper -Encoding ASCII
$wrapperDir | Out-File -FilePath $env:GITHUB_PATH -Append
