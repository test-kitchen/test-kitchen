tmp_stderr="/tmp/stderr";

# capture_tmp_stderr SOURCE
capture_tmp_stderr() {
  # spool up $tmp_stderr from all the commands we called
  if test -f "$tmp_stderr"; then
    output="`cat $tmp_stderr`";
    stderr_results="${stderr_results}\nSTDERR from $1:\n\n${output}\n";
    rm $tmp_stderr;
  fi
}

# do_curl URL FILENAME
do_curl() {
  echo "Trying curl...";
  curl -sL -D "$tmp_stderr" "$1" > "$2";
  ec=$?;
  # check for 404
  grep "404 Not Found" "$tmp_stderr" 2>&1 >/dev/null;
  if test $? -eq 0; then
    http_404_error "$1";
  fi

  # check for bad return status or empty output
  if test $ec -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "curl";
    return 1;
  else
    echo "Download complete.";
    return 0;
  fi
}

# do_download URL FILENAME
do_download() {
  echo "Downloading ${1} to file ${2}";

  exists wget;
  if test $? -eq 0; then
    do_wget "$1" "$2" && return 0;
  fi

  exists curl;
  if test $? -eq 0; then
    do_curl "$1" "$2" && return 0;
  fi

  exists fetch;
  if test $? -eq 0; then
    do_fetch "$1" "$2" && return 0;
  fi

  exists python;
  if test $? -eq 0; then
    do_python "$1" "$2" && return 0;
  fi

  exists perl;
  if test $? -eq 0; then
    do_perl "$1" "$2" && return 0;
  fi

  unable_to_download "$1" "$2";
}

# do_fetch URL FILENAME
do_fetch() {
  echo "Trying fetch...";
  fetch -o "$2" "$1" 2>"$tmp_stderr";
  ec=$?;
  # check for 404
  grep "Not Found" "$tmp_stderr" 2>&1 >/dev/null;
  if test $? -eq 0; then
    http_404_error "$1";
  fi

  # check for bad return status or empty output
  if test $ec -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "fetch";
    return 1;
  else
    echo "Download complete.";
    return 0;
  fi
}

# do_perl URL FILENAME
do_perl() {
  echo "Trying perl...";
  perl -e "use LWP::Simple; getprint(\$ARGV[0]);" "$1" > "$2" 2>"$tmp_stderr";
  ec=$?;
  # check for 404
  grep "404 Not Found" "$tmp_stderr" 2>&1 >/dev/null;
  if test $? -eq 0; then
    http_404_error "$1";
  fi

  # check for bad return status or empty output
  if test $ec -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "perl";
    return 1;
  else
    echo "Download complete.";
    return 0;
  fi
}

# do_python URL FILENAME
do_python() {
  echo "Trying python...";
  python -c "import sys,urllib2 ; sys.stdout.write(urllib2.urlopen(sys.argv[1]).read())" "$1" > "$2" 2>"$tmp_stderr";
  ec=$?;
  # check for 404
  grep "HTTP Error 404" "$tmp_stderr" 2>&1 >/dev/null;
  if test $? -eq 0; then
    http_404_error "$1";
  fi

  # check for bad return status or empty output
  if test $ec -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "python";
    return 1;
  else
    echo "Download complete.";
    return 0;
  fi
}

# do_wget URL FILENAME
do_wget() {
  echo "Trying wget...";
  wget -O "$2" "$1" 2>"$tmp_stderr";
  ec=$?;
  # check for 404
  grep "ERROR 404" "$tmp_stderr" 2>&1 >/dev/null;
  if test $? -eq 0; then
    http_404_error "$1";
  fi

  # check for bad return status or empty output
  if test $ec -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "wget";
    return 1;
  else
    echo "Download complete.";
    return 0;
  fi
}

# exists COMMAND
exists() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0;
  else
    return 1;
  fi
}

# http_404_error URL
http_404_error() {
  echo ">>>>>> Downloading ${1} resulted in an HTTP/404, aborting";
  exit 40;
}

# should_update_chef ROOT VERSION
should_update_chef() {
  if test ! -d "$1"; then
    return 0;
  elif test "$2" = "true"; then
    return 1;
  elif test "$2" = "latest"; then
    return 0;
  fi

  if test -f "${1}/version-manifest.txt"; then
    chef_version="`head -n 1 ${1}/version-manifest.txt | cut -d \" \" -f 2`";
  else
    chef_version="`${1}/bin/chef-solo -v | cut -d \" \" -f 2`";
  fi

  echo "$chef_version" | grep "^${2}" 2>&1 >/dev/null;
  if test $? -eq 0; then
    return 1;
  else
    echo "${2}" | grep "^$chef_version" 2>&1 >/dev/null;
    if test $? -eq 0; then
      return 1;
    else
      return 0;
    fi
  fi
}

# unable_to_download URL FILE
unable_to_download() {
  echo "Unable to download $1 to $2, aborting";

  if test "x${stderr_results}" != "x"; then
    echo "\nDEBUG OUTPUT FOLLOWS:\n${stderr_results}";
  fi

  exit 10;
}

# main
main() {
  should_update_chef "$chef_omnibus_root" "$version"
  if test $? -eq 0; then
    echo "-----> Installing Chef Omnibus (${pretty_version})";

    # solaris 10 lacks recent enough credentials, so http url is used
    platform="`/usr/bin/uname -s 2>/dev/null`";
    platform_version="`/usr/bin/uname -r 2>/dev/null`";
    if test "x${platform}" = "xSunOS" && test "x${platform_version}" = "x5.10"; then
      chef_omnibus_url=`echo "$chef_omnibus_url" | sed -e "s/https/http/"`;
    fi

    do_download "$chef_omnibus_url" /tmp/install.sh;
    $sudo_sh /tmp/install.sh $install_flags;
  else
    echo "-----> Chef Omnibus installation detected (${pretty_version})";
  fi
}

# augment path in an attempt to find a download program
PATH="${PATH}:/opt/local/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/sfw/bin";
export PATH;

main
