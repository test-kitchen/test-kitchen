# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

do_wget() {
  echo "trying wget..."
  wget -O "$2" "$1" 2>/tmp/stderr
  rc=$?
  # check for 404
  grep "ERROR 404" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    http_404_error
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "wget"
    return 1
  fi

  return 0
}

# do_curl URL FILENAME
do_curl() {
  echo "trying curl..."
  curl -sL -D /tmp/stderr "$1" > "$2"
  rc=$?
  # check for 404
  grep "404 Not Found" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    http_404_error
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "curl"
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

# do_curl URL FILENAME
do_perl() {
  echo "trying perl..."
  perl -e "use LWP::Simple; getprint($ARGV[0]);" "$1" > "$2" 2>/tmp/stderr
  rc=$?
  # check for 404
  grep "404 Not Found" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    http_404_error
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "perl"
    return 1
  fi

  return 0
}

# do_curl URL FILENAME
do_python() {
  echo "trying python..."
  python -c "import sys,urllib2 ; sys.stdout.write(urllib2.urlopen(sys.argv[1]).read())" "$1" > "$2" 2>/tmp/stderr
  rc=$?
  # check for 404
  grep "HTTP Error 404" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    http_404_error
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "python"
    return 1
  fi
  return 0
}

capture_tmp_stderr() {
  # spool up /tmp/stderr from all the commands we called
  if test -f "/tmp/stderr"; then
    output=`cat /tmp/stderr`
    stderr_results="${stderr_results}\nSTDERR from $1:\n\n$output\n"
    rm /tmp/stderr
  fi
}

# do_download URL FILENAME
do_download() {
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

  unable_to_retrieve_installer
}


http_404_error() {
  echo "FOUR OH FOUR"
  # To Do
  exit 1
}

unable_to_retrieve_installer() {
  echo "Unable to retrieve a valid installer!"

  if test "x$stderr_results" != "x"; then
    echo "\nDEBUG OUTPUT FOLLOWS:\n$stderr_results"
  fi

  exit 1
}

# @param $1 the omnibus root directory
# @param $2 the requested version of omnibus package
# @return 0 if omnibus needs to be installed, non-zero otherwise
should_update_chef() {
  if test ! -d "$1" ; then return 0
  elif test "$2" = "true" ; then return 1
  elif test "$2" = "latest" ; then return 0
  fi

  version="`$1/bin/chef-solo -v | cut -d \" \" -f 2`"

  echo "$version" | grep "^$2" 2>&1 >/dev/null
  if test $? -eq 0 ; then
    return 1
  else
    return 0
  fi
}

platform=`/usr/bin/uname -s`
platform_version=`/usr/bin/uname -r`

should_update_chef "$chef_omnibus_root" "$version"
if test $? -eq 0 ; then
  echo "-----> Installing Chef Omnibus ($pretty_version)"

  if test "x$platform" = "xSunOS" && test "x$platform_version" = "x5.10"; then
    # solaris 10 lacks recent enough credentials - your base O/S is completely insecure, please upgrade
    chef_omnibus_url=`echo $chef_omnibus_url | sed -e 's/https/http/'`
  fi

  do_download "$chef_omnibus_url" /tmp/install.sh
  if test $? -ne 0 ; then
    echo ">>>>>>>> NO FREAKING DOWNLOAD THINGS FOUND - ABOOOOORRRRTTTT"
    exit 1;
  fi
  $sudo_sh /tmp/install.sh $install_flags
else
  echo "-----> Chef Omnibus installation detected ($pretty_version)"
fi
