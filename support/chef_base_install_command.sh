# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

# do_wget URL FILENAME
do_wget() {
  echo "trying wget..."
  wget -O "$2" "$1" 2>/tmp/stderr
  # check for bad return status
  test $? -ne 0 && return 1
  # check for 404 or empty file
  grep "ERROR 404" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0 || test ! -s "$2"; then
    return 1
  fi
  return 0
}

# do_curl URL FILENAME
do_curl() {
  echo "trying curl..."
  curl -L "$1" > "$2"
  # check for bad return status
  [ $? -ne 0 ] && return 1
  # check for bad output or empty file
  grep "The specified key does not exist." "$2" 2>&1 >/dev/null
  if test $? -eq 0 || test ! -s "$2"; then
    return 1
  fi
  return 0
}

# do_fetch URL FILENAME
do_fetch() {
  echo "trying fetch..."
  fetch -o "$2" "$1" 2>/tmp/stderr
  # check for bad return status
  test $? -ne 0 && return 1
  return 0
}

# do_perl URL FILENAME
do_perl() {
  echo "trying perl..."
  perl -e "use LWP::Simple; getprint($ARGV[0]);" "$1" > "$2"
  # check for bad return status
  test $? -ne 0 && return 1
  # check for bad output or empty file
  # grep "The specified key does not exist." "$2" 2>&1 >/dev/null
  # if test $? -eq 0 || test ! -s "$2"; then
  #   unable_to_retrieve_package
  # fi
  return 0
}

# do_python URL FILENAME
do_python() {
  echo "trying python..."
  python -c "import sys,urllib2 ; sys.stdout.write(urllib2.urlopen(sys.argv[1]).read())" "$1" > "$2"
  # check for bad return status
  test $? -ne 0 && return 1
  # check for bad output or empty file
  #grep "The specified key does not exist." "$2" 2>&1 >/dev/null
  #if test $? -eq 0 || test ! -s "$2"; then
  #  unable_to_retrieve_package
  #fi
  return 0
}

# do_download URL FILENAME
do_download() {
  PATH=/opt/local/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
  export PATH

  echo "downloading $1"
  echo "  to file $2"

  # we try all of these until we get success.
  # perl, in particular may be present but LWP::Simple may not be installed

  if exists wget; then
    do_wget $1 $2 && return 0
  fi

  if exists curl; then
    do_curl $1 $2 && return 0
  fi

  if exists fetch; then
    do_fetch $1 $2 && return 0
  fi

  if exists perl; then
    do_perl $1 $2 && return 0
  fi

  if exists python; then
    do_python $1 $2 && return 0
  fi

  echo ">>>>>> wget, curl, fetch, perl or python not found on this instance."
  return 16
}

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
