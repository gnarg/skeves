require 'sinatra'
require 'reve'
require 'yaml'
require 'lib/skills'
require 'appengine-apis/users'
require 'appengine-apis/logger'
require 'dm-core'
require 'dm-validations'
require 'dm-datastore-adapter/datastore-adapter'

include AppEngine

DataMapper.setup(:default,
                 { :adapter => :datastore,
                   :host => 'localhost' })

class Pilot
  include DataMapper::Resource
  
  property :id,       Serial
  property :nickname, String
  property :user_id,  String
  property :api_key,  String, :size => 64

  validates_present :nickname
  validates_present :user_id
  validates_present :api_key
end

before do
  @user = Users.current_user
  @pilot = Pilot.first(:nickname => @user.nickname) if @user
end 

get '/' do
  erb :index
end

get '/register' do
  @pilot ||= Pilot.new
  erb :register
end

post '/register' do
  @pilot ||= Pilot.new
  @pilot.attributes = params['pilot']
  @pilot.nickname = @user.nickname
  if @pilot.save
    redirect '/queue'
  else
    "ERROR: #{@pilot.errors.inspect}"
  end
end

get '/queue' do
  if !@user
    redirect Users.create_login_url('/queue')
  end

  if !@pilot
    redirect '/register'
  end
  
  api = Reve::API.new(@pilot.user_id, @pilot.api_key)
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
