require 'sinatra'
require 'reve'
require 'yaml'
require 'models'
require 'lib/skills'
require 'appengine-apis/users'
require 'appengine-apis/logger'
require 'appengine-apis/mail'

before do
  @user = Users.current_user
  @pilot = Pilot.first(:nickname => @user.nickname) if @user
end 

get '/' do
  if @pilot
    begin
      @skills = @pilot.skill_queue
    rescue Reve::Exceptions => e
      return "Eve didn't like you auth information: #{e.message}"
    rescue Exception => e
      return "Error fetching your queue, please try again later: #{e.message}"
    end
  
    return 'No skills in queue.' if @skills.empty?
  end

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
    redirect '/'
  else
    "ERROR: #{@pilot.errors.inspect}"
  end
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
