  winrm.cmd quickconfig -q
  net user /add %machine_user% %machine_pass%
  net localgroup administrators %machine_user% /add
  bundle install --with integration
  bundle exec kitchen verify windows