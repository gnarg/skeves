require 'sinatra'
require 'reve'
require 'yaml'
require 'lib/skills'
require 'appengine-apis/users'
require 'appengine-apis/logger'
require 'appengine-apis/mail'
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
  property :email,    String, :length => (1..255), :format => :email_address
  property :monitor,  Boolean, :default => false
  property :notified, Boolean, :default => false

  validates_present :nickname
  validates_present :user_id
  validates_present :api_key

  def skill_queue
    if !@skills
      queue = []
      api = Reve::API.new(self.user_id, self.api_key)
      api.characters.each do |character|
        queue = api.skill_queue(:characterid => character.id)
        if queue.any?
          @character = character
          break
        end
      end
      @skills = queue.select{|s| s.end_time.kind_of? Time}.map{|s| Skeves::Skill.new(s)}
    end
    
    @skills
  end
  
  def character
    skill_queue if !@character
    @character
  end
end

before do
  @user = Users.current_user
  @pilot = Pilot.first(:nickname => @user.nickname) if @user
end 

get '/' do
  erb :index
end

get '/pilot' do
  @pilot ||= Pilot.new
  erb :pilot
end

post '/pilot' do
  @pilot ||= Pilot.new
  @pilot.attributes = params['pilot']
  @pilot.monitor = !params['pilot']['monitor'].nil?
  if @pilot.email.nil? || @pilot.email.empty?
    @pilot.email = @user.email
  end
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
    redirect '/pilot'
  end

  begin
    @skills = @pilot.skill_queue
  rescue Reve::Exceptions => e
    return "Eve didn't like you auth information: #{e.message}"
  rescue Exception => e
    return "Please try again later."
  end
  
  return 'No skills in queue.' if @skills.empty?
  
  erb :queue
end

get '/cron/monitor' do
  gae_log = AppEngine::Logger.new
  
  Pilot.all(:monitor => true).each do |pilot|
    begin
      if pilot.skill_queue.empty? && !pilot.notified
        send_queue_warning(pilot)  
        gae_log.info "Sent email to #{pilot.nickname}."
      elsif pilot.skill_queue.any? && pilot.notified
        pilot.notified = false
        pilot.save
      end
    rescue Exception => e
      gae_log.warn "Problem with #{pilot.nickname}: #{e.class.name} - #{e.message}"
    end
  end

  'ok'
end

def send_queue_warning(pilot)
  user_address = pilot.email
  sender_address = "jon.guymon@gmail.com"
  subject = "[skeves] Skill queue empty."
  body = <<-EOM
    No skill in training.
  EOM
  
  AppEngine::Mail.send(sender_address, user_address, subject, body)

  pilot.notified = true
  pilot.save
end
