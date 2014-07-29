# @return True if chef path exist, False otherwise
function is_chef_installed { Test-Path /opscode/chef }

# @param $version the requested version of omnibus package
# @return True if omnibus needs to be installed, False otherwise
function should_update_chef($version) {
  if (-Not (is_chef_installed)) { return $true }

  try {
    $chef_version=(chef-solo -v).split(" ",2)[1]
  } catch [Exception] {
    $chef_version = ""
  }

  switch ($version) {
    { "true", $chef_version -contains $_ } { return $false }
    "latest" { return $true }
    default { return $true }
  }
}
# @param $chef_url The url where we will download chef
# @param $chef_msi Temporal MSI path
function download_chef($chef_url, $chef_msi) {
  (New-Object System.Net.WebClient).DownloadFile($chef_url, $chef_msi)
}

# function to install chef with sort of a nice progress bar
function install_chef {
  $proc_msi = Start-Process -FilePath 'msiexec.exe' -ArgumentList "/qn /i $chef_msi" -Passthru

  Write-Host -NoNewline "       [MSI] ["
  while (-Not $proc_msi.HasExited ) {
    Write-Host -NoNewline "#"
    Start-Sleep 2
  }
  Write-Host "]"
  rm -r $chef_msi
  Write-Host "Completed!\n"
}