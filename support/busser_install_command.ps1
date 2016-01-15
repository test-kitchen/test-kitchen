if ((& "$ruby" "$gem" list busser -i) -ne "true") {
  Write-Host "-----> Installing Busser ($version)`n"
  & "$ruby" "$gem" install $gem_install_args.Split() 2>&1
} else {
  Write-Host "-----> Busser installation detected ($version)`n"
}

if (-Not (Test-Path "$busser")) {
  $gem_bindir = & "$ruby" -rrubygems -e "puts Gem.bindir.dup.gsub('/', '\\')"
  & "$ruby" "$gem_bindir\busser" setup --type bat 2>&1
}

Write-Host "       Installing Busser plugins: $plugins`n"
& "$busser" plugin install $plugins.Split() 2>&1
