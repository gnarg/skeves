#!/usr/bin/ruby1.8 -w
#
# Copyright:: Copyright 2009 Google Inc.
# Original Author:: Ryan Brown (mailto:ribrdb@google.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Custom types for App Engine

require 'dm-core/type'

module DataMapper
  module Types
    class List < Type
      primitive ::Object

      def self.dump(value, property)
        value
      end
      
      def self.load(value, property)
        value.to_a if value
      end
      
      def self._type=(type)
        @type = type
      end
    end
    
    class Blob < Type
      primitive String
      size 1024 * 1024

      def self.dump(value, property)
        AppEngine::Datastore::Blob.new(value) if value
      end
      
      def self.load(value, property)
        value
      end
    end
  end
end