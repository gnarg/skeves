require 'rubygems'
require 'appengine-rack'
require 'appengine-apis/urlfetch'

Net::HTTP = AppEngine::URLFetch::HTTP

AppEngine::Rack.configure_app(:application => 'jguymon-skeves',
                              :version => 1)

require 'app'

run Sinatra::Application 
