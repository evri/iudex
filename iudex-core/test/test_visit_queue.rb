#!/usr/bin/env jruby
#.hashdot.profile += jruby-shortlived

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

require File.join( File.dirname( __FILE__ ), "setup" )
require 'iudex-core'

class TestVisitQueue < MiniTest::Unit::TestCase
  include Iudex::Core
  include Gravitext::HTMap

  import 'java.util.concurrent.Executors'
  import 'java.util.concurrent.TimeUnit'
  import 'java.lang.Runnable'

  UniMap.create_key( 'vtest_input' )

  UniMap.define_accessors

  def setup
    @visit_q = VisitQueue.new
    @visit_q.default_min_host_delay = 50 #ms
    @scheduler = Executors::new_scheduled_thread_pool( 1 )
  end

  def teardown
    @scheduler.shutdown_now if @scheduler
  end

  def test_priority_acquire
    check_priority
  end

  def test_priority_take
    check_priority( :take_order )
  end

  def check_priority( access_method = :acquire_order )
    orders = [ %w[ h a 1.3 ],
               %w[ h b 1.1 ],
               %w[ h c 1.2 ] ].map do |oinp|
      order( oinp )
    end

    @visit_q.add_all( orders )

    orders.sort { |p,n| n.priority <=> p.priority }.each do |o|
      assert_equal( o.vtest_input, send( access_method ) )
    end

    assert_queue_empty
  end

  def test_hosts_acquire
    check_priority_hosts
  end

  def test_hosts_take
    check_priority_hosts( :take_order )
  end

  def add_common_orders
    [ %w[   h2 a 2.2 100 ],
      %w[ w.h2 b 2.1 ],
      %w[   h2 c 2.0 ],
      %w[   h3 a 3.2 130 ],
      %w[   h3 b 3.1 130 ],
      %w[ m.h3 c 3.0 ],
      %w[   h1 a 1.2 ],
      %w[   h1 b 1.1 ] ].each do |oinp|

      @visit_q.add( order( oinp ) )
    end

    assert_equal( 3, @visit_q.host_count, "host count" )
    assert_equal( 8, @visit_q.order_count, "order count" )
  end

  def check_priority_hosts( access_method = :acquire_order )
    add_common_orders

    expected = [ %w[   h3 a 3.2 ],
                 %w[   h2 a 2.2 ],
                 %w[   h1 a 1.2 ],
                 %w[   h1 b 1.1 ],
                 %w[ w.h2 b 2.1 ],
                 %w[   h3 b 3.1 ],
                 %w[   h2 c 2.0 ],
                 %w[ m.h3 c 3.0 ] ]

    p = 0
    expected.each do |o|
      assert_equal( o, send( access_method ), p += 1 )
    end

    assert_queue_empty
  end

  def test_configure
    @visit_q.configure_host( 'h2.com', 75, 2 )

    [ %w[   h2 a 2.2 ],
      %w[ w.h2 b 2.1 ],
      %w[   h3 a 3.2 ],
      %w[   h3 b 3.1 ],
      %w[   h1 a 1.2 ],
      %w[   h1 b 1.1 ] ].each do |oinp|

      @visit_q.add( order( oinp ) )

    end
    assert_equal( 3, @visit_q.host_count, "host count" )

    expected = [ %w[   h3 a 3.2 ],
                 %w[   h2 a 2.2 ],
                 %w[   h1 a 1.2 ],
                 %w[   h3 b 3.1 ],
                 %w[   h1 b 1.1 ],
                 %w[ w.h2 b 2.1 ] ]

    p = 0
    expected.each do |o|
      assert_equal( o, acquire_order, p += 1 )
    end

    assert_queue_empty
  end

  def test_multi_access_2
    @visit_q.default_max_access_per_host = 2
    add_common_orders

    expected = [ %w[   h3 a 3.2 ],
                 %w[   h2 a 2.2 ],
                 %w[   h1 a 1.2 ],
                 %w[   h3 b 3.1 ],
                 %w[ w.h2 b 2.1 ],
                 %w[   h1 b 1.1 ],
                 %w[   h2 c 2.0 ],
                 %w[ m.h3 c 3.0 ] ]

    p = 0
    expected.each do |o|
      assert_equal( o, acquire_order, p += 1 )
    end

    assert_queue_empty
  end

  def test_multi_access_3
    @visit_q.default_max_access_per_host = 3
    add_common_orders

    expected = [ %w[   h3 a 3.2 ],
                 %w[   h2 a 2.2 ],
                 %w[   h1 a 1.2 ],
                 %w[   h3 b 3.1 ],
                 %w[ w.h2 b 2.1 ],
                 %w[   h1 b 1.1 ],
                 %w[ m.h3 c 3.0 ],
                 %w[   h2 c 2.0 ] ]

    p = 0
    expected.each do |o|
      assert_equal( o, acquire_order, p += 1 )
    end

    assert_queue_empty
  end

  def test_interleaved
    @visit_q.default_max_access_per_host = 3
    @visit_q.default_min_host_delay = 3 #ms

    [ %w[   h1 a 5.1 ],
      %w[   h1 b 5.2 ],
      %w[   h1 c 5.3 ],
      %w[   h1 d 5.4 ],
      %w[   h2 a 1.1 ],
      %w[   h2 b 1.2 ],
      %w[   h2 c 1.3 ],
      %w[   h2 d 1.4 ] ].each do |oinp|

      @visit_q.add( order( oinp ) )
    end

    (392 + 8 ).times do |i|
      o = @visit_q.acquire( 100 )
      assert( o )
      @scheduler.schedule( Job.new { @visit_q.release( o, nil ) },
                           rand( 20 ), TimeUnit::MILLISECONDS )
      if i < 392
        @scheduler.schedule( Job.new {
                               @visit_q.add( order( [ %w[ h1 h2 ][rand( 2 )],
                                                      i,
                                                      o.priority + 0.5 ] ) ) },
                           rand( 20 ), TimeUnit::MILLISECONDS )
      end
      #puts o.url.to_string
      #puts @visit_q.dump.to_string
    end

    @scheduler.shutdown
    assert( @scheduler.await_termination( 5, TimeUnit::SECONDS ) )

    assert_queue_empty
  end

  def assert_queue_empty
    @scheduler.shutdown
    @scheduler.await_termination( 2, TimeUnit::SECONDS )
    @scheduler = nil
    assert_equal( 0, @visit_q.order_count, "order count" )
    assert_equal( 0, @visit_q.host_count,  "host count" )
  end

  def acquire_order
    o = @visit_q.acquire( 200 )
    if o
      o.vtest_input.tap do |i|
        @scheduler.schedule( Job.new { @visit_q.release( o, nil ) },
                             ( i[3] || 20 ).to_i,
                             TimeUnit::MILLISECONDS )
      end.slice( 0..2 )
    end
  end

  def take_order
    hq = @visit_q.take( 200 )
    if hq
      o = hq.remove
      if o
        o.vtest_input.tap do |i|
          @scheduler.schedule( proc { @visit_q.untake( hq ) },
                               ( i[3] || 20 ).to_i,
                               TimeUnit::MILLISECONDS )
        end.slice( 0..2 )
      end
    end
  end

  def order( args )
    host, c, p = args
    UniMap.new.tap do |o|
      o.url = visit_url( "http://#{host}.com/#{c}" )
      o.priority = p.to_f
      o.vtest_input = args
    end
  end

  def visit_url( url )
    VisitURL.normalize( url )
  end

  class Job
    include RJack
    include Runnable

    LOG = SLF4J[ self.class ]

    def initialize( &block )
      @block = block
    end
    def run
      @block.call
    rescue => e
      LOG.error( e )
    end
  end

end
