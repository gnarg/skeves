require 'sinatra'
require 'reve'
require 'yaml'
require 'models'
require 'lib/skills'
require 'appengine-apis/users'
require 'appengine-apis/logger'
require 'appengine-apis/mail'
require 'appengine-apis/labs/taskqueue'

before do
  @user = Users.current_user
  @pilot = Pilot.first(:nickname => @user.nickname) if @user
end 

get '/' do
  erb :index
end

get '/skillqueue' do
  begin
    @skills = @pilot.skill_queue
  rescue Exception => e
    return "Error fetching your queue, please check your API info and try again later: #{e.class.name} - #{e.message}"
  end
  
  return 'No skills in queue.' if @skills.empty?

  erb :skillqueue
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
  Pilot.all(:monitor => true).each do |pilot|
    url = "/queue/monitor/#{pilot.nickname}"
    AppEngine::Labs::TaskQueue.add(:url => url)
  end

  'ok'
end

post '/queue/monitor/:pilot' do
  pilot = Pilot.first(:nickname => params[:pilot])
  begin
    if pilot.skill_queue.empty? && !pilot.notified
      url = "/queue/notify/#{pilot.nickname}"
      AppEngine::Labs::TaskQueue.add(:url => url)
    elsif pilot.skill_queue.any? && pilot.notified
      pilot.notified = false
      pilot.save
    end
  rescue Exception => e
    gae_log = AppEngine::Logger.new    
    gae_log.warn "Problem with #{pilot.nickname}: #{e.class.name} - #{e.message}"
  end  
end

post '/queue/notify/:pilot' do
  pilot = Pilot.first(:nickname => params[:pilot])
  send_queue_warning(pilot)
  gae_log = AppEngine::Logger.new  
  gae_log.info "Sent email to #{pilot.nickname}."
end

def send_queue_warning(pilot)
  user_address = pilot.email
  sender_address = "monitor@skeves.com"
  subject = "[skeves] Skill queue empty."
  body = <<-EOM
    No skill in training.
  EOM
  
  AppEngine::Mail.send(sender_address, user_address, subject, body)

  pilot.notified = true
  pilot.save
end
