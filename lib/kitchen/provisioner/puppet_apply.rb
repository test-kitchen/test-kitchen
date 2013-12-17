# -*- encoding: utf-8 -*-
#
# Author:: Chris Lundquist (<chris.lundquist@github.com>)
#
# Copyright (C) 2013, Chris Lundquist
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

require 'kitchen/provisioner/chef_base'

module Kitchen

  module Provisioner

    # Puppet Apply provisioner.
    #
    # @author Chris Lundquist (<chris.lundquist@github.com>)
    class PuppetApply < Base
      attr_accessor :tmpdir

      default_config :require_puppet_omnibus, true
      # TODO use something like https://github.com/fnichol/omnibus-puppet
      default_config :puppet_omnibus_url, nil
      default_config :puppet_version,    'latest'

      default_config :manifest, 'site.pp'

      default_config :manifests_path do |provisioner|
        provisioner.calculate_path('manifests') or
          raise 'No manifests_path detected. Please specify one in .kitchen.yml'
      end

      default_config :modules_path do |provisioner|
        provisioner.calculate_path('modules') or
          raise 'No modules_path detected. Please specify one in .kitchen.yml'
      end

      default_config :hiera_data_path do |provisioner|
        provisioner.calculate_path('hiera')
      end

      default_config :hiera_config_path do |provisioner|
        provisioner.calculate_path('hiera.yaml', :file)
      end

      # FIXME honor omnibus options
      def install_command
        return unless config[:require_puppet_omnibus]

       <<-INSTALL
        if [ ! $(which puppet) ]; then
          #{sudo('wget')} http://apt.puppetlabs.com/puppetlabs-release-precise.deb
          #{sudo('dpkg')} -i puppetlabs-release-precise.deb
          #{sudo('apt-get')} update

          #{sudo('apt-get')} install -y --force-yes \
          build-essential \
          pkg-config \
          libmysqlclient-dev \
          libxslt-dev \
          libaugeas-dev \
          libxml2-dev \
          libxml2=2.7.8.dfsg-5.1ubuntu4 # newer package has broken deps

          #{sudo('apt-get')} install -y puppet=#{version} puppet-common=#{version} hiera-puppet rubygems
          #{sudo('gem')} install bundler --no-ri --no-rdoc
        fi
        INSTALL
      end

      def create_sandbox
        @tmpdir = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, tmpdir)
        info('Preparing files for transfer')
        debug("Creating local sandbox in #{tmpdir}")

        yield if block_given?

        prepare_modules
        prepare_manifests
        prepare_hiera_config
        prepare_hiera_data

        tmpdir
      end

      def cleanup_sandbox
        return if tmpdir.nil?

        debug("Cleaning up local sandbox in #{tmpdir}")
        FileUtils.rmtree(tmpdir)
      end

      def prepare_command
        commands = []

        if hiera_config
          commands << [
            sudo('cp'), File.join(config[:root_path],'hiera.yaml'), '/etc/',
          ].join(' ')

          commands << [
            sudo('cp'), File.join(config[:root_path],'hiera.yaml'), '/etc/puppet/',
          ].join(' ')
        end

        if hiera_data
          commands << [
            sudo('cp -r'), File.join(config[:root_path], 'hiera'), '/var/lib/'
          ].join(' ')
        end

        commands.join(' && ')
      end

      def run_command
        [
          sudo('puppet'),
          'apply',
          File.join(config[:root_path], 'manifests', manifest),
          "--modulepath=#{File.join(config[:root_path], 'modules')}",
          "--manifestdir=#{File.join(config[:root_path], 'manifests')}"
        ].join(" ")
      end

      protected

      def manifest
        config[:manifest]
      end

      def manifests
        config[:manifests_path]
      end

      def modules
        config[:modules_path]
      end

      def hiera_config
        config[:hiera_config_path]
      end

      def hiera_data
        config[:hiera_data_path]
      end

      def version
        # TODO honor version
        '2.7.23-1puppetlabs1' # || config[:puppet_version] == 'latest' ? nil : config[:puppet_version]
      end

      def prepare_manifests
        info('Preparing manifests')
        debug("Using manifests from #{manifests}")

        tmp_manifests_dir = File.join(tmpdir, 'manifests')
        FileUtils.mkdir_p(tmp_manifests_dir)
        FileUtils.cp_r(Dir.glob("#{manifests}/*"), tmp_manifests_dir)
      end

      def prepare_modules
        info('Preparing modules')
        debug("Using modules from #{modules}")

        tmp_modules_dir = File.join(tmpdir, 'modules')
        FileUtils.mkdir_p(tmp_modules_dir)
        FileUtils.cp_r(Dir.glob("#{modules}/*"), tmp_modules_dir)
      end

      def prepare_hiera_config
        return unless hiera_config

        info('Preparing hiera')
        debug("Using hiera from #{hiera_config}")

        FileUtils.cp_r(hiera_config, File.join(tmpdir, 'hiera.yaml'))
      end

      def prepare_hiera_data
        return unless hiera_data
        info('Preparing hiera data')
        debug("Using hiera data from #{hiera_data}")

        tmp_hiera_dir = File.join(tmpdir, 'hiera')
        FileUtils.mkdir_p(tmp_hiera_dir)
        FileUtils.cp_r(Dir.glob("#{hiera_data}/*"), tmp_hiera_dir)
      end
    end
  end
end
