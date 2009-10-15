require 'appengine-apis'
require 'dm-core'
require 'dm-validations'

include AppEngine

DataMapper.setup(:default, 'appengine://auto')

class Pilot
  include DataMapper::Resource
  
  property :id,       Serial
  property :nickname, String
  property :user_id,  String
  property :api_key,  String, :length => 64
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
      @skills = queue.select{|s| s.end_time.kind_of? Time} \
        .map{|s| Skeves::Skill.new(s)}
    end
    
    @skills
  end
  
  def character
    skill_queue if !@character
    @character
  end
end
