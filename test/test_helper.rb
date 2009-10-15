Dir.glob('.gems/gems/*/lib').each do |path|
  $:.unshift(File.expand_path(path))
end

require 'java'
require 'rubygems'
require 'app'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'rack/test'
require 'mocha'

import 'com.google.apphosting.api.ApiProxy'
import 'com.google.appengine.api.datastore.dev.LocalDatastoreService'
import 'com.google.appengine.tools.development.ApiProxyLocalImpl'

class TestEnvironment
  include ApiProxy::Environment

  def getAppId
    "test environment"
  end

  def isLoggedIn
    true
  end

  def getAttributes
    {}
  end

  def getEmail
    'test@example.com'
  end

  def getAuthDomain
    'test'
  end

  def getRequestNamespace
    ''
  end
end

set :environment, :test

class TestBase < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

def start_env
  ApiProxy.environment_for_current_thread = TestEnvironment.new
  ApiProxy.delegate = Class.new(ApiProxyLocalImpl).new(java.io.File.new('.'))
end

def stop_env
  ApiProxy.delegate = nil
  ApiProxy.environment_for_current_thread = nil
end
