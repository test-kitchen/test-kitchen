# @return True if chef path exist, False otherwise
function is_chef_installed { Test-Path /opscode/chef }

# @param $version the requested version of omnibus package
# @return True if omnibus needs to be installed, False otherwise
function should_update_chef($version) {
  if (-Not (is_chef_installed)) { return $true }

  try {
    $chef_version=(chef-solo -v).split(' ',2)[1]
  } catch [Exception] {
    $chef_version = ''
  }

  switch ($version) {
    { 'true', $chef_version -contains $_ } { return $false }
    'latest' { return $true }
    default { return $true }
  }
}

# @param $chef_url The url where we will download chef
# @param $chef_msi Temporal MSI path
function download_chef($chef_url, $chef_msi) {
  Write-Host -NoNewline "`r`tDownloading Chef..."
  (New-Object System.Net.WebClient).DownloadFile($chef_url, $chef_msi)
  Write-Host -NoNewline "`r`tDone!              "
}

# function to install chef with sort of a nice progress bar
function install_chef {
  $proc_msi = Start-Process -FilePath 'msiexec.exe' -ArgumentList "/qn /i $chef_msi" -Passthru
  $bar = ""
  while (-Not $proc_msi.HasExited ) {
    Write-Host -NoNewline "`r`t[MSI] [$bar"
    Start-Sleep 2
    $bar += "#"
  }
  rm -r $chef_msi
  Write-Host -NoNewline "`r`t[MSI] [$bar] Completed!\n"
}