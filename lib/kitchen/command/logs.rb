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

require_relative "../command"

require "json" unless defined?(JSON)

module Kitchen
  module Command
    # Command to print structured logs for one instance.
    class Logs < Kitchen::Command::Base
      LEVELS = %w{debug info warn error fatal unknown}.freeze

      # Invoke the command.
      def call
        validate_format!
        validate_level!
        if options[:all_sessions]
          emit_all_session_logs
          return
        end

        target_instances = instances
        validate_follow_target!(target_instances)

        target_instances.each do |instance|
          session_id = selected_session_id(instance)
          die "No structured log file found at #{instance.structured_log_path}" unless
            File.file?(instance.structured_log_path)

          emit_file(instance.structured_log_path, session_id)
          follow_file(instance.structured_log_path, session_id) if options[:follow]
        end
      end

      private

      def emit_all_session_logs
        log_paths = all_session_log_paths
        validate_follow_target!(log_paths)

        log_paths.each do |path|
          emit_file(path, nil)
          follow_file(path, nil) if options[:follow]
        end
      end

      def all_session_log_paths
        paths = structured_log_paths(args.first)
        return paths unless paths.empty?

        die "No structured log files found in #{Kitchen::DEFAULT_LOG_DIR}"
      end

      def structured_log_paths(arg)
        paths = all_structured_log_paths
        return paths if arg.nil? || arg == "all"

        exact_path = File.join(Kitchen::DEFAULT_LOG_DIR, "#{arg}.ndjson")
        return [exact_path] if File.file?(exact_path)

        regexp = Regexp.new(arg)
        paths.select { |path| File.basename(path, ".ndjson") =~ regexp }
      rescue RegexpError => e
        die "Invalid Ruby regular expression, " \
          "you may need to single quote the argument. " \
          "Please try again or consult https://rubular.com/ (#{e.message})"
      end

      def all_structured_log_paths
        Dir[File.join(Kitchen::DEFAULT_LOG_DIR, "*.ndjson")]
          .reject { |path| File.basename(path) == "kitchen.ndjson" }
          .sort
      end

      def validate_follow_target!(targets)
        return unless options[:follow] && targets.size > 1

        die "Following multiple instance logs is not supported; choose one instance"
      end

      def instances
        results = parse_subcommand(args.first)
        if results.size > 1 && !options[:all_sessions]
          die "Argument `#{args.first}' returned multiple results:\n" +
            results.map { |i| "  * #{i.name}" }.join("\n")
        end
        results
      end

      def selected_session_id(instance)
        return if options[:all_sessions]
        return options[:session_id] if options[:session_id]
        return instance.current_session_id if instance.current_session_id

        if File.file?(instance.structured_log_path)
          session_id = latest_session_id(instance.structured_log_path)
          return session_id if session_id
        end

        die "Instance #{instance.to_str} has no current session id; use --all-sessions"
      end

      def latest_session_id(path)
        File.foreach(path).filter_map do |line|
          JSON.parse(line)["instance_session_id"]
        rescue JSON::ParserError
          nil
        end.last
      end

      def emit_file(path, session_id)
        File.foreach(path) { |line| emit_line(line, session_id) }
      end

      def follow_file(path, session_id)
        File.open(path, "r") do |file|
          file.seek(0, IO::SEEK_END)
          loop do
            line = file.gets
            if line
              emit_line(line, session_id)
            else
              sleep 1
            end
          end
        end
      end

      def emit_line(line, session_id)
        event = JSON.parse(line)
        return unless session_match?(event, session_id)
        return unless level_match?(event)

        puts format_event(event)
      rescue JSON::ParserError
        nil
      end

      def format_event(event)
        case options[:format]
        when "ndjson" then JSON.generate(event)
        when nil, "text" then event["message"].to_s
        end
      end

      def session_match?(event, session_id)
        session_id.nil? || event["instance_session_id"] == session_id
      end

      def level_match?(event)
        return true unless options[:level]

        level_index(event["level"]) >= level_index(options[:level])
      end

      def level_index(level)
        LEVELS.index(level.to_s) || LEVELS.index("unknown")
      end

      def validate_format!
        return if [nil, "ndjson", "text"].include?(options[:format])

        die "Invalid logs format `#{options[:format]}'; use ndjson or text"
      end

      def validate_level!
        return unless options[:level]
        return if LEVELS.include?(options[:level])

        die "Invalid log level `#{options[:level]}'; use debug, info, warn, error, or fatal"
      end
    end
  end
end
