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

    # Powershell shell.
    #
    # @author Matt Wrock <matt@mattwrock.com>
    class Powershell < Base

      def default_ruby_bin
        "$env:systemdrive\\opscode\\chef\\embedded\\bin"
      end

      def default_busser_bin(busser_root)
        File.join(busser_root, "gems/bin/busser.bat")
      end

      def busser_setup(ruby_bin, busser_root, gem_install_args)
        <<-CMD.gsub(/^ {10}/, "")
          if ((gem list busser -i) -eq \"false\") {
            gem install #{gem_install_args}
          }
          Copy-Item #{ruby_bin}/ruby.exe #{busser_root}/gems/bin
        CMD
      end

      def set_env(key, value)
        <<-CMD.gsub(/^ {10}/, "")
          $env:#{key}="#{value}"
        CMD
      end

      def add_to_path(dir)
        <<-CMD.gsub(/^ {10}/, "")
          $env:PATH="$env:PATH;#{dir}"
        CMD
      end

      # (see Base#wrap_command)
      def wrap_command(command)
        command = "false" if command.nil?
        command = "true" if command.to_s.empty?
        command
      end

      # (see Base#sudo)
      def sudo(script)
        script
      end
    end
  end
end
