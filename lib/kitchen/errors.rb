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

  module Error ; end

  # Base exception class from which all Kitchen exceptions derive. This class
  # nests an exception when this class is re-raised from a rescue block.
  class StandardError < ::StandardError

    include Error

    attr_reader :original

    def initialize(msg, original = $!)
      super(msg)
      @original = original
    end
  end

  # Base exception class for all exceptions that are caused by user input
  # errors.
  class UserError < StandardError ; end

  # Base exception class for all exceptions that are caused by incorrect use
  # of an API.
  class ClientError < StandardError ; end

  # Base exception class for exceptions that are caused by external library
  # failures which may be temporary.
  class TransientFailure < StandardError ; end

  # Exception class for any exceptions raised when performing an instance
  # action.
  class ActionFailed < TransientFailure ; end
end
