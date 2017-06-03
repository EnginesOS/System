#https://github.com/swipely/docker-api/blob/5c677411fa9ba9dbb4a52e378f48cac4f9abf9bc/lib/excon/middlewares/hijack.rb
#The MIT License (MIT)
#
#Copyright (c) 2014 Swipely, Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
module Excon
  VALID_REQUEST_KEYS << :hijack_block
  module Middleware
    # Hijack is an Excon middleware which parses response headers and then
    # yields the underlying TCP socket for raw TCP communication (used to
    # attach to STDIN of containers).
    class Hijack < Base
      def build_response(status, socket)
        response = {
          body: '',
          headers: Excon::Headers.new,
          status: status,
          remote_ip: socket.respond_to?(:remote_ip) &&
          socket.remote_ip,
        }
        if socket.data[:scheme] =~ /^(https?|tcp)$/
          response.merge({
            local_port: socket.respond_to?(:local_port) &&
            socket.local_port,
            local_address: socket.respond_to?(:local_address) &&
            socket.local_address
          })
        end
        response
      end

      def response_call(datum)
        r=nil
        if datum[:hijack_block]
          # Need to process the response headers here rather than in
          # Excon::Middleware::ResponseParser as the response parser will
          # block trying to read the body.
          socket = datum[:connection].send(:socket)

          # c.f. Excon::Response.parse
          until match = /^HTTP\/\d+\.\d+\s(\d{3})\s/.match(socket.readline); end
          status = match[1].to_i

          datum[:response] = build_response(status, socket)

          Excon::Response.parse_headers(socket, datum)
          datum[:hijack_block].call socket.instance_variable_get(:@socket)
        end
        r =  @stack.response_call(datum)
        #    rescue   dotn catch excepions here as is break excon
      end
    end
  end
end