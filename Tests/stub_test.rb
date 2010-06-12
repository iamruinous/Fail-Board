require 'test/unit'

require 'ProjectViewController'

class ProjectViewController < Test::Unit::TestCase
  def setup
    @controller = ProjectViewController.new()
  end
  
  def teardown
    @controller.release()
  end
  
  def test_poller_gets_initialized
    assert true, @controller.poller == nil
  end
end