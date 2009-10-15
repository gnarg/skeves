require File.dirname(__FILE__) + '/test_helper'

class SkevesTest < TestBase
  def setup
    @pilot = Pilot.first(:nickname => 'test@example.com')
    @pilot ||= Pilot.create(:nickname => 'test@example.com')
  end

  def test_get_index
    get '/'
    assert last_response.ok?
  end

  def test_get_pilot
    get '/pilot'
    assert last_response.ok?
  end
  
  def test_post_pilot
    Pilot.all.each{|p| p.destroy}
    post '/pilot', :pilot => {:nickname => 'new', :user_id => '123',
      :api_key => '123'}

    pilot = Pilot.first(:nickname => 'test@example.com')
    assert_equal '123', pilot.user_id
    assert_equal '123', pilot.api_key    
  end
end

start_env
Test::Unit::UI::Console::TestRunner.run(SkevesTest)
stop_env
exit
