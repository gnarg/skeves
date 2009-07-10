require 'sinatra'
require 'reve'
require 'yaml'
require 'lib/skills'
require 'appengine-apis/users'

include AppEngine

before do
  @user = Users.current_user
end 

get '/' do
  erb :index
end

get '/register' do
  erb :register
end

get '/queue' do
  if !@user
    redirect create_login_url('/queue')
  end
  
  eve_auth = YAML.load(File.open(options.root + '/config/eve_auth.yml'))
  
  api = Reve::API.new(eve_auth['user_id'], eve_auth['api_key'])
  queue = []
  api.characters.each do |character|
    queue = api.skill_queue(:characterid => character.id)
    if queue.any?
      @character = character
      break
    end
  end
  
  return 'No skills in queue.' if queue.empty?
  
  @skills = queue.map{|s| Skeves::Skill.new(s)}

  erb :queue
end
