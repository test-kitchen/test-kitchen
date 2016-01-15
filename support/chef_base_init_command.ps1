Function Delete-AllDirs($dirs) {
  $dirs | ForEach-Object {
    if (Test-Path ($path = Unresolve-Path $_)) { Remove-Item $path -Recurse -Force }
  }
}

Function Unresolve-Path($p) {
  if ($p -eq $null) { return $null }
  else { return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p) }
}

Function Make-RootPath($p) {
  $p = Unresolve-Path $p
  if (-Not (Test-Path $p)) { New-Item $p -ItemType directory | Out-Null }
}

Delete-AllDirs $dirs
Make-RootPath $root_path
