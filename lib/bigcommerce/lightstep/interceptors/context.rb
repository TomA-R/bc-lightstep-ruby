# frozen_string_literal: true

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
    module Interceptors
      ##
      # Runs interceptors in a given context
      #
      class Context
        ##
        # Initialize the interception context
        #
        # @param [Array<Bigcommerce::Lightstep::Interceptors::Base>] interceptors
        # @param [::Logger] logger
        #
        def initialize(interceptors: nil, logger: nil)
          @interceptors = interceptors || ::Bigcommerce::Lightstep.interceptors.all
          @logger = logger || ::Bigcommerce::Lightstep.logger
        end

        ##
        # Intercept a trace with all interceptors
        #
        # @param [::LightStep::Span] span
        #
        def intercept(span)
          return yield span if @interceptors.none?

          interceptor = @interceptors.pop

          return yield span unless interceptor

          @logger.debug "[bigcommerce-lightstep] Intercepting request with interceptor: #{interceptor.class}"

          interceptor.call(span: span) do |yielded_span|
            if @interceptors.any?
              intercept(yielded_span) { yield yielded_span }
            else
              yield yielded_span
            end
          end
        end
      end
    end
  end
end
