#
# Author:: Test Kitchen Contributors
#
# Copyright (C) 2026, Test Kitchen Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen/verifier/inspec"

module Kitchen
  module Verifier
    # Compatibility alias which presents the Cinc Auditor verifier name while
    # reusing the kitchen-inspec implementation and configuration surface.
    class CincAuditor < Inspec
    end
  end
end
