# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

module Kitchen

  module Shell

    # Bourne shell.
    #
    # @author Matt Wrock <matt@mattwrock.com>
    class Bourne < Base

      # (see Base#busser_setup)
      def busser_setup(ruby_bin, busser_root, gem_install_args)
        gem = sudo("#{ruby_bin}/gem")
        <<-CMD.gsub(/^ {10}/, "")
          mkdir -p #{busser_root}/suites
          gem_bindir=`#{ruby_bin}/ruby -rrubygems -e "puts Gem.bindir"`

          if ! #{gem} list busser -i >/dev/null; then
            #{gem} install #{gem_install_args}
          fi
          #{sudo("${gem_bindir}")}/busser setup
        CMD
      end

      # (see Base#set_env)
      def set_env(key, value)
        <<-CMD.gsub(/^ {10}/, "")
          #{key}="#{value}"
          export #{key}
        CMD
      end

      # (see Base#add_to_path)
      def add_to_path(dir)
        <<-CMD.gsub(/^ {10}/, "")
          export PATH="$PATH:#{dir}"
        CMD
      end

      # (see Base#helper_file)
      def helper_file
        file = "download_helpers.sh"

        IO.read(File.join(
          File.dirname(__FILE__), %W[.. .. .. support #{file}]
        ))
      end

      # (see Base#wrap_command)
      def wrap_command(command)
        command = "false" if command.nil?
        command = "true" if command.to_s.empty?

        command = command.sub(/\n\Z/, "") if command =~ /\n\Z/

        "sh -c '\n#{command}\n'"
      end

      # (see Base#sudo)
      def sudo(script)
        config[:sudo] ? "sudo -E #{script}" : script
      end
    end
  end
end
