# we are installing the first version of chef that bundled chef-zero in order
# to get chef-zero and Chef::ChefFS only. The version of Chef that gets run
# will be the installed omnibus package. Yep, this is funky :)

if ((& "$gem" list chef-zero -i) -ne "true") {
  Write-Host ">>>>>> Attempting to use chef-zero with old version of Chef`n"
  Write-Host "-----> Installing chef zero dependencies`n"
  & "$gem" install chef --version 11.8.0 --no-ri --no-rdoc --conservative
}
