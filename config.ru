require 'rubygems'
require 'appengine-apis/urlfetch'
Net::HTTP = AppEngine::URLFetch::HTTP
require 'app'

set :run, false
set :environment, :production
set :logging, true

run Sinatra::Application 
