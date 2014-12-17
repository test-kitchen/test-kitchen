# @param $1 the omnibus root directory
# @param $2 the requested version of omnibus package
# @return 0 if omnibus needs to be installed, non-zero otherwise
should_update_chef() {
  if test ! -d "$1" ; then return 0
  elif test "$2" = "true" ; then return 1
  elif test "$2" = "latest" ; then return 0
  fi

  local version="`$1/bin/chef-solo -v | cut -d " " -f 2`"
  if echo "$version" | grep "^$2" 2>&1 >/dev/null; then
    return 1
  else
    return 0
  fi
}
