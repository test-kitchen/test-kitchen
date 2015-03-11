# @param $1 the omnibus root directory
# @param $2 the requested version of omnibus package
# @return 0 if omnibus needs to be installed, non-zero otherwise
should_update_chef() {
  if test ! -d "$1" ; then return 0
  elif test "$2" = "true" ; then return 1
  elif test "$2" = "latest" ; then return 0
  fi

  local version="`$1/bin/chef-solo -v | cut -d " " -f 2`"

  echo "$version" | grep "^$2" 2>&1 >/dev/null
  if test $? -eq 0 ; then
    return 1
  else
    return 0
  fi
}

should_update_chef "$chef_omnibus_root" "$version"
if test $? -eq 0 ; then
  echo "-----> Installing Chef Omnibus ($pretty_version)"
  do_download "$chef_omnibus_url" /tmp/install.sh
  $sudo_sh /tmp/install.sh $install_flags
else
  echo "-----> Chef Omnibus installation detected ($pretty_version)"
fi
