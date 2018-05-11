# Copyright (c) 2018-present, BigCommerce Pty. Ltd. All rights reserved
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

module Bigcommerce
  module Lightstep
    ##
    # General configuration for lightstep integration
    #
    module Configuration
      VALID_CONFIG_KEYS = {
        component_name: '',
        access_token: '',
        host: 'lightstep-collector.linkerd',
        port: 4140,
        ssl_verify_peer: true,
        open_timeout: 20,
        read_timeout: 20,
        continue_timeout: nil,
        keep_alive_timeout: 2,
        logger: nil,
        verbosity: 1
      }.freeze

      attr_accessor *VALID_CONFIG_KEYS.keys

      ##
      # Whenever this is extended into a class, setup the defaults
      #
      def self.extended(base)
        base.reset
      end

      ##
      # Yield self for ruby-style initialization
      #
      # @yields [Bigcommerce::Instrumentation::Configuration]
      # @return [Bigcommerce::Instrumentation::Configuration]
      #
      def configure
        reset unless @configured
        yield self
        @configured = true
      end

      ##
      # @return [Boolean]
      #
      def configured?
        @configured
      end

      ##
      # Return the current configuration options as a Hash
      #
      # @return [Hash]
      #
      def options
        opts = {}
        VALID_CONFIG_KEYS.each_key do |k|
          opts.merge!(k => send(k))
        end
        opts
      end

      ##
      # Set the default configuration onto the extended class
      #
      def reset
        VALID_CONFIG_KEYS.each do |k, v|
          send("#{k}=".to_sym, v)
        end
        self.component_name = ENV.fetch('LIGHTSTEP_COMPONENT_NAME', '')
        self.access_token = ENV.fetch('LIGHTSTEP_ACCESS_TOKEN', '')
        self.host = ENV.fetch('LIGHTSTEP_HOST', 'lightstep-collector.linkerd')
        self.port = ENV.fetch('LIGHTSTEP_PORT', 4140).to_i
        self.ssl_verify_peer = ENV.fetch('LIGHTSTEP_SSL_VERIFY_PEER', true)
        self.verbosity = ENV.fetch('LIGHTSTEP_VERBOSITY', 1).to_i
        self.logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      end

      ##
      # Automatically determine environment
      #
      def environment
        if defined?(Rails)
          Rails.env
        else
          ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
        end
      end
    end
  end
end
