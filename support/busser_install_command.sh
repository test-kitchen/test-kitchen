
# Ensure that $BUSSER_ROOT is owned by the current user, which migh not be the
# case if parts of $BUSSER_ROOT are mounted via vagrant synched folders.
# See https://github.com/test-kitchen/test-kitchen/issues/671 
sudo chown -R $USER:$USER $BUSSER_ROOT

$gem list busser -i 2>&1 >/dev/null
if test $? -ne 0; then
  echo "-----> Installing Busser ($version)"
  $gem install $gem_install_args
else
  echo "-----> Busser installation detected ($version)"
fi

if test ! -f "$BUSSER_ROOT/bin/busser"; then
  gem_bindir=`$ruby -rrubygems -e "puts Gem.bindir"`
  $gem_bindir/busser setup
fi

echo "       Installing Busser plugins: $plugins"
$busser plugin install $plugins
