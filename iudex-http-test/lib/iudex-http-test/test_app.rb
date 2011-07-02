#--
# Copyright (c) 2011 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'rack'
require 'sinatra/base'
require 'markaby'
require 'cgi'

require 'iudex-http-test/base'

module Iudex::HTTP::Test

  class TestApp < Sinatra::Base

    PUBLIC = File.expand_path( File.join(
               File.dirname( __FILE__ ), '..', '..', 'public' ) )

    before '*' do
      s = params[:sleep].to_f
      sleep s if s > 0.0
    end

    get '/' do
      redirect to( '/index' )
    end

    get '/301' do
      redirect( to( '/index' ), 301 ) #"redirect body"
    end

    get '/redirects/multi/:depth' do
      depth = params[:depth].to_i
      status = ( params[:code] || 302 ).to_i
      if depth > 1
        redirect( to( "/redirects/multi/#{depth - 1}#{common params}" ),
                  status )
      else
        "You finally made it"
      end
    end

    get '/index' do
      markaby do
        html do
          head { title "Test Index Page" }
          body do
            h1 "Iudex HTTP Test Service"
            a( :href => url( '/foobar' ) ) { "foobar" }
          end
        end
      end
    end

    get '/atom.xml' do
      send_file( "#{PUBLIC}/atom.xml",
                 :type => 'application/atom+xml' )
    end

    get '/env' do
      request.inspect
    end

    def common( params )
      ps = [ :sleep ].
        map { |k| ( v = params[k] ) && [ k, v ] }.
        compact.
        map { |k,v| [ k, CGI.escape( v.to_s ) ].join( '=' ) }
      '?' + ps.join( '&' ) unless ps.empty?
    end

  end

end
