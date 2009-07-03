require 'skeves'

set :run, false
set :environment, :production
set :logging, true

run Sinatra::Application 
