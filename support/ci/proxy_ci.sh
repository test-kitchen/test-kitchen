#!/usr/bin/env bash

set -e

# Add a local user for kitchen with a password we control.
sudo -E useradd $MACHINE_USER --shell /bin/bash --create-home
sudo -E usermod -p `openssl passwd -1 $MACHINE_PASS` $MACHINE_USER
sudo -E usermod -aG sudo $MACHINE_USER

# Make sure SSH can run on Azure DevOps hosted agent.
sudo mkdir -p /var/run/sshd
sudo service ssh restart

# Install squid and git.
sudo apt-get update
sudo apt-get -y install squid3 git curl 
git clone https://github.com/smurawski/proxy_tests.git

# Add the ruby path to the secure path, so we can run the tests elevated (to manage the squid service)
sudo echo 'Defaults	secure_path="/opt/hostedtoolcache/Ruby/2.5.5/x64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"' | sudo tee /etc/sudoers.d/kitchen
sudo echo "" | sudo tee -a /etc/sudoers.d/kitchen
sudo echo "kitchen ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/kitchen
sudo echo "" | sudo tee -a /etc/sudoers.d/kitchen


# Install dependencies and run some tests!
sudo -E bundle install --gemfile Gemfile.proxy_tests
sudo -E bundle exec bash $PROXY_TESTS_DIR/run_tests.sh kitchen \* \* /tmp/out.txt
cat /tmp/out.txt

echo ""
echo "===================="
echo "Tests finished."
echo "===================="
echo ""

sudo cat /var/log/squid/cache.log
sudo cat /var/log/squid/access.log
