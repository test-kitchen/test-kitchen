#
# Author:: Andrew Crump (<andrew@kotirisoftware.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module TestKitchen
  module Project
    module SupportedPlatforms

      def extract_supported_platforms(metadata)
        raise ArgumentError, "Metadata must be provided" unless metadata
        ast = parse_ruby(metadata)
        supports = find_nodes(ast, [:command]).reject do |command|
          find_nodes(command, [:@ident, 'supports']).empty?
        end
        string_literals(supports) + word_list(ast, supports)
      end

      private

      def parse_ruby(ruby_str)
        Ripper::SexpBuilder.new(ruby_str).parse
      end

      def word_list(ast, nodes)
        nodes.map do |node|
          var_name = find_nodes(find_nodes(node, [:var_ref]), [:@ident]).flatten
          if var_name.length > 1
            add_block = find_nodes(ast, [:method_add_block])
            unless find_nodes(find_nodes(add_block, [:do_block]),
              [:@ident, var_name[1]]).flatten.empty?

              find_nodes(find_nodes(add_block,
                [:qwords_add]), [:@tstring_content]).uniq.map do |str|
                  str[1] if str.length > 1
                end

            end
          end
        end.flatten.compact
      end

      def string_literals(nodes)
        nodes.map do |node|
          find_nodes(node, [:@tstring_content]).map do |tstring|
            tstring[1] if tstring.length > 1
          end.compact
        end.flatten
      end

      def find_nodes(ast, node, result=[])
        if ast.respond_to?(:each)
          result << ast if ast.size > 1 and ast[0..(node.size - 1)] == node
          ast.each { |child| find_nodes(child, node, result) }
        end
        result
      end

    end
  end
end
