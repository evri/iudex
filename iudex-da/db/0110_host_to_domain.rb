#--
# Copyright (c) 2008-2011 David Kellum
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

class HostToDomain < ActiveRecord::Migration

  def self.up
    # Move host to domain in place. This is intended to be the
    # normalized registration level domain as provided by
    # VisitURL.domain. Existing host values will often not match the
    # RL domain, but the usage as a WorkPoller grouping does not
    # strictly require this. Furthermore it would be very costly to
    # rewrite a large database to correct domain values.  Start with a
    # clean or custom migrated database if this consistency is
    # important for your needs.
    rename_column( 'urls', 'host', 'domain' )
    #Equiv: add_column( 'urls', 'domain', :text, :null => false )
  end

  def self.down
    rename_column( 'urls', 'domain', 'host' )
  end

end