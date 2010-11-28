#!/usr/bin/env jruby
# -*- coding: utf-8 -*-
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2010 David Kellum
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

require File.join( File.dirname( __FILE__ ), "setup" )

require 'iudex-html'
require 'iudex-html/factory_helper'

require 'iudex-filter/filter_chain_factory'

class TestFactoryHelper < MiniTest::Unit::TestCase
  include HTMLTestHelper

  # include Gravitext::HTMap
  # include Iudex::Core
  # include Iudex::HTML
  # include Iudex::HTML::Filters
  # include Iudex::Filter::Core

  # UniMap.define_accessors

  class TestFilterChainFactory < Iudex::Filter::Core::FilterChainFactory
    include Iudex::HTML::Filters::FactoryHelper

    def filters
     [ html_clean_filters( :title,   :title_tree ),
       html_clean_filters( :summary, :summary_tree ),
       html_write_filter( :summary_tree, :summary ) ].flatten
    end
  end

  def test
    fcf = TestFilterChainFactory.new( "test" )
    fcf.open
    assert( fcf.open? )
    fcf.close
  end

end
