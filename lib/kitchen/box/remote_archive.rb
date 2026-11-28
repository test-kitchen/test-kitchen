# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "net/http" unless defined?(Net::HTTP)
require "uri" unless defined?(URI::HTTP)
require "kitchen/errors"

module Kitchen
  module Box
    # Streams an explicitly selected archive into cache-owned temporary storage.
    class RemoteArchive
      REDIRECTS = %w{301 302 303 307 308}.freeze
      LOOPBACK = %w{localhost 127.0.0.1 ::1}.freeze

      def self.valid_url?(url)
        return false unless url.is_a?(String)

        uri = URI.parse(url)
        uri.is_a?(URI::HTTP) && !uri.host.to_s.empty? && !uri.userinfo && !uri.fragment &&
          (uri.scheme == "https" || LOOPBACK.include?(uri.hostname))
      rescue URI::InvalidURIError
        false
      end

      def initialize(url)
        @url = url
      end

      def download(destination, bytes:)
        url = @url
        6.times do
          raise UserError, "Unsupported remote box URL" unless self.class.valid_url?(url)

          uri = URI.parse(url)
          location = request(uri, destination, bytes)
          return unless location

          redirect = URI.join(uri.to_s, location)
          if uri.scheme == "https" && redirect.scheme != "https"
            raise UserError, "Remote box redirected from HTTPS to an insecure URL"
          end

          url = redirect.to_s
        end
        raise UserError, "Too many redirects while downloading remote box"
      rescue URI::Error, SocketError, SystemCallError, IOError, Timeout::Error, OpenSSL::SSL::SSLError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError => e
        raise UserError, "Cannot download remote box (#{e.class})"
      end

      private

      def request(uri, destination, bytes)
        proxy = LOOPBACK.include?(uri.hostname) ? nil : :ENV
        http = Net::HTTP.new(uri.hostname, uri.port, proxy)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = 10
        http.read_timeout = 30
        http.max_retries = 0
        http.request_get(uri.request_uri, "Accept-Encoding" => "identity") do |response|
          if REDIRECTS.include?(response.code)
            return response["location"] || raise(UserError, "Remote box redirect has no location")
          end
          raise UserError, "Remote box download returned HTTP #{response.code}" unless response.code == "200"

          File.open(destination, "wb", 0o600) do |archive|
            response.read_body do |chunk|
              bytes -= chunk.bytesize
              raise UserError, "Size mismatch while downloading remote box" if bytes < 0

              archive.write(chunk)
            end
          end
          raise UserError, "Size mismatch while downloading remote box" unless bytes == 0
        end
        nil
      end
    end
  end
end
