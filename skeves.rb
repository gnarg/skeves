require 'rubygems'
require 'sinatra'
require 'reve'
require 'yaml'
require 'lib/skills'

get '/' do
  eve_auth = YAML.load(File.open(File.dirname(__FILE__) + '/config/eve_auth.yml'))
  
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

  erb :index
end
