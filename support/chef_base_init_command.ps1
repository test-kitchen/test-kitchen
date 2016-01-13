Function Unresolve-Path($p) {
  if ($p -eq $null) { return $null }
  else { return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p) }
}

Function Make-RootPath($p) {
  $p = Unresolve-Path $p
  if (-Not (Test-Path $p)) { New-Item $p -ItemType directory | Out-Null }
}

Make-RootPath $root_path
