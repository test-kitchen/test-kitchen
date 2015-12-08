Function Delete-AllDirs($dirs) {
  $dirs | ForEach-Object {
    if (Test-Path ($path = Unresolve-Path $_)) { Remove-Item $path -Recurse -Force }
  }
}

Delete-AllDirs $dirs
