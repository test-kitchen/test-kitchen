# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

  # A class to manage actors.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Manager

    include Celluloid

    trap_exit :actor_died

    # Terminate all actors that are linked.
    def stop
      Array(links.to_a).map { |actor| actor.terminate if actor.alive? }
    end

    private

    def actor_died(actor, reason)
      if reason.nil?
        Kitchen.logger.debug("Actor terminated cleanly")
      else
        Kitchen.logger.debug("An actor crashed due to #{reason.inspect}")
      end
    end
  end
end
