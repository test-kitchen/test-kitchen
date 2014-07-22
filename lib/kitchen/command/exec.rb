# -*- encoding: utf-8 -*-
#
# Author:: SAWANOBORI Yukihiko (<sawanoboriyu@higanworks.com>)
#
# Copyright (C) 2014, HiganWorks LLC
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

require "kitchen/command"

module Kitchen

  module Command

    # Execute command on remote instance.
    #
    # @author SAWANOBORI Yukihiko (<sawanoboriyu@higanworks.com>)
    class Exec < Kitchen::Command::Base

      # Invoke the command.
      def call
        results = parse_subcommand(args.first)

        results.each do |instance|
          banner "Execute command on #{instance.name}."
          instance.remote_exec(options[:command])
        end
      end
    end
  end
end
