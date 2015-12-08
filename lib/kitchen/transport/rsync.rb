# -*- encoding: utf-8 -*-
#
# Author:: Matt Kulka (<mkulka@local-motors.com>)
#
# Copyright (C) 2015, Matt Kulka
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
require "kitchen/transport/ssh"

require "open3"

module Kitchen
  module Transport
    class Rsync < Kitchen::Transport::Ssh

      # Connection class that inherits from the normal ssh class but
      # overrides the upload method to call out to rsync.
      class Connection < Kitchen::Transport::Ssh::Connection
        def upload(locals, remote)
          key_args = []
          Array(options[:keys]).each { |ssh_key| key_args << "-i #{ssh_key}" }
          cmd = "rsync -rav --delete --exclude=cache -e 'ssh -l #{username} -p #{port} " \
            " -o StrictHostKeyChecking=no #{key_args.join(" ")}' #{locals.join(" ")} " \
            "#{hostname}:#{remote}"

          logger.debug("Rsync via command '#{cmd}'")
          Open3.popen2e(cmd) {|stdin, stdout_stderr, wait_thr|
            Thread.new do
              stdout_stderr.each {|l| logger.debug(l.chomp) }
            end

            stdin.puts("#{options[:password]}\n") if Array(options[:keys]).empty?
            logger.debug("Rsync returned #{wait_thr.value}")
          }
        end
      end
    end
  end
end
