# we are installing the first version of chef that bundled chef-zero in order
# to get chef-zero and Chef::ChefFS only. The version of Chef that gets run
# will be the installed omnibus package. Yep, this is funky :)

$gem list chef-zero -i 2>&1 >/dev/null
if test $? -ne 0 ; then
  echo ">>>>>> Attempting to use chef-zero with old version of Chef"
  echo "-----> Installing chef zero dependencies"
  $gem install chef --version 11.8.0 --no-ri --no-rdoc --conservative
fi
